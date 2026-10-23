
import fs from "node:fs";
import path from "node:path";

// ---------- CONFIGURATION ----------

const IST_DAY = process.argv[2];

const API_BASE =
    "https://api.dexscreener.com/token-pairs/v1/bsc";

const REQUEST_DELAY_MS = 200;
const MAX_RETRIES = 5;
const REQUEST_TIMEOUT_MS = 15000;
const DEFAULT_429_WAIT_MS = 60000;

let cooldownUntil = 0;

// ---------- DATE VALIDATION ----------

function parseDate(date) {
    if (!/^\d{4}-\d{2}-\d{2}$/.test(date ?? "")) {
        throw new Error("Date must use YYYY-MM-DD format.");
    }

    const [year, month, day] = date.split("-").map(Number);
    const parsed = new Date(Date.UTC(year, month - 1, day));

    if (
        parsed.getUTCFullYear() !== year ||
        parsed.getUTCMonth() !== month - 1 ||
        parsed.getUTCDate() !== day
    ) {
        throw new Error("Invalid calendar date.");
    }

    return { year, month, day };
}

function monthFolder(month) {
    const names = [
        "January", "February", "March", "April",
        "May", "June", "July", "August",
        "September", "October", "November", "December"
    ];

    return `${String(month).padStart(2, "0")}-${names[month - 1]}`;
}

// ---------- UTILITIES ----------

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

function validAddress(address) {
    return /^0x[a-fA-F0-9]{40}$/.test(address);
}

function errorMessage(error) {
    return String(error?.message || error).slice(0, 300);
}

function parseRetryAfter(value) {
    if (!value) return null;

    // Retry-After may be a number of seconds or an HTTP date.
    const seconds = Number(value);

    if (Number.isFinite(seconds) && seconds >= 0) {
        return seconds * 1000;
    }

    const timestamp = Date.parse(value);

    if (Number.isFinite(timestamp)) {
        return Math.max(0, timestamp - Date.now());
    }

    return null;
}

async function waitForCooldown() {
    while (cooldownUntil > Date.now()) {
        const remaining = cooldownUntil - Date.now();

        console.log(
            `  API cooldown: waiting ${Math.ceil(remaining / 1000)} seconds`
        );

        await sleep(remaining);
    }
}

// ---------- ATOMIC OUTPUT ----------

function saveRecords(file, records) {
    const tempFile = `${file}.tmp`;

    const contents = [...records.values()]
        .map(record => JSON.stringify(record))
        .join("\n");

    fs.writeFileSync(
        tempFile,
        contents ? `${contents}\n` : "",
        "utf8"
    );

    fs.renameSync(tempFile, file);
}

function loadRecords(file) {
    const records = new Map();

    if (!fs.existsSync(file)) {
        return records;
    }

    const lines = fs.readFileSync(file, "utf8").split(/\r?\n/);

    for (let i = 0; i < lines.length; i++) {
        if (!lines[i].trim()) continue;

        let record;

        try {
            record = JSON.parse(lines[i]);
        } catch {
            throw new Error(
                `Corrupt JSONL at line ${i + 1}. ` +
                "Back up and repair the file before resuming."
            );
        }

        if (
            typeof record.address !== "string" ||
            !validAddress(record.address) ||
            !["ok", "error"].includes(record.status)
        ) {
            throw new Error(`Invalid saved record at line ${i + 1}.`);
        }

        if (
            record.status === "ok" &&
            (
                typeof record.liquidity !== "number" ||
                !Number.isFinite(record.liquidity) ||
                record.liquidity < 0 ||
                !Number.isInteger(record.pairCount) ||
                record.pairCount < 0
            )
        ) {
            throw new Error(`Invalid saved liquidity at line ${i + 1}.`);
        }

        records.set(record.address.toLowerCase(), record);
    }

    return records;
}

// ---------- API REQUEST ----------

async function fetchPairs(address) {
    let lastError;

    for (let attempt = 0; attempt <= MAX_RETRIES; attempt++) {
        await waitForCooldown();

        try {
            const response = await fetch(
                `${API_BASE}/${address}`,
                {
                    signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS)
                }
            );

            if (!response.ok) {
                const error = new Error(
                    `DexScreener HTTP ${response.status}`
                );

                if (
                    response.status === 429 ||
                    response.status >= 500
                ) {
                    if (response.status === 429) {
                        const serverDelay = parseRetryAfter(
                            response.headers.get("retry-after")
                        );

                        const delay = serverDelay ??
                            Math.max(
                                DEFAULT_429_WAIT_MS,
                                1000 * 2 ** (attempt + 1)
                            );

                        error.retryAfterMs = delay;

                        cooldownUntil = Math.max(
                            cooldownUntil,
                            Date.now() + delay
                        );
                    }

                    throw error;
                }

                error.permanent = true;
                throw error;
            }

            const pairs = await response.json();

            if (!Array.isArray(pairs)) {
                throw new Error(
                    "Invalid API response: expected an array."
                );
            }

            return pairs;

        } catch (error) {
            lastError = error;

            if (error.permanent) break;
            if (attempt === MAX_RETRIES) break;

            const delay = error.retryAfterMs !== undefined
                ? error.retryAfterMs
                : Math.min(1000 * 2 ** attempt, 30000);

            console.log(
                `  Retry ${attempt + 1}/${MAX_RETRIES}: ` +
                `${errorMessage(error)}; waiting ` +
                `${Math.ceil(delay / 1000)} seconds`
            );

            await sleep(delay);
        }
    }

    throw new Error(
        `API request failed after retries: ${errorMessage(lastError)}`
    );
}

// ---------- LIQUIDITY CALCULATION ----------

async function getLiquidity(address) {
    const pairs = await fetchPairs(address);

    let total = 0;

    for (const pair of pairs) {
        if (
            !pair ||
            typeof pair !== "object" ||
            Array.isArray(pair)
        ) {
            throw new Error("Malformed pair in API response.");
        }

        const rawLiquidity = pair.liquidity?.usd;

        if (
            rawLiquidity === null ||
            rawLiquidity === undefined ||
            (
                typeof rawLiquidity !== "number" &&
                typeof rawLiquidity !== "string"
            ) ||
            (
                typeof rawLiquidity === "string" &&
                rawLiquidity.trim() === ""
            )
        ) {
            throw new Error("Pair has missing USD liquidity data.");
        }

        const liquidity = Number(rawLiquidity);

        if (!Number.isFinite(liquidity) || liquidity < 0) {
            throw new Error("Pair has invalid USD liquidity data.");
        }

        total += liquidity;

        if (!Number.isFinite(total)) {
            throw new Error("Total liquidity overflow.");
        }
    }

    return {
        address,
        liquidity: Number(total.toFixed(2)),
        status: "ok",
        pairCount: pairs.length,
        checkedAt: new Date().toISOString()
    };
}

// ---------- MAIN ----------
async function main() {
    if (!IST_DAY) {
        console.error("Usage: node liquidity.js YYYY-MM-DD");
        process.exitCode = 1;
        return;
    }

    let date;

    try {
        date = parseDate(IST_DAY);
    } catch (error) {
        console.error(errorMessage(error));
        process.exitCode = 1;
        return;
    }

    const { year, month, day } = date;
    const monthDir = monthFolder(month);
    const paddedMonthDir = `${String(month).padStart(2, "0")}-${monthDir.split("-").slice(1).join("-")}`;
    const paddedDay = String(day).padStart(2, "0");

    // Keep discovery input paths unchanged.
    const inputFile = path.join(
        "discovery",
        String(year),
        paddedMonthDir,
        `${paddedDay}.txt`
    );

    // Use padded month and day for worth output.
    const outputDir = path.join(
        "worth",
        String(year),
        paddedMonthDir
    );

    const outputFile = path.join(
        outputDir,
        `${paddedDay}.jsonl`
    );

    if (!fs.existsSync(inputFile)) {
        console.error(`Discovery file not found: ${inputFile}`);
        process.exitCode = 1;
        return;
    }

    const addresses = fs.readFileSync(inputFile, "utf8")
        .split(/\r?\n/)
        .map(address => address.trim())
        .filter(Boolean);

    const seen = new Set();
    const validAddresses = [];
    const invalidAddresses = [];

    for (const address of addresses) {
        if (!validAddress(address)) {
            invalidAddresses.push(address);
            continue;
        }

        const key = address.toLowerCase();

        if (seen.has(key)) continue;

        seen.add(key);
        validAddresses.push(address);
    }

    fs.mkdirSync(outputDir, { recursive: true });

    const records = loadRecords(outputFile);

    const pending = validAddresses.filter(address => {
        const previous = records.get(address.toLowerCase());
        return previous?.status !== "ok";
    });

    console.log(`Input addresses : ${addresses.length}`);
    console.log(`Valid unique     : ${validAddresses.length}`);
    console.log(`Invalid          : ${invalidAddresses.length}`);
    console.log(
        `Already completed: ${validAddresses.length - pending.length}`
    );
    console.log(`To scan          : ${pending.length}\n`);

    for (const address of invalidAddresses) {
        console.error(`Invalid address: ${address}`);
    }

    let successes = 0;
    let failures = 0;

    for (let i = 0; i < pending.length; i++) {
        const address = pending[i];

        try {
            const record = await getLiquidity(address);

            records.set(address.toLowerCase(), record);
            successes++;

            console.log(
                `[${i + 1}/${pending.length}] ${address} ` +
                `$${record.liquidity.toFixed(2)} ` +
                `(${record.pairCount} pairs)`
            );

        } catch (error) {
            records.set(address.toLowerCase(), {
                address,
                liquidity: null,
                status: "error",
                error: errorMessage(error),
                checkedAt: new Date().toISOString()
            });

            failures++;

            console.error(
                `[${i + 1}/${pending.length}] ${address} FAILED: ` +
                errorMessage(error)
            );
        }

        saveRecords(outputFile, records);

        if ((i + 1) % 100 === 0) {
            console.log(`Scanned ${i + 1}/${pending.length}`);
        }

        if (i + 1 < pending.length) {
            await sleep(REQUEST_DELAY_MS);
        }
    }

    const successfulTotal = validAddresses.filter(address =>
        records.get(address.toLowerCase())?.status === "ok"
    ).length;

    const failedTotal = validAddresses.length - successfulTotal;

    console.log("\n========== SUMMARY ==========");
    console.log(`Input   : ${inputFile}`);
    console.log(`Output  : ${outputFile}`);
    console.log(`Success : ${successfulTotal}`);
    console.log(`Failed  : ${failedTotal}`);
    console.log(`Invalid : ${invalidAddresses.length}`);
    console.log(`Records : ${records.size}`);
    console.log("==============================");

    if (failedTotal > 0 || invalidAddresses.length > 0) {
        process.exitCode = 1;
    }
}
main().catch(error => {
    console.error("Fatal error:", errorMessage(error));
    process.exitCode = 1;
});

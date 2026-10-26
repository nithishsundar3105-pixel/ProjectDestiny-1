
import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const ROOT = process.cwd();
const WORTH_DIR = path.join(ROOT, "worth");
const CODE_DIR = path.join(ROOT, "code");

const BSCSCAN_API = "https://api.etherscan.io/v2/api";
const BSC_CHAIN_ID = "56";
const BSCSCAN_API_KEY = "MXTXIGEJQAMXFKCDCQ3NB3XKJRDQG766TI";
const BSC_RPC_URL =
    process.env.BSC_RPC_URL || "https://bsc-dataseed.binance.org";

const MIN_LIQUIDITY = 100;

// EIP-1967 implementation storage slot:
// bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1)
const IMPLEMENTATION_SLOT =
    "0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc";

const MONTHS = [
    "January", "February", "March", "April",
    "May", "June", "July", "August",
    "September", "October", "November", "December",
];

const sleep = (ms) =>
    new Promise((resolve) => setTimeout(resolve, ms));

function parseDate(value) {
    if (!/^\d{4}-\d{2}-\d{2}$/.test(value || "")) {
        throw new Error("Usage: node verified.js YYYY-MM-DD");
    }

    const [year, month, day] = value.split("-").map(Number);
    const date = new Date(Date.UTC(year, month - 1, day));

    if (
        date.getUTCFullYear() !== year ||
        date.getUTCMonth() !== month - 1 ||
        date.getUTCDate() !== day
    ) {
        throw new Error(`Invalid date: ${value}`);
    }

    return {
        year: String(year),
        month: String(month).padStart(2, "0"),
        day: String(day).padStart(2, "0"),
        monthName: MONTHS[month - 1],
    };
}

async function readJsonl(filePath) {
    const content = await fs.readFile(filePath, "utf8");
    const records = [];

    for (const [index, line] of content.split(/\r?\n/).entries()) {
        if (!line.trim()) continue;

        try {
            const record = JSON.parse(line);

            if (
                typeof record.address !== "string" ||
                !/^0x[0-9a-fA-F]{40}$/.test(record.address)
            ) {
                console.warn(`Skipping invalid address on line ${index + 1}`);
                continue;
            }

            if (!Number.isFinite(Number(record.liquidity))) {
                console.warn(`Skipping invalid liquidity on line ${index + 1}`);
                continue;
            }

            records.push({
                ...record,
                address: record.address.toLowerCase(),
                liquidity: Number(record.liquidity),
            });
        } catch {
            console.warn(`Skipping malformed JSON on line ${index + 1}`);
        }
    }

    // A contract should only be processed once per day.
    return [
        ...new Map(records.map((r) => [r.address, r])).values(),
    ];
}

async function bscScan(action, params = {}) {
    if (!BSCSCAN_API_KEY) {
        throw new Error("Set the BSCSCAN_API_KEY environment variable.");
    }

    const url = new URL(BSCSCAN_API);
    url.searchParams.set("chainid", BSC_CHAIN_ID);
    url.searchParams.set("module", "contract");
    url.searchParams.set("action", action);
    url.searchParams.set("apikey", BSCSCAN_API_KEY);

    for (const [key, value] of Object.entries(params)) {
        url.searchParams.set(key, value);
    }

    let lastError;

    for (let attempt = 0; attempt < 3; attempt++) {
        try {
            const response = await fetch(url, {
                signal: AbortSignal.timeout(30000),
            });

            if (!response.ok) {
                throw new Error(`BscScan HTTP ${response.status}`);
            }

            const data = await response.json();

            if (
                String(data.status) === "1" &&
                Array.isArray(data.result)
            ) {
                return data.result[0] || null;
            }

            // Verification absence is handled by getContract().
            // Other API errors are retried, then reported.
            throw new Error(
                `BscScan ${action}: ${data.message || ""} ${typeof data.result === "string"
                    ? data.result
                    : JSON.stringify(data.result)
                }`
            );
        } catch (error) {
            lastError = error;
            if (attempt < 2) await sleep(1000 * (attempt + 1));
        }
    }

    throw lastError;
}

async function rpc(method, params) {
    const response = await fetch(BSC_RPC_URL, {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({
            jsonrpc: "2.0",
            id: 1,
            method,
            params,
        }),
        signal: AbortSignal.timeout(30000),
    });

    if (!response.ok) {
        throw new Error(`BSC RPC HTTP ${response.status}`);
    }

    const data = await response.json();

    if (data.error) {
        throw new Error(`BSC RPC: ${data.error.message}`);
    }

    return data.result;
}

function extractImplementation(storageValue) {
    if (!storageValue || /^0x0*$/.test(storageValue)) {
        return null;
    }

    const address = "0x" + storageValue.slice(-40);

    if (/^0x0{40}$/i.test(address)) {
        return null;
    }

    return address.toLowerCase();
}

async function getContract(address) {
    const result = await bscScan("getsourcecode", { address });

    if (!result || !result.SourceCode?.trim()) {
        return null;
    }

    return {
        address: address.toLowerCase(),
        name: result.ContractName || "Unknown",
        sourceCode: result.SourceCode,
        implementation: result.Implementation || "",
        proxyFlag: result.Proxy || "0",
    };
}

// Supports both single-file verification and the JSON source bundle
// returned by BscScan for multi-file Solidity projects.
function sourceToText(sourceCode) {
    let value = sourceCode.trim();

    // BscScan sometimes wraps standard JSON input in an extra pair
    // of braces: {{ ... }}.
    if (value.startsWith("{{") && value.endsWith("}}")) {
        value = value.slice(1, -1);
    }

    try {
        const parsed = JSON.parse(value);
        const sources = parsed.sources;

        if (sources && typeof sources === "object") {
            return Object.entries(sources)
                .map(([fileName, file]) => {
                    const content = file.content || "";
                    return `// ===== Original source: ${fileName} =====\n${content}`;
                })
                .join("\n\n");
        }
    } catch {
        // Normal flattened or single-file Solidity source.
    }

    return value;
}

function metadataComment({
    address,
    liquidity,
    name,
    proxyAddress,
    implementationAddress,
    implementationName,
}) {
    const lines = [
        "// ============================================================",
        `// Contract name: ${name}`,
        `// Contract address: ${address}`,
        `// Liquidity: $${liquidity}`,
    ];

    if (proxyAddress) {
        lines.push(
            `// Proxy address: ${proxyAddress}`,
            `// Proxy name: ${name}`,
            `// Implementation address: ${implementationAddress}`,
            `// Implementation name: ${implementationName}`
        );
    }

    lines.push(
        "// Chain: BNB Smart Chain (56)",
        "// Source: BscScan verified contract",
        "// ============================================================",
        ""
    );

    return lines.join("\n");
}

async function saveSource(outputDir, number, contract, metadata) {
    const filename = `${number}.sol`;
    const outputPath = path.join(outputDir, filename);

    const text =
        metadataComment(metadata) +
        sourceToText(contract.sourceCode) +
        "\n";

    await fs.writeFile(outputPath, text, "utf8");

    console.log(`  Saved ${filename}: ${contract.name}`);
    return filename;
}

async function createUltimate(outputDir) {
    const entries = await fs.readdir(outputDir, {
        withFileTypes: true,
    });

    const solFiles = entries
        .filter((entry) => entry.isFile() && /^\d+\.sol$/.test(entry.name))
        .map((entry) => entry.name)
        .sort((a, b) => Number.parseInt(a) - Number.parseInt(b));

    const sections = [];

    for (const filename of solFiles) {
        const content = await fs.readFile(
            path.join(outputDir, filename),
            "utf8"
        );

        sections.push(
            `\n//\n// ===== BEGIN ${filename} =====\n//\n`,
            content,
            `\n// ===== END ${filename} =====\n`
        );
    }

    await fs.writeFile(
        path.join(outputDir, "ultimate.sol"),
        sections.join("\n"),
        "utf8"
    );

    console.log(`Created ultimate.sol (${solFiles.length} source files)`);
}

async function main() {
    const date = parseDate(process.argv[2]);

    if (!BSCSCAN_API_KEY) {
        throw new Error(
            "Missing BSCSCAN_API_KEY. Set it before running the program."
        );
    }

    const inputPath = path.join(
        WORTH_DIR,
        date.year,
        `${date.month}-${date.monthName}`,
        `${date.day}.jsonl`
    );

    const outputDir = path.join(
        CODE_DIR,
        date.year,
        `${date.month}-${date.monthName}`,
        `Day-${date.day}`
    );

    await fs.access(inputPath);
    await fs.mkdir(outputDir, { recursive: true });

    const records = await readJsonl(inputPath);
    const selected = records.filter(
        (record) => record.liquidity > MIN_LIQUIDITY
    );

    const stats = {
        inputRecords: records.length,
        liquidityPass: selected.length,
        verifiedContracts: 0,
        unverifiedContracts: 0,
        nonProxy: 0,
        proxy: 0,
        verifiedImplementations: 0,
        unverifiedImplementations: 0,
        sourceFilesSaved: 0,
        errors: 0,
    };

    // Remove numbered files from a previous run so that rerunning
    // the same date does not leave stale Solidity files behind.
    for (const entry of await fs.readdir(outputDir, {
        withFileTypes: true,
    })) {
        if (
            entry.isFile() &&
            (/^\d+\.sol$/.test(entry.name) ||
                entry.name === "ultimate.sol" ||
                entry.name === "details.txt")
        ) {
            await fs.unlink(path.join(outputDir, entry.name));
        }
    }

    let fileNumber = 1;

    console.log(`Date: ${process.argv[2]}`);
    console.log(`Input: ${inputPath}`);
    console.log(`Liquidity-qualified contracts: ${selected.length}`);

    for (const record of selected) {
        const address = record.address;

        console.log(`\nChecking ${address} ($${record.liquidity})`);

        try {
            // Step 1: The proxy contract itself must be verified.
            const contract = await getContract(address);
            await sleep(250);

            if (!contract) {
                stats.unverifiedContracts++;
                console.log("  Skipped: contract source is not verified");
                continue;
            }

            stats.verifiedContracts++;

            // Step 2: Query the actual EIP-1967 implementation slot.
            const storageValue = await rpc(
                "eth_getStorageAt",
                [address, IMPLEMENTATION_SLOT, "latest"]
            );

            const implementation = extractImplementation(storageValue);

            if (!implementation || implementation === address) {
                stats.nonProxy++;

                await saveSource(outputDir, fileNumber++, contract, {
                    address,
                    liquidity: record.liquidity,
                    name: contract.name,
                });

                stats.sourceFilesSaved++;
                continue;
            }

            // Step 3: Proxy detected. Its implementation must also be
            // verified before any source file is saved for this token.
            stats.proxy++;
            console.log(`  Proxy implementation: ${implementation}`);

            const implementationContract =
                await getContract(implementation);

            await sleep(250);

            if (!implementationContract) {
                stats.unverifiedImplementations++;
                console.log("  Skipped: implementation is not verified");
                continue;
            }

            stats.verifiedImplementations++;

            // Save implementation source, with metadata for both contracts.
            await saveSource(
                outputDir,
                fileNumber++,
                implementationContract,
                {
                    address: implementation,
                    liquidity: record.liquidity,
                    name: contract.name,
                    proxyAddress: address,
                    implementationAddress: implementation,
                    implementationName: implementationContract.name,
                }
            );

            stats.sourceFilesSaved++;
        } catch (error) {
            stats.errors++;
            console.error(`  Error: ${error.message}`);
        }
    }

    const report = [
        `Date: ${process.argv[2]}`,
        `Input file: ${path.relative(ROOT, inputPath)}`,
        "",
        `Unique valid input records: ${stats.inputRecords}`,
        `Liquidity threshold: > $${MIN_LIQUIDITY}`,
        `Passed liquidity filter: ${stats.liquidityPass}`,
        "",
        `Verified contracts: ${stats.verifiedContracts}`,
        `Unverified contracts: ${stats.unverifiedContracts}`,
        "",
        `Non-proxy contracts: ${stats.nonProxy}`,
        `Proxy contracts: ${stats.proxy}`,
        `Verified proxy implementations: ${stats.verifiedImplementations}`,
        `Unverified proxy implementations: ${stats.unverifiedImplementations}`,
        "",
        `Source files saved: ${stats.sourceFilesSaved}`,
        `Processing errors: ${stats.errors}`,
        "",
        "Note: A verified proxy whose implementation is unverified is not saved.",
    ].join("\n");

    await fs.writeFile(
        path.join(outputDir, "details.txt"),
        report + "\n",
        "utf8"
    );

    await createUltimate(outputDir);

    console.log("\n" + report);
    console.log(`\nOutput directory: ${outputDir}`);
}

main().catch((error) => {
    console.error(error.message);
    process.exitCode = 1;
});

import { ethers } from "ethers";
import fs from "fs";
import path from "path";

const RPC =
    "https://bsc-mainnet.infura.io/v3/030c61a42b4d4b08a30ef087e7fae563"; //030c61a42b4d4b08a30ef087e7fae563 //102ea0bb5e114762b8b0fa4f055b2706
//https://rpc.ankr.com/bsc/5e1fc5d2bf7094628b5d570f6667413c181a0523999b7ee7facfb48ff7b56b20  https://bsc-mainnet.infura.io/v3/102ea0bb5e114762b8b0fa4f055b270

const FACTORY =
    "0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73";

const ABI = [
    "event PairCreated(address indexed token0,address indexed token1,address pair,uint)"
];

const CANONICAL_FILE = "canonical/unique.txt";

const provider = new ethers.JsonRpcProvider(RPC);
const factory = new ethers.Contract(FACTORY, ABI, provider);

const IST_DAY = process.argv[2];

if (!IST_DAY) {
    console.log("Usage:");
    console.log("node Unique.js YYYY-MM-DD");
    process.exit(1);
}

// --------------------------------------------------
// Configuration
// --------------------------------------------------

// const EXCLUDED_PREFIXES = [
//     "7777",
//     "4444",
//     "ffff"
// ];


const EXCLUDED_SUFFIXES = [
    "7777",
    "4444",
    "ffff"
];

// --------------------------------------------------
// Utility
// --------------------------------------------------

const sleep = (ms) =>
    new Promise(resolve => setTimeout(resolve, ms));

// --------------------------------------------------
// Safe PairCreated log retrieval
// --------------------------------------------------

// async function getPastLogsSafe(
//     contract,
//     fromBlock,
//     toBlock
// ) {
//     try {
//         await sleep(50);

//         return await contract.queryFilter(
//             contract.filters.PairCreated(),
//             fromBlock,
//             toBlock
//         );
//     } catch (error) {
//         const errorMsg =
//             error.message || "";

//         const innerError =
//             error.error || {};

//         const errorCode =
//             innerError.code ||
//             error.code;

//         const innerMessage =
//             innerError.message || "";

//         if (
//             errorCode === -32005 ||
//             errorCode === -32602 ||
//             errorMsg.includes("10000 results") ||
//             innerMessage.includes(
//                 "exceeds limit of 10000"
//             )
//         ) {
//             if (fromBlock >= toBlock) {
//                 throw new Error(
//                     `Single block ${fromBlock} exceeds Infura's internal limits.`
//                 );
//             }

//             const midBlock =
//                 Math.floor(
//                     (fromBlock + toBlock) / 2
//                 );

//             console.log(
//                 `[Info] Infura limit hit. ` +
//                 `Splitting ${fromBlock} -> ${toBlock}`
//             );

//             const firstHalf =
//                 await getPastLogsSafe(
//                     contract,
//                     fromBlock,
//                     midBlock
//                 );

//             const secondHalf =
//                 await getPastLogsSafe(
//                     contract,
//                     midBlock + 1,
//                     toBlock
//                 );

//             return firstHalf.concat(
//                 secondHalf
//             );
//         }

//         if (
//             errorMsg.includes("429") ||
//             errorMsg.includes(
//                 "Too Many Requests"
//             )
//         ) {
//             console.log(
//                 "[Warning] Rate limit hit. " +
//                 "Backing off for 2.5 seconds..."
//             );

//             await sleep(2500);

//             return await getPastLogsSafe(
//                 contract,
//                 fromBlock,
//                 toBlock
//             );
//         }

//         throw error;
//     }
// }

async function getPastLogsSafe(
    contract,
    fromBlock,
    toBlock
) {
    try {
        await sleep(50);

        return await contract.queryFilter(
            contract.filters.PairCreated(),
            fromBlock,
            toBlock
        );
    } catch (error) {
        const errorMsg =
            error.message || "";

        const innerError =
            error.error || {};

        const errorCode =
            innerError.code ||
            error.code;

        const innerMessage =
            innerError.message || "";

        // Updated condition to capture Ankr's limit error (-32062 / "Block range is too large")
        if (
            errorCode === -32005 ||
            errorCode === -32602 ||
            errorCode === -32062 ||
            errorMsg.includes("10000 results") ||
            errorMsg.includes("Block range is too large") ||
            innerMessage.includes("exceeds limit of 10000") ||
            innerMessage.includes("Block range is too large")
        ) {
            if (fromBlock >= toBlock) {
                throw new Error(
                    `Single block ${fromBlock} exceeds RPC internal limits.`
                );
            }

            const midBlock =
                Math.floor(
                    (fromBlock + toBlock) / 2
                );

            console.log(
                `[Info] RPC limit hit. ` +
                `Splitting ${fromBlock} -> ${toBlock}`
            );

            const firstHalf =
                await getPastLogsSafe(
                    contract,
                    fromBlock,
                    midBlock
                );

            const secondHalf =
                await getPastLogsSafe(
                    contract,
                    midBlock + 1,
                    toBlock
                );

            return firstHalf.concat(
                secondHalf
            );
        }

        if (
            errorMsg.includes("429") ||
            errorMsg.includes(
                "Too Many Requests"
            )
        ) {
            console.log(
                "[Warning] Rate limit hit. " +
                "Backing off for 2.5 seconds..."
            );

            await sleep(2500);

            return await getPastLogsSafe(
                contract,
                fromBlock,
                toBlock
            );
        }

        throw error;
    }
}


// --------------------------------------------------
// IST date -> timestamp window
// --------------------------------------------------

function getIstWindow(day) {
    const start =
        new Date(
            `${day}T00:00:00+05:30`
        );

    const end =
        new Date(start);

    end.setUTCDate(
        end.getUTCDate() + 1
    );

    return {
        startTimestamp:
            Math.floor(
                start.getTime() / 1000
            ),

        endTimestamp:
            Math.floor(
                end.getTime() / 1000
            )
    };
}

// --------------------------------------------------
// Timestamp -> BSC block
// --------------------------------------------------

async function findBlockByTimestamp(
    targetTimestamp
) {
    const latest =
        await provider.getBlock(
            "latest"
        );

    let low = 1;
    let high = latest.number;

    while (low < high) {
        const mid =
            Math.floor(
                (low + high) / 2
            );

        const block =
            await provider.getBlock(mid);

        if (
            block.timestamp <
            targetTimestamp
        ) {
            low = mid + 1;
        } else {
            high = mid;
        }
    }

    return low;
}

// --------------------------------------------------
// Load canonical registry
// --------------------------------------------------

function loadCanonical() {
    const set = new Set();

    if (
        !fs.existsSync(
            CANONICAL_FILE
        )
    ) {
        fs.mkdirSync(
            path.dirname(
                CANONICAL_FILE
            ),
            {
                recursive: true
            }
        );

        return set;
    }

    const data =
        fs
            .readFileSync(
                CANONICAL_FILE,
                "utf8"
            )
            .split(/\r?\n/)
            .map(x =>
                x.trim().toLowerCase()
            )
            .filter(Boolean);

    for (const addr of data) {
        set.add(addr);
    }

    return set;
}

// --------------------------------------------------
// Month folder naming
// --------------------------------------------------

function monthFolder(month) {
    const names = [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
    ];

    return `${month}-${names[month - 1]}`;
}

// --------------------------------------------------
// Main
// --------------------------------------------------

async function main() {
    const {
        startTimestamp,
        endTimestamp
    } = getIstWindow(IST_DAY);

    console.log(
        `Resolving block ranges for ${IST_DAY}...`
    );

    const fromBlock =
        await findBlockByTimestamp(
            startTimestamp
        );

    const toBlock =
        (
            await findBlockByTimestamp(
                endTimestamp
            )
        ) - 1;

    console.log(
        `IST Day : ${IST_DAY}`
    );

    console.log(
        `Blocks  : ${fromBlock} -> ${toBlock}`
    );

    console.log(
        "Fetching events safely..."
    );

    // --------------------------------------------------
    // Fetch PairCreated events
    // --------------------------------------------------

    const events =
        await getPastLogsSafe(
            factory,
            fromBlock,
            toBlock
        );

    console.log(
        `PairCreated events retrieved: ${events.length}`
    );

    // --------------------------------------------------
    // Canonical registry
    // --------------------------------------------------

    const canonical =
        loadCanonical();

    const before =
        canonical.size;

    const newlyDiscovered = [];

    let excludedBySuffix = 0;

    // --------------------------------------------------
    // Process token address
    // --------------------------------------------------

    function processAddress(address) {
        address =
            address.toLowerCase();

        const addressWithout0x =
            address.startsWith("0x")
                ? address.slice(2)
                : address;

        // --------------------------------------------------
        // Exclude addresses beginning with 7777, 4444, ffff
        // --------------------------------------------------

        // if (
        //     EXCLUDED_PREFIXES.some(prefix =>
        //         addressWithout0x.startsWith(prefix)
        //     )
        // ) {
        //     excludedByPrefix++;
        //     return;
        // }

        // Exclude addresses ending with 7777, 4444, or ffff
        if (
            EXCLUDED_SUFFIXES.some(suffix =>
                address.endsWith(suffix)
            )
        ) {
            excludedBySuffix++;
            return;
        }

        // --------------------------------------------------
        // Already known
        // --------------------------------------------------

        if (
            canonical.has(address)
        ) {
            return;
        }

        // --------------------------------------------------
        // New canonical token
        // --------------------------------------------------

        canonical.add(address);

        newlyDiscovered.push(
            address
        );
    }

    // --------------------------------------------------
    // Process all PairCreated events
    // --------------------------------------------------

    for (const event of events) {
        processAddress(
            event.args.token0
        );

        processAddress(
            event.args.token1
        );
    }

    // --------------------------------------------------
    // Append new tokens to canonical
    // --------------------------------------------------

    if (
        newlyDiscovered.length > 0
    ) {
        const prefix =
            before > 0
                ? "\n"
                : "";

        fs.appendFileSync(
            CANONICAL_FILE,
            prefix +
            newlyDiscovered.join("\n")
        );
    }

    // --------------------------------------------------
    // Daily discovery file
    // --------------------------------------------------

    const [
        year,
        month,
        day
    ] = IST_DAY.split("-");

    const discoveryDir =
        path.join(
            "discovery",
            year,
            monthFolder(
                Number(month)
            )
        );

    const discoveryFile =
        path.join(
            discoveryDir,
            `${Number(day)}.txt`
        );

    fs.mkdirSync(
        discoveryDir,
        {
            recursive: true
        }
    );

    fs.writeFileSync(
        discoveryFile,
        newlyDiscovered.join("\n")
    );

    // --------------------------------------------------
    // Summary
    // --------------------------------------------------

    console.log();

    console.log(
        "========== SUMMARY =========="
    );

    console.log(
        `PairCreated events : ${events.length}`
    );

    console.log(
        `Known before       : ${before}`
    );

    // console.log(
    //     `Excluded prefixes  : ${excludedByPrefix}`
    // );

    console.log(
        `Excluded suffixes  : ${excludedBySuffix}`
    );

    console.log(
        `New discoveries    : ${newlyDiscovered.length}`
    );

    console.log(
        `Canonical size     : ${canonical.size}`
    );

    console.log(
        `Discovery file     : ${discoveryFile}`
    );

    console.log(
        "============================="
    );
}

main().catch(console.error);
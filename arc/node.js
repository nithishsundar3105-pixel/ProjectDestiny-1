
import { ethers } from "ethers";

const RPC = "https://bsc-mainnet.infura.io/v3/030c61a42b4d4b08a30ef087e7fae563 ";

const FACTORY =
    "0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73";

const ABI = [
    "event PairCreated(address indexed token0,address indexed token1,address pair,uint)"
];

const provider = new ethers.JsonRpcProvider(RPC);
const factory = new ethers.Contract(FACTORY, ABI, provider);

const IST_DAY = process.argv[2];

if (!IST_DAY) {
    console.log("Usage: node pairs.js YYYY-MM-DD");
    process.exit(1);
}

function getIstWindow(day) {
    const start = new Date(`${day}T00:00:00+05:30`);
    const end = new Date(start);

    end.setUTCDate(end.getUTCDate() + 1);

    return {
        start: Math.floor(start.getTime() / 1000),
        end: Math.floor(end.getTime() / 1000)
    };
}

async function findBlockByTimestamp(target) {
    const latest = await provider.getBlock("latest");

    let low = 1;
    let high = latest.number;

    while (low < high) {
        const mid = Math.floor((low + high) / 2);
        const block = await provider.getBlock(mid);

        if (block.timestamp < target) {
            low = mid + 1;
        } else {
            high = mid;
        }
    }

    const block = await provider.getBlock(low);

    // Target timestamp has not been reached yet.
    if (block.timestamp < target) {
        throw new Error("Target timestamp is beyond the latest block");
    }

    return low;
}


async function main() {
    const { start, end } = getIstWindow(IST_DAY);

    const fromBlock = await findBlockByTimestamp(start);
    const toBlock = (await findBlockByTimestamp(end)) - 1;

    console.log(`IST date: ${IST_DAY}`);
    console.log(`Blocks: ${fromBlock} -> ${toBlock}`);

    if (toBlock < fromBlock) {
        console.log("No blocks in this date range.");
        return;
    }

    const MAX_CHUNK_SIZE = 5000;
    let currentBlock = fromBlock;
    const tokens = new Set();

    while (currentBlock <= toBlock) {
        const chunkToBlock = Math.min(
            currentBlock + MAX_CHUNK_SIZE - 1,
            toBlock
        );

        console.log(
            `Fetching logs from block ${currentBlock} to ${chunkToBlock}...`
        );

        const eventsChunk = await factory.queryFilter(
            factory.filters.PairCreated(),
            currentBlock,
            chunkToBlock
        );

        for (const event of eventsChunk) {
            tokens.add(event.args.token0.toLowerCase());
            tokens.add(event.args.token1.toLowerCase());
        }

        currentBlock = chunkToBlock + 1;
    }

    for (const token of tokens) {
        console.log(token);
    }

    console.log(`Unique tokens: ${tokens.size}`);
}

main().catch(console.error);

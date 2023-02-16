#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

const CONTRACT_NAME = /^(.*)GasTest\:/;
const TEST_NAME = /\:(.*?)\(/;
const GAS_AMOUNT = /gas\: (\d+)/;

const DESCRIPTIONS = {
    test_findKeyIn10kMap: "Find a key in a 10k map",
    test_findKeySingleKeyMap: "Find a key in a single key map",
    test_iterate10kKeys: "Iterate over 10k keys",
    test_remove10kKeys: "Remove 10k keys",
    test_write10kKeys: "Write 10k keys to map",
    test_write100kKeys: "Write 100k keys to map",
    test_writeSingleKey: "Write a single key"
};

const results = {};

exec('forge snapshot --match-path "./test/gas-comparison/*"', async (err, stdout, stderr) => {
    if (err) {
        console.error('Forge command failed');
        return;
    }

    const file = fs.readFileSync(path.join(__dirname, '.gas-snapshot'), 'utf8');
    const lines = file.split('\n');

    for (let line of lines) {
        const contract = line.match(CONTRACT_NAME)[1];
        const test = line.match(TEST_NAME)[1];
        const gas = line.match(GAS_AMOUNT)[1];
        results[test] = results[test] ?? { HashMap: null, EnumerableMap: null, Mapping: null };
        results[test][contract] = BigInt(gas).toLocaleString();
    }

    const table = [
        ['Test', 'HashMap', 'EnumerableMap', 'Mapping']
    ];

    for (let [test, result] of Object.entries(results)) {
        table.push([DESCRIPTIONS[test], result.HashMap, result.EnumerableMap, result.Mapping]);
    }

    const { markdownTable } = await import('markdown-table');
    const markdown = markdownTable(table);

    console.log(markdown);
});

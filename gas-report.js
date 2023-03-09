#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

const DESCRIPTIONS = {
    test_findKeyIn10kMap: "Find a key in a 10k map",
    test_findKeySingleKeyMap: "Find a key in a single key map",
    test_iterate10kKeys: "Iterate over 10k keys",
    test_remove10kKeys: "Remove 10k keys",
    test_write10kKeys: "Write 10k keys to map",
    test_write100kKeys: "Write 100k keys to map",
    test_writeSingleKey: "Write a single key"
};

const ORDER = [
    "test_writeSingleKey",
    "test_write10kKeys",
    "test_write100kKeys",
    "test_findKeyIn10kMap",
    "test_findKeySingleKeyMap",
    "test_iterate10kKeys",
    "test_remove10kKeys"
];

const results = {};

exec('forge test -j --match-path "./test/gas-comparison/*"', async (err, stdout, stderr) => {
    if (err) {
        console.error('Forge command failed');
        return;
    }

    const json = stdout.split('\n').find(l => l.startsWith('{'));
    const info = JSON.parse(json);

    for (let [testFile, details] of Object.entries(info)) {
        const contract = testFile.split(':')[1].replace('GasTest', '');
        for (let [test, testResults] of Object.entries(details.test_results)) {
            test = test.replace('()', '');
            const gas = testResults.decoded_logs.find(l => l.startsWith('Gas used')).match(/(\d+)/)[1];
            results[test] = results[test] ?? { HashMap: null, EnumerableMap: null, Mapping: null };
            results[test][contract] = BigInt(gas).toLocaleString();
        }
    }

    const table = [
        ['Test', 'HashMap', 'EnumerableMap', 'Mapping']
    ];

    for (let test of ORDER) {
        const result = results[test];
        table.push([DESCRIPTIONS[test], result.HashMap, result.EnumerableMap, result.Mapping]);
    }

    const { markdownTable } = await import('markdown-table');
    const markdown = markdownTable(table);

    console.log(markdown);
});

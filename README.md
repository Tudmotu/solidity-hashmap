# Solidity HashMap
[![npm](https://img.shields.io/npm/v/solidity-hashmap)](https://www.npmjs.com/package/solidity-hashmap)
Solidity famously lacks complex data-structures such as HashMaps, LinkedLists,
etc. This is a true HashMap implementation for Solidity. 

If you've ever wished you could use a simple key/value structure that lets you
iterate over keys, find values, etc, this is for you.

This library is an attempt at implementing a true, efficient HashMap
data-structure in Solidity which includes all the familiar API methods you'd
expect a HashMap to support:
- `.get()`/`.set()`
- `.size()`
- `.keys()`
- `.values()`
- `.entries()`
- `.contains()`

## Disclaimer
This is WIP. It probably contains bugs that would cause "storage slot
collisions". I am looking for people to review the code. If you understand what
"storage slot collision" means and would like to review the code, please contact
me directly or by opening an issue.

## Why do we need a true HashMap?
The `mapping()` data-structure in Solidity is very interesting. It manages to be
very gas-efficient at O(1) while taking up 1 slot per key/value pair. This is
highly efficient, but has a serious drawback: 
Since the `mapping()` storage layout relies on hashing of keys, it is
impossible to enumerate mappings. You cannot iterate over them or infer what
keys they hold. Despite its name, it doesn't provide the same API as you'd
expect of a `Map` object in other languages.

This does not only affect smart-contract authors, but also off-chain data mining
services. The `mapping()` type creates an untraceable storage trie that makes it
much harder to index.

HashMap makes development more natural while allowing off-chain tools to easily
index your smart-contract data.

## Installation
Depending on what toolchain you are using, you will require different
installation methods.

### Foundry
If you are using Foundry, install using Forge:
```console
$ forge install tudmotu/solidity-hashmap
```

### Hardhat
If you are using Hardhat, install using NPM:
```console
$ npm i -D solidity-hashmap
```

## Usage
You must both import the library and extend the HashMap interface with the
`using .. for` syntax.
```solidity
import 'solidity-hashmap/HashMap.sol';

contract Example {
    using HashMapLib for HashMap;

    HashMap hashmap;

    constructor () {
        hashmap.set("key", "value");
        hashmap.get("key");
    }
}
```

## Caveats
Currently this implementation has some notable caveats. Some of these might get
"fixed" and some will not, either due to technical or design limitations.
- Keys and values are `bytes32`. To set/get different values, they must be cast
appropriately
- Some of the methods (e.g. `.entries()`, `.values()`) are very gas-intensive
and are only appropriate in `view` functions called via RPC, where gas is not an
issue
- Keys cannot be an empty `bytes32`
- Only value-types are currently supported: numbers, addresses and strings
shorter than 32 bytes
- `memory` HashMaps are currently not supported
- A HashMap is almost O(1), but not quite. More keys means gas-efficiency might
deteriorate but it will never reach O(n)

## Comparison to alternatives
Two alternatives exist for HashMap:
1. Solidity's builtin `mapping()` data structure
1. OpenZeppelin `EnumerableMapping` implementation

HashMap aims to find a balance between gas/storage efficiency, and developer
experience. While Solidity's `mapping()` is very gas & storage efficient, it is
not developer friendly at all. And while `EnumerableMapping` is more developer
friendly, it is not storage-efficient.

HashMap finds a balance between storage, gas, and developer experience. HashMap
is both efficient in gas & storage, while providing a simple, familiar API.

# Contributions
Contributions are welcome.

Please avoid opening unsolicited PRs without first discussing them in an issue.

If you encounter bugs, please report them in the repository.

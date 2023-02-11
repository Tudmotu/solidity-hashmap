# Solidity HashMap
This is a true HashMap implementation for Solidity. Solidity famously lacks
complex data-structures such as HashMaps, LinkedLists, etc.

This library is an attempt at implementing a true, efficient HashMap
data-structure in Solidity which includes all the familiar API methods you'd
expect a HashMap to support:

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

## Usage
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

## Comparison to alternatives
Two alternatives exist for HashMap:
1. Solidity's builtin `mapping()` data structure
1. OpenZeppelin `EnumerableMapping` implementation

HashMap aims to find a balance between gas & storage efficiency, and Developer
Experience. While Solidity's `mapping()` is very gas & storage efficient, it is
not developer friendly at all. And while `EnumerableMapping` is more developer
friendly, it is not storage-efficient.

HashMap finds a balance between storage, gas, and developer experience. HashMap
is both efficient in gas & storage, while providing a simple, familiar API.

# Contributions
Contributions are welcome.

Please avoid opening unsolicited PRs without first discussing them in an issue.

If you encounter bugs, please report them in the repository.

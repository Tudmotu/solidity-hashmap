pragma solidity ^0.8.18;

import '../src/HashMap.sol';

contract HashMapTest {
    using HashMapLib for HashMap;

    HashMap hashmap;

    // The state of the contract gets reset before each
    // test is run, with the `setUp()` function being called
    // each time after deployment.
    function setUp() public {
        hashmap = HashMap(0);
    }

    function testEntries_returnsListOfAllEntries () public {
        hashmap.set("test", "blabla");
        hashmap.set("test3", "blabla3");
        hashmap.set("test4", "blabla4");
        // TBD
    }

    function testRemoveKey_decreasesSize () public {
        hashmap.set("test3", "blabla");
        hashmap.remove("test3");
        require(hashmap.size() == 0, "Size not decreased after key removal");
    }

    function testRemoveKey_returnsEmptyValue () public {
        hashmap.set("test3", "blabla");
        hashmap.remove("test3");
        require(hashmap.get("test3") == "", "Value of 'test3' is not empty after removal");
    }

    function testKeysWithSameHashBucket_returnsDifferentValues () public {
        hashmap.set("test3", "123test");
        hashmap.set("test4", "test123");
        require(hashmap.get("test3") == "123test", "Value of 'test3' is not 123test");
        require(hashmap.get("test4") == "test123", "Value is of 'test4' not test123");
    }

    function testSetOverrideValues_returnsModifiedValue () public {
        hashmap.set("test", "test123");
        hashmap.set("test", "123test");
        require(hashmap.get("test") == "123test", "Value is not 123test");
    }

    function testGet_returnsValue () public {
        hashmap.set("test", "test123");
        require(hashmap.get("test") == "test123", "Value is not test123");
    }

    function testSizeAfterDuplicateKey_returnsOne () public {
        hashmap.set("test", "test");
        hashmap.set("test", "test2");
        require(hashmap.size() == 1, "Size is not 1");
    }

    function testSizeAfterSet_returnsOne () public {
        hashmap.set("test", "test");
        require(hashmap.size() == 1, "Size is not 1");
    }

    function testSize_returnsZero () public view {
        require(hashmap.size() == 0, "Size is not 0");
    }
}

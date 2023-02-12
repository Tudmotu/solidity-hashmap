pragma solidity ^0.8.18;

import 'forge-std/Test.sol';
import '../src/HashMap.sol';

contract HashMapTest is Test {
    using HashMapLib for HashMap;

    HashMap hashmap;
    HashMap hashmap2;

    // The state of the contract gets reset before each
    // test is run, with the `setUp()` function being called
    // each time after deployment.
    function setUp() public {
        hashmap = HashMap(0);
        hashmap2 = HashMap(0);
    }

    function testContains_returnsTrueIfExists () public {
        hashmap.set("exists", "123");
        require(hashmap.contains("exists") == true, "HashMap does not include initialized key");
    }

    function testIncludes_returnsFalseIfNotExists () public view {
        require(hashmap.contains("non-existing") == false, "HashMap includes non-initialized key");
    }

    function testValues_returnsListOfAllValues () public {
        hashmap.set("test", "blabla");
        hashmap.set("test3", "blabla3");
        hashmap.set("test4", "blabla4");
        bytes32[] memory values = hashmap.values();
        require(values[0] == "blabla", "Value number 0 is not 'blabla'");
        require(values[1] == "blabla3", "Value number 1 is not 'blabla3'");
        require(values[2] == "blabla4", "Value number 2 is not 'blabla4'");
    }

    function testDifferentHashMaps_haveDifferentSizes () public {
        hashmap.set("test", "blabla");
        require(hashmap.size() == 1, "Size is not 1");
        require(hashmap2.size() == 0, "Size is not 0");
    }

    function testKeys_returnsListOfAllKeys () public {
        hashmap.set("test", "blabla");
        hashmap.set("test3", "blabla3");
        hashmap.set("test4", "blabla4");
        bytes32[] memory keys = hashmap.keys();
        require(keys[0] == "test", "Key number 0 is not 'test'");
        require(keys[1] == "test3", "Key number 1 is not 'test3'");
        require(keys[2] == "test4", "Key number 2 is not 'test4'");
    }

    function testSetEmptyKey_revert () public {
        vm.expectRevert("Key cannot be empty bytes32");
        hashmap.set(bytes32(0), "test");
    }

    function testSet_noKeyCollisions_Fuzz (bytes32[] memory keys) public {
        for (uint i = 0; i < keys.length; i++) {
            vm.assume(keys[i] != bytes32(0));
            bytes32 value = keccak256(abi.encode("value", keys[i]));
            hashmap.set(keys[i], value);
        }

        for (uint i = 0; i < keys.length; i++) {
            bytes32 val = hashmap.get(keys[i]);
            bytes32 expected = keccak256(abi.encode("value", keys[i]));
            require(val == expected, "Incorrect value");
        }
    }

    function testEntries_returnsListOfAllEntries () public {
        hashmap.set("test", "blabla");
        hashmap.set("test3", "blabla3");
        hashmap.set("test4", "blabla4");
        KV[] memory entries = hashmap.entries();
        require(entries[0].key == "test", "Entry 0 key is wrong");
        require(entries[0].value == "blabla", "Entry 0 value is wrong");
        require(entries[1].key == "test3", "Entry 1 key is wrong");
        require(entries[1].value == "blabla3", "Entry 1 value is wrong");
        require(entries[2].key == "test4", "Entry 2 key is wrong");
        require(entries[2].value == "blabla4", "Entry 2 value is wrong");
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

    function testSetOverrideValues_returnsModifiedValue (bytes32 value, bytes32 modifiedValue) public {
        hashmap.set("test", value);
        hashmap.set("test", modifiedValue);
        require(hashmap.get("test") == modifiedValue, "Value was not modified");
    }

    function testSetOverrideValues_returnsModifiedValue () public {
        hashmap.set("test", "test123");
        hashmap.set("test", "123test");
        require(hashmap.get("test") == "123test", "Value is not 123test");
    }

    function testGet_returnsValue_Fuzz (bytes32 key, bytes32 value) public {
        hashmap.set(key, value);
        require(hashmap.get(key) == value, "Value is incorrect");
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

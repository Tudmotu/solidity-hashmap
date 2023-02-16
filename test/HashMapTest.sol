pragma solidity ^0.8.18;

import 'forge-std/Test.sol';
import 'openzeppelin-contracts/contracts/utils/Strings.sol';
import '../src/HashMap.sol';

contract HashMapTest is Test {
    HashMap hashmap;
    HashMap hashmap2;

    // The state of the contract gets reset before each
    // test is run, with the `setUp()` function being called
    // each time after deployment.
    function setUp() public {
        hashmap = HashMap(0);
        hashmap2 = HashMap(0);
    }

    function testIterator_iterateAllKeys_Fuzz (bytes32[] memory keys) public {
        vm.assume(keys.length > 0);
        uint uniques;
        for (uint i = 0; i < keys.length; i++) {
            if (keys[i] == bytes32(0)) continue;
            bool duplicate = false;
            for (uint f = i + 1; f < keys.length; f++) {
                if (keys[f] == keys[i]) {
                    duplicate = true;
                    break;
                }
            }
            if (duplicate == false) uniques++;
        }
        for (uint i = 0; i < keys.length; i++) {
            if (keys[i] == bytes32(0)) continue;
            hashmap.set(keys[i], keys[i]);
        }

        uint iteratedCount = 0;
        HashMapIterator memory iterator = hashmap.iterator();

        while (iterator.hasNext()) {
            KV memory currEntry = iterator.next();
            for (uint i = 0; i < keys.length; i++) {
                if (keys[i] == currEntry.key) {
                    require(currEntry.value == keys[i], "Value does not match");
                    iteratedCount++;
                    break;
                }
            }
        }

        require(uniques == iteratedCount, "Some keys are missing from iterator");
    }

    function testIteratorWithKeysInSameBucket_iterateAll () public {
        bytes32 key1 = "test156";
        bytes32 key2 = "test196";
        hashmap.set(key1, "val");
        hashmap.set(key2, "val");
        HashMapIterator memory iterator = hashmap.iterator();
        while (iterator.hasNext()) {
            KV memory entry = iterator.next();
            require(entry.key == key1 || entry.key == key2, "Entry does not match any keys");
        }
    }

    function testIteratorWithTwoKeys_iterateAll () public {
        bytes32 key1 = hex"00000000000000000000000000000000000000000000000000000000007f0002";
        bytes32 key2 = hex"00000000000000000d000000000000000000000000000000000000004f000000";
        hashmap.set(key1, "val");
        hashmap.set(key2, "val");
        HashMapIterator memory iterator = hashmap.iterator();
        while (iterator.hasNext()) {
            KV memory entry = iterator.next();
            require(entry.key == key1 || entry.key == key2, "Entry does not match any keys");
        }
    }

    function testIteratorNext_returnFirstKey () public {
        hashmap.set("testKey", "123");
        KV memory entry = hashmap.iterator().next();
        require(entry.key == "testKey", "Iterator .next returned wrong key");
        require(entry.value == "123", "Iterator .next returned wrong value");
    }

    function testContains_returnsTrueIfExists () public {
        hashmap.set("exists", "123");
        require(hashmap.contains("exists") == true, "HashMap does not include initialized key");
    }

    function testIncludes_returnsFalseIfNotExists () public view {
        require(hashmap.contains("non-existing") == false, "HashMap includes non-initialized key");
    }

    function testValues_returnsListOfAllValues () public {
        hashmap.set("test1", "blabla1");
        hashmap.set("test2", "blabla2");
        hashmap.set("test3", "blabla3");
        bytes32[] memory values = hashmap.values();
        require(values[0] == "blabla2", "Value number 0 is incorrect");
        require(values[1] == "blabla1", "Value number 1 is incorrect");
        require(values[2] == "blabla3", "Value number 2 is incorrect");
    }

    function testDifferentHashMaps_haveDifferentSizes () public {
        hashmap.set("test", "blabla");
        require(hashmap.size() == 1, "Size is not 1");
        require(hashmap2.size() == 0, "Size is not 0");
    }

    function testKeys_returnsListOfAllKeys () public {
        hashmap.set("test1", "blabla");
        hashmap.set("test2", "blabla3");
        hashmap.set("test3", "blabla4");
        bytes32[] memory keys = hashmap.keys();
        require(keys[0] == "test2", "Key number 0 is incorrect");
        require(keys[1] == "test1", "Key number 1 is incorrect");
        require(keys[2] == "test3", "Key number 2 is incorrect");
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
        hashmap.set("test1", "blabla1");
        hashmap.set("test2", "blabla2");
        hashmap.set("test3", "blabla3");
        KV[] memory entries = hashmap.entries();
        require(entries[0].key == "test2", "Entry 0 key is wrong");
        require(entries[0].value == "blabla2", "Entry 0 value is wrong");
        require(entries[1].key == "test1", "Entry 1 key is wrong");
        require(entries[1].value == "blabla1", "Entry 1 value is wrong");
        require(entries[2].key == "test3", "Entry 2 key is wrong");
        require(entries[2].value == "blabla3", "Entry 2 value is wrong");
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
        vm.assume(key != bytes32(0));
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

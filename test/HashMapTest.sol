// SPDX-License-Identifier: Unlicese
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

    function testIterator_iterateAllKeys_Fuzz (bytes32[100] memory keys) public {
        bytes32 free_mem;
        vm.pauseGasMetering();

        vm.assume(keys.length > 0);
        uint uniques;
        assembly ("memory-safe") {
            free_mem := mload(0x40)
        }
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
            assembly ("memory-safe") {
                mstore(0x40, free_mem)
            }
        }

        assembly ("memory-safe") {
            free_mem := mload(0x40)
        }
        for (uint i = 0; i < keys.length; i++) {
            if (keys[i] != bytes32(0)) {
                hashmap.set(keys[i], keys[i]);
            }
            assembly ("memory-safe") {
                mstore(0x40, free_mem)
            }
        }

        uint iteratedCount = 0;

        vm.resumeGasMetering();

        HashMapIterator memory iterator = hashmap.iterator();

        assembly ("memory-safe") {
            free_mem := mload(0x40)
        }
        while (iterator.hasNext()) {
            Entry memory currEntry = iterator.next();
            for (uint i = 0; i < keys.length; i++) {
                if (keys[i] == currEntry.key.asBytes32()) {
                    require(currEntry.value.asBytes32() == keys[i], "Value does not match");
                    iteratedCount++;
                    break;
                }
            }
            assembly ("memory-safe") {
                mstore(0x40, free_mem)
            }
        }

        require(uniques == iteratedCount, "Some keys are missing from iterator");
    }

    function testIteratorWithSomeKeysInSameBucket_iterateAll (bytes32 key0) public {
        vm.assume(key0 != bytes32(0));
        vm.pauseGasMetering();
        hashmap.set(key0, string("val"));
        // These all go in the same bucket: 16373
        bytes32 key1 = "test8590";
        bytes32 key2 = "test16619";
        hashmap.set(key1, string("val"));
        hashmap.set(key2, string("val"));
        vm.resumeGasMetering();

        uint key0Bucket = HashMapLib._bucketNumber(key0);

        bytes32[3] memory expectedKeys;

        if (key0Bucket <= 16373) {
            expectedKeys[0] = key0;
            expectedKeys[1] = key1;
            expectedKeys[2] = key2;
        }
        else {
            expectedKeys[0] = key1;
            expectedKeys[1] = key2;
            expectedKeys[2] = key0;
        }

        HashMapIterator memory iterator = hashmap.iterator();
        assertEq(iterator.next().key.asBytes32(), expectedKeys[0], "Key 0 is incorrect");
        assertEq(iterator.next().key.asBytes32(), expectedKeys[1], "Key 1 is incorrect");
        assertEq(iterator.next().key.asBytes32(), expectedKeys[2], "Key 2 is incorrect");
    }

    function testIteratorWithTwoKeys_iterateAll_Fuzz (bytes32[2] memory keys) public {
        vm.assume(keys[0] != keys[1]);
        vm.assume(keys[0] != bytes32(0));
        vm.assume(keys[1] != bytes32(0));
        vm.pauseGasMetering();
        hashmap.set(keys[0], string("val"));
        hashmap.set(keys[1], string("val"));
        vm.resumeGasMetering();

        HashMapIterator memory iterator = hashmap.iterator();
        uint count;
        while (iterator.hasNext()) {
            bytes32 key = iterator.next().key.asBytes32();
            require(
                key == keys[0] || key == keys[1],
                "Entry does not match any keys"
            );
            count++;
        }

        require(count == 2, "Not all keys found");
    }

    function testIteratorNext_returnFirstKey () public {
        vm.pauseGasMetering();
        hashmap.set(string("testKey"), string("123"));
        vm.resumeGasMetering();
        Entry memory entry = hashmap.iterator().next();
        require(entry.key.asBytes32() == "testKey", "Iterator .next returned wrong key");
        require(entry.value.asBytes32() == "123", "Iterator .next returned wrong value");
    }

    function testContains_returnsTrueIfExists () public {
        hashmap.set(string("exists"), string("123"));
        require(hashmap.contains(string("exists")) == true, "HashMap does not include initialized key");
    }

    function testIncludes_returnsFalseIfNotExists () public view {
        require(hashmap.contains(string("non-existing")) == false, "HashMap includes non-initialized key");
    }

    function testValues_returnsListOfAllValues () public {
        vm.pauseGasMetering();
        hashmap.set(string("test1"), string("blabla1"));
        hashmap.set(string("test2"), string("blabla2"));
        hashmap.set(string("test3"), string("blabla3"));
        vm.resumeGasMetering();
        bytes32[] memory values = hashmap.valuesAsBytes32();
        require(values[0] == "blabla2", "Value number 0 is incorrect");
        require(values[1] == "blabla1", "Value number 1 is incorrect");
        require(values[2] == "blabla3", "Value number 2 is incorrect");
    }

    function testMultipleHashMaps_dontCollide () public {
        bytes32 free_mem;
        vm.pauseGasMetering();
        uint SIZE = 32000;
        assembly ("memory-safe") {
            free_mem := mload(0x40)
        }
        for (uint i = 1; i < SIZE + 1; i++) {
            bytes32 data = bytes32(i);
            hashmap.set(data, data);
            hashmap2.set(data, data);
            assembly ("memory-safe") {
                mstore(0x40, free_mem)
            }
        }
        vm.resumeGasMetering();

        assertEq(hashmap.size(), SIZE, "Hashmap 1 has incorrect size");
        assertEq(hashmap2.size(), SIZE, "Hashmap 2 has incorrect size");
    }

    function testMultipleHashMaps_haveDifferentSizes () public {
        hashmap.set(string("test"), string("blabla"));
        require(hashmap.size() == 1, "Size is not 1");
        require(hashmap2.size() == 0, "Size is not 0");
    }

    function testKeys_returnsListOfAllKeys () public {
        hashmap.set(string("test1"), string("blabla"));
        hashmap.set(string("test2"), string("blabla3"));
        hashmap.set(string("test3"), string("blabla4"));
        bytes32[] memory keys = hashmap.keysAsBytes32();
        require(keys[0] == "test2", "Key number 0 is incorrect");
        require(keys[1] == "test1", "Key number 1 is incorrect");
        require(keys[2] == "test3", "Key number 2 is incorrect");
    }

    function testSetEmptyKey_revert () public {
        vm.expectRevert("Key cannot be empty bytes32");
        hashmap.set(bytes32(0), string("test"));
    }

    function testSet_noKeyCollisions_Fuzz (bytes32[] memory keys) public {
        bytes32 free_mem;
        assembly ("memory-safe") {
            free_mem := mload(0x40)
        }
        for (uint i = 0; i < keys.length; i++) {
            vm.assume(keys[i] != bytes32(0));
            bytes32 value = keccak256(abi.encode("value", keys[i]));
            hashmap.set(keys[i], value);
            assembly ("memory-safe") {
                mstore(0x40, free_mem)
            }
        }

        assembly ("memory-safe") {
            free_mem := mload(0x40)
        }
        for (uint i = 0; i < keys.length; i++) {
            bytes32 val = hashmap.get(keys[i]).asBytes32();
            bytes32 expected = keccak256(abi.encode("value", keys[i]));
            require(val == expected, "Incorrect value");
            assembly ("memory-safe") {
                mstore(0x40, free_mem)
            }
        }
    }

    function testEntries_returnsListOfAllEntries () public {
        hashmap.set(string("test1"), string("blabla1"));
        hashmap.set(string("test2"), string("blabla2"));
        hashmap.set(string("test3"), string("blabla3"));
        Entry[] memory entries = hashmap.entries();
        require(entries[0].key.asBytes32() == "test2", "Entry 0 key is wrong");
        require(entries[0].value.asBytes32() == "blabla2", "Entry 0 value is wrong");
        require(entries[1].key.asBytes32() == "test1", "Entry 1 key is wrong");
        require(entries[1].value.asBytes32() == "blabla1", "Entry 1 value is wrong");
        require(entries[2].key.asBytes32() == "test3", "Entry 2 key is wrong");
        require(entries[2].value.asBytes32() == "blabla3", "Entry 2 value is wrong");
    }

    function testRemoveKeyEmptyMap_revert () public {
        vm.expectRevert("Key does not exist");
        hashmap.remove(string("non-existing"));
    }

    function testRemoveKey_packsValuesInStorage () public {
        // These all go in the same bucket: 16373
        hashmap.set(string("test8590"), string("blabla"));
        hashmap.set(string("test16619"), string("blabla"));
        hashmap.set(string("test16798"), string("blabla"));
        hashmap.set(string("test17756"), string("blabla"));
        hashmap.set(string("test20898"), string("blabla"));

        hashmap.remove(string("test16619"));

        bytes32[] memory keys = hashmap.keysAsBytes32();
        bytes32[4] memory expectedKeys = [
            bytes32("test8590"),
            bytes32("test20898"),
            bytes32("test16798"),
            bytes32("test17756")
        ];

        assertEq(keys[0], expectedKeys[0], 'Key 1 is wrong');
        assertEq(keys[1], expectedKeys[1], 'Key 2 is wrong');
        assertEq(keys[2], expectedKeys[2], 'Key 3 is wrong');
        assertEq(keys[3], expectedKeys[3], 'Key 4 is wrong');
    }

    function testRemoveKey_decreasesSize () public {
        hashmap.set(string("test3"), string("blabla"));
        hashmap.remove(string("test3"));
        require(hashmap.size() == 0, "Size not decreased after key removal");
    }

    function testRemoveKey_returnsEmptyValue () public {
        hashmap.set(string("test3"), string("blabla"));
        hashmap.remove(string("test3"));
        require(hashmap.get(string("test3")).asBytes32() == "", "Value of 'test3' is not empty after removal");
    }

    function testKeysWithSameHashBucket_returnsDifferentValues () public {
        hashmap.set(string("test3"), string("123test"));
        hashmap.set(string("test4"), string("test123"));
        require(hashmap.get(string("test3")).asBytes32() == "123test", "Value of 'test3' is not 123test");
        require(hashmap.get(string("test4")).asBytes32() == "test123", "Value is of 'test4' not test123");
    }

    function testSetOverrideValues_returnsModifiedValue (bytes32 value, bytes32 modifiedValue) public {
        hashmap.set(string("test"), value);
        hashmap.set(string("test"), modifiedValue);
        require(hashmap.get(string("test")).asBytes32() == modifiedValue, "Value was not modified");
    }

    function testSetOverrideValues_returnsModifiedValue () public {
        hashmap.set(string("test"), string("test123"));
        hashmap.set(string("test"), string("123test"));
        require(hashmap.get(string("test")).asBytes32() == "123test", "Value is not 123test");
    }

    function testGet_returnsValue_Fuzz (bytes32 key, bytes32 value) public {
        vm.assume(key != bytes32(0));
        hashmap.set(key, value);
        require(hashmap.get(key).asBytes32() == value, "Value is incorrect");
    }

    function testGet_returnsValue () public {
        hashmap.set(string("test"), string("test123"));
        require(hashmap.get(string("test")).asBytes32() == "test123", "Value is not test123");
    }

    function testSizeAfterDuplicateKey_returnsOne () public {
        hashmap.set(string("test"), string("test"));
        hashmap.set(string("test"), string("test2"));
        require(hashmap.size() == 1, "Size is not 1");
    }

    function testSizeAfterSet_returnsOne () public {
        hashmap.set(string("test"), string("test"));
        require(hashmap.size() == 1, "Size is not 1");
    }

    function testSize_returnsZero () public view {
        require(hashmap.size() == 0, "Size is not 0");
    }
}

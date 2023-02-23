// SPDX-License-Identifier: MIT
// See Solidity forum discussion: https://forum.soliditylang.org/t/adding-hashmap-style-storage-layout-to-solidity/1448
// This HashMap implementation is somewhat similar to how Java's HashMap works.
// For example: https://anmolsehgal.medium.com/java-hashmap-internal-implementation-21597e1efec3

pragma solidity >=0.8.13 <0.9.0;

uint constant BUCKET_COUNT = 65536;

struct HashMap {
    uint initialSize;
}

using HashMapLib for HashMap global;

struct KV {
    bytes32 key;
    bytes32 value;
}

library HashMapLib {
    function bytesHash (bytes32 key) private pure returns (uint hash) {
        hash = uint(keccak256(abi.encode(key)));
    }

    function soliditySlot (HashMap storage map) private pure returns (uint slot) {
        assembly {
            slot := map.slot
        }
    }

    function baseSlot (HashMap storage map) private pure returns (uint slot) {
        slot = uint(keccak256(abi.encodePacked(soliditySlot(map))));
    }

    function size (HashMap storage map) internal view returns (uint mapSize) {
        uint slot = baseSlot(map);
        assembly {
            mapSize := sload(slot)
        }
    }

    function _bucket (HashMap storage map, bytes32 key) private pure returns (uint slot) {
        return baseSlot(map) + 1 + (bytesHash(key) % BUCKET_COUNT);
    }

    function _findKey (HashMap storage map, bytes32 key) private view returns (uint keySlot, bytes32 currKey, uint bucketSlot) {
        bucketSlot = _bucket(map, key);

        assembly {
            keySlot := add(bucketSlot, BUCKET_COUNT)
            currKey := sload(keySlot)
        }

        while (currKey != "" && currKey != key) {
            assembly {
                keySlot := add(keySlot, mul(BUCKET_COUNT, 2))
                currKey := sload(keySlot)
            }
        }
    }

    function _increaseSize (HashMap storage map, uint bucketSlot) private {
        uint slot = baseSlot(map);
        assembly {
            sstore(slot, add(sload(slot), 1))
            sstore(bucketSlot, add(sload(bucketSlot), 1))
        }
    } 

    function _decreaseSize (HashMap storage map, uint bucketSlot) private {
        uint slot = baseSlot(map);
        assembly {
            sstore(slot, sub(sload(slot), 1))
            sstore(bucketSlot, sub(sload(bucketSlot), 1))
        }
    } 

    function _bucketSize (HashMap storage map, uint bucket) internal view returns (uint bucketSize) {
        uint slot = baseSlot(map);
        assembly {
            let bucketSlot := add(add(slot, 1), bucket)
            bucketSize := sload(bucketSlot)
        }
    }

    function _getKeyInBucketByIndex (HashMap storage map, uint bucket, uint index) private view returns (bytes32 key, uint keySlot) {
        uint firstKeySlot = baseSlot(map) + 1 + bucket + BUCKET_COUNT;
        keySlot = firstKeySlot + (2 * BUCKET_COUNT) * index;

        assembly {
            key := sload(keySlot)
        } 
    }

    function _getValueInBucketByIndex (HashMap storage map, uint bucket, uint index) private view returns (bytes32 value, uint valueSlot) {
        uint firstValueSlot = baseSlot(map) + 1 + bucket + 2 * BUCKET_COUNT;
        valueSlot = firstValueSlot + (2 * BUCKET_COUNT) * index;

        assembly {
            value := sload(valueSlot)
        } 
    }

    function _getKeyValueInBucketByIndex (HashMap storage map, uint bucket, uint index) internal view returns (KV memory kv) {
        (bytes32 key, uint keySlot) = _getKeyInBucketByIndex(map, bucket, index);

        if (key == "") return KV("", "");

        uint valueSlot = keySlot + BUCKET_COUNT;
        bytes32 value;
        assembly {
            value := sload(valueSlot)
        }

        kv = KV(key, value);
    }

    function values (HashMap storage map) internal view returns (bytes32[] memory valueList) {
        uint mapSize = size(map);
        uint valueCount = 0;
        valueList = new bytes32[](mapSize);

        for (uint currBucket = 0; currBucket < BUCKET_COUNT; currBucket++) {
            uint bucketSize = _bucketSize(map, currBucket);

            for (uint bucketIndex = 0; bucketIndex < bucketSize; bucketIndex++) {
                (bytes32 value,) = _getValueInBucketByIndex(map, currBucket, bucketIndex);
                if (value == "") continue;
                valueList[valueCount] = value;
                valueCount++;
            }

            if (valueCount == mapSize) break;
        }

        return valueList;
    }

    function keys (HashMap storage map) internal view returns (bytes32[] memory keyList) {
        uint mapSize = size(map);
        uint keyCount = 0;
        keyList = new bytes32[](mapSize);

        for (uint currBucket = 0; currBucket < BUCKET_COUNT; currBucket++) {
            uint bucketSize = _bucketSize(map, currBucket);
            uint bucketIndex = 0;
            uint bucketKeyCount = 0;

            while (bucketKeyCount < bucketSize) {
                (bytes32 key,) = _getKeyInBucketByIndex(map, currBucket, bucketIndex);
                bucketIndex++;
                if (key == "") continue;
                keyList[keyCount] = key;
                keyCount++;
                bucketKeyCount++;
            }

            if (keyCount == mapSize) break;
        }

        return keyList;
    }

    function entries (HashMap storage map) internal view returns (KV[] memory) {
        uint mapSize = size(map);
        uint kvCount = 0;
        KV[] memory pairs = new KV[](mapSize);

        for (uint currBucket = 0; currBucket < BUCKET_COUNT; currBucket++) {
            uint bucketSize = _bucketSize(map, currBucket);

            for (uint bucketIndex = 0; bucketIndex < bucketSize; bucketIndex++) {
                KV memory kv = _getKeyValueInBucketByIndex(map, currBucket, bucketIndex);
                if (kv.key == "") continue;
                pairs[kvCount] = kv;
                kvCount++;
            }

            if (kvCount == mapSize) break;
        }

        return pairs;
    } 

    function set (HashMap storage map, bytes32 key, bytes32 value) internal {
        require(key != bytes32(0), "Key cannot be empty bytes32");
        (uint keySlot, bytes32 currKey, uint bucketSlot) = _findKey(map, key);

        assembly {
            sstore(keySlot, key)
            sstore(add(keySlot, BUCKET_COUNT), value)
        }

        if (currKey != key) {
            _increaseSize(map, bucketSlot);
        }
    }

    function get (HashMap storage map, bytes32 key) internal view returns (bytes32 value) {
        (uint keySlot,,) = _findKey(map, key);
        assembly {
            value := sload(add(keySlot, BUCKET_COUNT))
        }
    }

    function remove (HashMap storage map, bytes32 key) internal {
        (uint keySlot, bytes32 currKey, uint bucketSlot) = _findKey(map, key);
        require(currKey != bytes32(0), "Key does not exist");

        uint bucketSize;
        assembly {
            bucketSize := sload(bucketSlot)
        }
        uint lastKeySlot = bucketSlot + BUCKET_COUNT + (bucketSize - 1) * 2 * BUCKET_COUNT;
        uint lastValueSlot = lastKeySlot + BUCKET_COUNT;

        assembly {
            let valueSlot := add(keySlot, BUCKET_COUNT)
            sstore(keySlot, sload(lastKeySlot))
            sstore(valueSlot, sload(lastValueSlot))
            sstore(lastKeySlot, "")
            sstore(lastValueSlot, "")
        }
        _decreaseSize(map, bucketSlot);
    } 

    function contains (HashMap storage map, bytes32 key) internal view returns (bool exists){
        (, bytes32 currKey,) = _findKey(map, key);
        exists = currKey != "";
    }

    function iterator (HashMap storage map) internal pure returns (HashMapIterator memory iter) {
        Cursor memory cursor = Cursor(0, 0);
        iter = HashMapIterator(soliditySlot(map), 0, cursor);
    }
}

struct Cursor {
    uint bucket;
    uint position;
}
struct HashMapIterator {
    uint mapSlot;
    uint current;
    Cursor cursor;
}
using HashMapIteratorLib for HashMapIterator global;

library HashMapIteratorLib {
    function _getMap (HashMapIterator memory self) private pure returns (HashMap storage map) {
        uint mapSlot = self.mapSlot;
        assembly {
            map.slot := mapSlot
        }
    }

    function next (HashMapIterator memory self) internal view returns (KV memory entry) {
        HashMap storage map = _getMap(self);

        while (self.cursor.bucket < BUCKET_COUNT) {
            uint bucketSize = map._bucketSize(self.cursor.bucket);

            if (bucketSize == 0) {
                self.cursor.bucket += 1;
            }
            else if (bucketSize <= self.cursor.position) {
                self.cursor.position -= bucketSize;
            }
            else {
                self.current++;
                return map._getKeyValueInBucketByIndex(
                    self.cursor.bucket,
                    self.cursor.position
                );
            }
        }
    }

    function hasNext (HashMapIterator memory self) internal view returns (bool result) {
        return _getMap(self).size() > self.current;
    }
}

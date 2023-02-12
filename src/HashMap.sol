// SPDX-License-Identifier: MIT
// See Solidity forum discussion: https://forum.soliditylang.org/t/adding-hashmap-style-storage-layout-to-solidity/1448
// This HashMap implementation is somewhat similar to how Java's HashMap works.
// For example: https://anmolsehgal.medium.com/java-hashmap-internal-implementation-21597e1efec3

pragma solidity >=0.7.0 <0.9.0;

struct HashMap {
    uint initialSize;
}

struct KV {
    bytes32 key;
    bytes32 value;
}

library HashMapLib {
    uint constant BUCKET_COUNT = 256;

    function bytesHash (bytes32 key) private pure returns (uint hash) {
        hash = uint(keccak256(abi.encode(key)));
    }

    function baseSlot (HashMap storage map) private pure returns (uint slot) {
        assembly {
            slot := map.slot
        }
    }

    function size (HashMap storage map) internal view returns (uint mapSize) {
        assembly {
            mapSize := sload(map.slot)
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
        assembly {
            sstore(map.slot, add(sload(map.slot), 1))
            sstore(bucketSlot, add(sload(bucketSlot), 1))
        }
    } 

    function _decreaseSize (HashMap storage map, uint bucketSlot) private {
        assembly {
            sstore(map.slot, sub(sload(map.slot), 1))
            sstore(bucketSlot, sub(sload(bucketSlot), 1))
        }
    } 

    function _bucketSize (HashMap storage map, uint bucket) private view returns (uint bucketSize) {
        assembly {
            let bucketSlot := add(add(map.slot, 1), bucket)
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

    function _getKeyValueInBucketByIndex (HashMap storage map, uint bucket, uint index) private view returns (KV memory kv) {
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

            for (uint bucketIndex = 0; bucketIndex < bucketSize; bucketIndex++) {
                (bytes32 key,) = _getKeyInBucketByIndex(map, currBucket, bucketIndex);
                if (key == "") continue;
                keyList[keyCount] = key;
                keyCount++;
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
        (uint keySlot, , uint bucketSlot) = _findKey(map, key);
        assembly {
            let valueSlot := add(keySlot, BUCKET_COUNT)
            sstore(keySlot, "")
            sstore(valueSlot, "")
        }
        _decreaseSize(map, bucketSlot);
    } 

    function contains (HashMap storage map, bytes32 key) internal view returns (bool exists){
        (, bytes32 currKey,) = _findKey(map, key);
        exists = currKey != "";
    }
}

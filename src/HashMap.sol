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
    bytes32 private constant EMPTY_BYTES32 = bytes32(0);

    function bytesHash (bytes32 key) private pure returns (uint hash) {
        hash = uint(keccak256(abi.encode(key)));
    }

    function soliditySlot (HashMap storage map) private pure returns (uint slot) {
        assembly {
            slot := map.slot
        }
    }

    function baseSlot (HashMap storage map) private pure returns (uint slot) {
        slot = bytesHash(bytes32(soliditySlot(map)));
    }

    function size (HashMap storage map) internal view returns (uint mapSize) {
        bytes32 free_mem;
        HashMapIterator memory iter = iterator(map);

        assembly ("memory-safe") {
            free_mem := mload(0x40)
        }
        while (iter.hasNext()) {
            iter.next();
            mapSize++;
            assembly ("memory-safe") {
                mstore(0x40, free_mem)
            }
        }
    }

    function _bucketNumber (bytes32 key) public pure returns (uint slot) {
        return bytesHash(key) % BUCKET_COUNT;
    }

    function _bucket (HashMap storage map, bytes32 key) public pure returns (uint slot) {
        return baseSlot(map) + 1 + _bucketNumber(key);
    }

    function _findKey (HashMap storage map, bytes32 key) private view returns (uint keySlot, bytes32 currKey, uint bucketSlot) {
        bytes32 free_mem;
        bucketSlot = _bucket(map, key);

        assembly {
            keySlot := add(bucketSlot, BUCKET_COUNT)
            currKey := sload(keySlot)
        }

        assembly ("memory-safe") {
            free_mem := mload(0x40)
        }

        while (currKey != "" && currKey != key) {
            assembly {
                keySlot := add(keySlot, mul(BUCKET_COUNT, 2))
                currKey := sload(keySlot)
            }
            assembly ("memory-safe") {
                mstore(0x40, free_mem)
            }
        }
    }

    function _bucketSize (HashMap storage map, uint bucket) internal view returns (uint bucketSize) {
        uint slot = baseSlot(map);
        assembly {
            let bucketSlot := add(add(slot, 1), bucket)
            bucketSize := sload(bucketSlot)
        }
    }

    function _getKeyInBucketByIndex (HashMap storage map, uint bucket, uint index) internal view returns (bytes32 key, uint keySlot) {
        uint firstKeySlot = baseSlot(map) + 1 + bucket + BUCKET_COUNT;
        keySlot = firstKeySlot + (2 * BUCKET_COUNT) * index;

        assembly {
            key := sload(keySlot)
        }
    }

    function _getValueInBucketByIndex (HashMap storage map, uint bucket, uint index) internal view returns (bytes32 value, uint valueSlot) {
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

    function values (HashMap storage map) internal view returns (bytes32[] memory list) {
        HashMapIterator memory iter = iterator(map);
        bytes memory bytea;
        uint count;
        while (iter.hasNext()) {
            KV memory entry = iter.next();
            bytea = bytes.concat(bytea, entry.value);
            count++;
        }

        list = new bytes32[](count);
        for (uint i = 0; i < count; i++) {
            uint begin = i * 32;
            uint end = begin + 31;
            bytes memory element = new bytes(32);
            for (uint x = 0; x <= end - begin ; x++) {
                element[x] = bytea[x + begin];
            }
            list[i] = bytes32(element);
        }
    }

    function keys (HashMap storage map) internal view returns (bytes32[] memory list) {
        HashMapIterator memory iter = iterator(map);
        bytes memory bytea;
        uint count;
        while (iter.hasNext()) {
            KV memory entry = iter.next();
            bytea = bytes.concat(bytea, entry.key);
            count++;
        }

        list = new bytes32[](count);
        for (uint i = 0; i < count; i++) {
            uint begin = i * 32;
            uint end = begin + 31;
            bytes memory element = new bytes(32);
            for (uint x = 0; x <= end - begin ; x++) {
                element[x] = bytea[x + begin];
            }
            list[i] = bytes32(element);
        }
    }

    function entries (HashMap storage map) internal view returns (KV[] memory list) {
        HashMapIterator memory iter = iterator(map);
        bytes memory bytea;
        uint count;
        while (iter.hasNext()) {
            KV memory entry = iter.next();
            bytea = bytes.concat(bytes.concat(bytea, entry.key), entry.value);
            count++;
        }

        list = new KV[](count);
        for (uint i = 0; i < count; i++) {
            uint begin = i * 64;
            bytes memory key = new bytes(32);
            bytes memory value = new bytes(32);
            for (uint x = 0; x <= 63 ; x++) {
                if (x < 32) {
                    key[x] = bytea[x + begin];
                }
                else {
                    value[x - 32] = bytea[x + begin];
                }
            }
            list[i] = KV(bytes32(key), bytes32(value));
        }
    }

    function set (HashMap storage map, bytes32 key, bytes32 value) internal {
        require(key != EMPTY_BYTES32, "Key cannot be empty bytes32");
        (uint keySlot,,) = _findKey(map, key);

        assembly {
            sstore(keySlot, key)
            sstore(add(keySlot, BUCKET_COUNT), value)
        }
    }

    function get (HashMap storage map, bytes32 key) internal view returns (bytes32 value) {
        (uint keySlot,,) = _findKey(map, key);
        assembly {
            value := sload(add(keySlot, BUCKET_COUNT))
        }
    }

    function remove (HashMap storage map, bytes32 key) internal {
        bytes32 free_mem;
        (uint keySlot, bytes32 currKey, uint bucketSlot) = _findKey(map, key);
        require(currKey != EMPTY_BYTES32, "Key does not exist");

        uint bucket = bucketSlot - baseSlot(map) - 1;
        uint bucketIndex = 0;
        (bytes32 lastKey, uint lastKeySlot) = _getKeyInBucketByIndex(map, bucket, bucketIndex);

        assembly ("memory-safe") {
            free_mem := mload(0x40)
        }
        while (lastKey != EMPTY_BYTES32) {
            bucketIndex++;
            (lastKey, lastKeySlot) = _getKeyInBucketByIndex(map, bucket, bucketIndex);
            assembly ("memory-safe") {
                mstore(0x40, free_mem)
            }
        }

        lastKeySlot -= 2 * BUCKET_COUNT;
        uint lastValueSlot = lastKeySlot + BUCKET_COUNT;

        assembly {
            let valueSlot := add(keySlot, BUCKET_COUNT)
            sstore(keySlot, sload(lastKeySlot))
            sstore(valueSlot, sload(lastValueSlot))
            sstore(lastKeySlot, "")
            sstore(lastValueSlot, "")
        }
    }

    function contains (HashMap storage map, bytes32 key) internal view returns (bool exists){
        (, bytes32 currKey,) = _findKey(map, key);
        exists = currKey != "";
    }

    function iterator (HashMap storage map) internal pure returns (HashMapIterator memory iter) {
        Cursor memory cursor;
        Scan memory latestScan;
        KV memory latestEntry;
        iter = HashMapIterator(soliditySlot(map), cursor, latestScan, latestEntry);
    }
}

struct Cursor {
    uint bucket;
    uint position;
}

struct Scan {
    bool found;
    uint bucket;
    uint position;
    bytes32 key;
    uint keySlot;
}

struct HashMapIterator {
    uint mapSlot;
    Cursor cursor;
    Scan latestScan;
    KV latestEntry;
}

using HashMapIteratorLib for HashMapIterator global;

library HashMapIteratorLib {
    bytes32 private constant EMPTY_BYTES32 = bytes32(0);

    function _getMap (HashMapIterator memory self) private pure returns (HashMap storage map) {
        uint mapSlot = self.mapSlot;
        assembly {
            map.slot := mapSlot
        }
    }

    function scan (
        HashMapIterator memory self
    ) internal view returns (Scan memory) {
        bytes32 free_mem1;
        HashMap storage map = _getMap(self);

        uint currBucket = self.cursor.bucket;
        uint currPosition = self.cursor.position;

        assembly ("memory-safe") {
            free_mem1 := mload(0x40)
        }
        while (currBucket < BUCKET_COUNT) {
            (bytes32 nextKey, uint keySlot) = map._getKeyInBucketByIndex(
                currBucket,
                currPosition
            );

            if (nextKey != EMPTY_BYTES32) {
                self.latestScan = Scan(true, currBucket, currPosition, nextKey, keySlot);
                return self.latestScan;
            }

            currBucket++;
            currPosition = 0;
            assembly ("memory-safe") {
                mstore(0x40, free_mem1)
            }
        }

        Scan memory res;
        return res;
    }

    function next (HashMapIterator memory self) internal view returns (KV memory entry) {
        if (self.latestScan.bucket <= self.cursor.bucket &&
                self.latestScan.position <= self.cursor.position ) {
            scan(self);
        }

        if (self.latestScan.found) {
            self.cursor.bucket = self.latestScan.bucket;
            self.cursor.position = self.latestScan.position + 1;

            bytes32 nextValue;
            self.latestEntry.key = self.latestScan.key;
            uint keySlot = self.latestScan.keySlot;

            assembly {
                nextValue := sload(add(keySlot, BUCKET_COUNT))
            }

            self.latestEntry.value = nextValue;

            return self.latestEntry;
        }
    }

    function hasNext (HashMapIterator memory self) internal view returns (bool found) {
        return scan(self).found;
    }
}

pragma solidity ^0.8.18;

import 'forge-std/Test.sol';
import 'openzeppelin-contracts/contracts/utils/structs/EnumerableMap.sol';

contract EnumerableMapGasTest is Test {
    using EnumerableMap for EnumerableMap.Bytes32ToBytes32Map;

    EnumerableMap.Bytes32ToBytes32Map map;

    function write10kKeys () private {
        for (uint i = 0; i < 10000; i++) {
            map.set(keccak256(abi.encodePacked(i)), keccak256("test"));
        }
    }

    function test_findKeySingleKeyMap () public {
        vm.pauseGasMetering();
        map.set("test", "test");
        vm.resumeGasMetering();

        map.contains("test");
    }

    function test_writeSingleKey () public {
        map.set("test", "test");
    }

    function test_remove10kKeys () public {
        vm.pauseGasMetering();
        write10kKeys();
        vm.resumeGasMetering();

        for (uint i = 0; i < 10000; i++) {
            map.remove(keccak256(abi.encodePacked(i)));
        }
    }

    function test_findKeyIn10kMap () public {
        vm.pauseGasMetering();
        write10kKeys();
        vm.resumeGasMetering();

        map.contains(keccak256(abi.encodePacked(uint(9999))));
    }

    function test_iterate10kKeys () public {
        vm.pauseGasMetering();
        write10kKeys();
        vm.resumeGasMetering();

        for (uint i = 0; i < map.length(); i++) {
            map.get(keccak256(abi.encodePacked(i)));
        }
    }

    function test_write100kKeys () public {
        for (uint i = 0; i < 100000; i++) {
            map.set(keccak256(abi.encodePacked(i)), keccak256("test"));
        }
    }

    function test_write10kKeys () public {
        write10kKeys();
    }
}

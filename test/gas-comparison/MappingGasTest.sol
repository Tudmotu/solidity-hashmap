pragma solidity ^0.8.18;

import 'forge-std/Test.sol';
import '../../src/HashMap.sol';

contract MappingGasTest is Test {
    mapping(bytes32 => bytes32) map;

    function write10kKeys () private {
        for (uint i = 0; i < 10000; i++) {
            map[keccak256(abi.encodePacked(i))] = keccak256("test");
        }
    }

    function test_findKeySingleKeyMap () public {
        vm.pauseGasMetering();
        map["test"] = "test";
        vm.resumeGasMetering();

        map["test"] != 0;
    }

    function test_writeSingleKey () public {
        map["test"] = "test";
    }

    function test_remove10kKeys () public {
        vm.pauseGasMetering();
        write10kKeys();
        vm.resumeGasMetering();

        for (uint i = 0; i < 10000; i++) {
            delete map[keccak256(abi.encodePacked(i))];
        }
    }

    function test_findKeyIn10kMap () public {
        vm.pauseGasMetering();
        write10kKeys();
        vm.resumeGasMetering();

        map[keccak256(abi.encodePacked(uint(9999)))] != 0;
    }

    function test_iterate10kKeys () public {
        vm.pauseGasMetering();
        write10kKeys();
        vm.resumeGasMetering();

        for (uint i = 0; i < 10000; i++) {
            map[keccak256(abi.encodePacked(i))];
        }
    }

    function test_write100kKeys () public {
        for (uint i = 0; i < 100000; i++) {
            map[keccak256(abi.encodePacked(i))] = keccak256("test");
        }
    }

    function test_write10kKeys () public {
        write10kKeys();
    }
}

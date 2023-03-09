pragma solidity ^0.8.18;

import 'forge-std/Test.sol';
import '../../src/HashMap.sol';

contract MappingGasTest is Test {
    mapping(bytes32 => bytes32) map;

    function measureGas (uint startGas) private {
        console2.log("Gas used:", startGas - gasleft());
    }

    function write10kKeys () private {
        for (uint i = 0; i < 10000; i++) {
            map[keccak256(abi.encodePacked(i))] = keccak256("test");
        }
    }

    function test_findKeySingleKeyMap () public {
        map["test"] = "test";

        uint start = gasleft();
        map["test"] != 0;
        measureGas(start);
    }

    function test_writeSingleKey () public {
        uint start = gasleft();
        map["test"] = "test";
        measureGas(start);
    }

    function test_remove10kKeys () public {
        write10kKeys();

        uint start = gasleft();
        for (uint i = 0; i < 10000; i++) {
            delete map[keccak256(abi.encodePacked(i))];
        }
        measureGas(start);
    }

    function test_findKeyIn10kMap () public {
        write10kKeys();

        uint start = gasleft();
        map[keccak256(abi.encodePacked(uint(9999)))] != 0;
        measureGas(start);
    }

    function test_iterate10kKeys () public {
        write10kKeys();

        uint start = gasleft();
        for (uint i = 0; i < 10000; i++) {
            map[keccak256(abi.encodePacked(i))];
        }
        measureGas(start);
    }

    function test_write100kKeys () public {
        uint start = gasleft();
        for (uint i = 0; i < 100000; i++) {
            map[keccak256(abi.encodePacked(i))] = keccak256("test");
        }
        measureGas(start);
    }

    function test_write10kKeys () public {
        uint start = gasleft();
        write10kKeys();
        measureGas(start);
    }
}

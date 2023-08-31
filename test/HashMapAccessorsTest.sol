// SPDX-License-Identifier: Unlicese
pragma solidity >=0.8.13 <0.9.0;

import 'forge-std/Test.sol';
import '../src/HashMap.sol';

contract HashMapAccessorsTest is Test {
    HashMap hashmap;

    function test_bytes32SettersGetters (
        bytes32[4] memory keys,
        address addr,
        bool b,
        uint unum,
        int num
    ) public {
        for (uint i = 0; i < keys.length; i++) vm.assume(keys[i] != bytes32(0));
        vm.assume(addr != address(0));
        vm.assume(unum != 0);
        vm.assume(num != 0);
        hashmap.set(keys[0], addr);
        assertEq(hashmap.get(keys[0]).asAddress(), addr);
        hashmap.set(keys[1], b);
        assertEq(hashmap.get(keys[1]).asBool(), b);
        hashmap.set(keys[2], unum);
        assertEq(hashmap.get(keys[2]).asUint(), unum);
        hashmap.set(keys[3], num);
        assertEq(hashmap.get(keys[3]).asInt(), num);
    }

    function test_addressSettersGetters (
        address[5] memory keys,
        bytes32 b32,
        address addr,
        bool b,
        uint unum,
        int num
    ) public {
        for (uint i = 0; i < keys.length; i++) vm.assume(keys[i] != address(0));
        vm.assume(b32 != bytes32(0));
        vm.assume(addr != address(0));
        vm.assume(unum != 0);
        vm.assume(num != 0);
        hashmap.set(keys[0], b32);
        assertEq(hashmap.get(keys[0]).asBytes32(), b32);
        hashmap.set(keys[1], addr);
        assertEq(hashmap.get(keys[1]).asAddress(), addr);
        hashmap.set(keys[2], b);
        assertEq(hashmap.get(keys[2]).asBool(), b);
        hashmap.set(keys[3], unum);
        assertEq(hashmap.get(keys[3]).asUint(), unum);
        hashmap.set(keys[4], num);
        assertEq(hashmap.get(keys[4]).asInt(), num);
    }

    function test_boolSettersGetters (
        bool[5] memory keys,
        bytes32 b32,
        address addr,
        bool b,
        uint unum,
        int num
    ) public {
        vm.assume(b32 != bytes32(0));
        vm.assume(addr != address(0));
        vm.assume(unum != 0);
        vm.assume(num != 0);
        hashmap.set(keys[0], b32);
        assertEq(hashmap.get(keys[0]).asBytes32(), b32);
        hashmap.set(keys[1], addr);
        assertEq(hashmap.get(keys[1]).asAddress(), addr);
        hashmap.set(keys[2], b);
        assertEq(hashmap.get(keys[2]).asBool(), b);
        hashmap.set(keys[3], unum);
        assertEq(hashmap.get(keys[3]).asUint(), unum);
        hashmap.set(keys[4], num);
        assertEq(hashmap.get(keys[4]).asInt(), num);
    }

    function test_uintSettersGetters (
        uint[5] memory keys,
        bytes32 b32,
        address addr,
        bool b,
        uint unum,
        int num
    ) public {
        for (uint i = 0; i < keys.length; i++) vm.assume(keys[i] != 0);
        vm.assume(b32 != bytes32(0));
        vm.assume(addr != address(0));
        vm.assume(unum != 0);
        vm.assume(num != 0);
        hashmap.set(keys[0], b32);
        assertEq(hashmap.get(keys[0]).asBytes32(), b32);
        hashmap.set(keys[1], addr);
        assertEq(hashmap.get(keys[1]).asAddress(), addr);
        hashmap.set(keys[2], b);
        assertEq(hashmap.get(keys[2]).asBool(), b);
        hashmap.set(keys[3], unum);
        assertEq(hashmap.get(keys[3]).asUint(), unum);
        hashmap.set(keys[4], num);
        assertEq(hashmap.get(keys[4]).asInt(), num);
    }

    function test_intSettersGetters (
        int[5] memory keys,
        bytes32 b32,
        address addr,
        bool b,
        uint unum,
        int num
    ) public {
        for (uint i = 0; i < keys.length; i++) vm.assume(keys[i] != 0);
        vm.assume(b32 != bytes32(0));
        vm.assume(addr != address(0));
        vm.assume(unum != 0);
        vm.assume(num != 0);
        hashmap.set(keys[0], b32);
        assertEq(hashmap.get(keys[0]).asBytes32(), b32);
        hashmap.set(keys[1], addr);
        assertEq(hashmap.get(keys[1]).asAddress(), addr);
        hashmap.set(keys[2], b);
        assertEq(hashmap.get(keys[2]).asBool(), b);
        hashmap.set(keys[3], unum);
        assertEq(hashmap.get(keys[3]).asUint(), unum);
        hashmap.set(keys[4], num);
        assertEq(hashmap.get(keys[4]).asInt(), num);
    }

    function test_stringSettersGetters (
        uint32[20] memory uintKeys,
        bytes32 b32,
        address addr,
        bool b,
        uint unum,
        int num
    ) public {
        string[] memory keys = new string[](uintKeys.length);
        for (uint i = 0; i < keys.length; i++) {
            vm.assume(uintKeys[i] > 0);
            keys[i] = vm.toString(uintKeys[i]);
        }
        for (uint i = 0; i < keys.length; i++) {
            vm.assume(bytes(keys[i]).length > 0);
            vm.assume(bytes(keys[i]).length <= 32);
        }
        vm.assume(b32 != bytes32(0));
        vm.assume(addr != address(0));
        vm.assume(unum != 0);
        vm.assume(num != 0);
        hashmap.set(keys[0], b32);
        assertEq(hashmap.get(keys[0]).asBytes32(), b32);
        hashmap.set(keys[1], addr);
        assertEq(hashmap.get(keys[1]).asAddress(), addr);
        hashmap.set(keys[2], b);
        assertEq(hashmap.get(keys[2]).asBool(), b);
        hashmap.set(keys[3], unum);
        assertEq(hashmap.get(keys[3]).asUint(), unum);
        hashmap.set(keys[4], num);
        assertEq(hashmap.get(keys[4]).asInt(), num);
    }

    function test_keysAsBytes32 (
        bytes32[20] memory elements
    ) public {
        for (uint i = 0; i < elements.length; i++) {
            vm.assume(elements[i] != bytes32(0));

            for (uint j = 0; j < elements.length; j++) {
                vm.assume(i == j || elements[i] != elements[j]);
            }
        }

        for (uint i = 0; i < elements.length; i++) {
            hashmap.set(elements[i], i);
        }

        bytes32[] memory keys = hashmap.keysAsBytes32();
        assertEq(keys.length, elements.length);

        for (uint i = 0; i < elements.length; i++) {
            bool exists;
            for (uint x = 0; x < elements.length; x++) {
                exists = elements[i] == keys[x];
                if (exists) break;
            }
            assertTrue(exists, string.concat(
                'Element ', vm.toString(elements[i]), ' not found in keys'
            ));
        }
    }

    function test_keysAsAddress (
        address[20] memory elements
    ) public {
        for (uint i = 0; i < elements.length; i++) {
            vm.assume(elements[i] != address(0));

            for (uint j = 0; j < elements.length; j++) {
                vm.assume(i == j || elements[i] != elements[j]);
            }
        }

        for (uint i = 0; i < elements.length; i++) {
            hashmap.set(elements[i], i);
        }

        address[] memory keys = hashmap.keysAsAddress();
        assertEq(keys.length, elements.length);

        for (uint i = 0; i < elements.length; i++) {
            bool exists;
            for (uint x = 0; x < elements.length; x++) {
                exists = elements[i] == keys[x];
                if (exists) break;
            }
            assertTrue(exists, string.concat(
                'Element ', vm.toString(elements[i]), ' not found in keys'
            ));
        }
    }

    function test_keysAsBool () public {
        hashmap.set(true, uint(1));
        hashmap.set(false, uint(2));
        bool[] memory keys = hashmap.keysAsBool();
        assertEq(keys.length, 2);
        assertTrue(keys[0] == true || keys[0] == false);
        assertTrue(keys[1] == true || keys[1] == false);
        assertTrue(keys[0] != keys[1]);
    }

    function test_keysAsUint (
        uint[20] memory elements
    ) public {
        for (uint i = 0; i < elements.length; i++) {
            vm.assume(elements[i] != 0);

            for (uint j = 0; j < elements.length; j++) {
                vm.assume(i == j || elements[i] != elements[j]);
            }
        }

        for (uint i = 0; i < elements.length; i++) {
            hashmap.set(elements[i], i);
        }

        uint[] memory keys = hashmap.keysAsUint();
        assertEq(keys.length, elements.length);

        for (uint i = 0; i < elements.length; i++) {
            bool exists;
            for (uint x = 0; x < elements.length; x++) {
                exists = elements[i] == keys[x];
                if (exists) break;
            }
            assertTrue(exists, string.concat(
                'Element ', vm.toString(elements[i]), ' not found in keys'
            ));
        }
    }

    function test_keysAsInt (
        int[20] memory elements
    ) public {
        for (uint i = 0; i < elements.length; i++) {
            vm.assume(elements[i] != 0);

            for (uint j = 0; j < elements.length; j++) {
                vm.assume(i == j || elements[i] != elements[j]);
            }
        }

        for (uint i = 0; i < elements.length; i++) {
            hashmap.set(elements[i], i);
        }

        int[] memory keys = hashmap.keysAsInt();
        assertEq(keys.length, elements.length);

        for (uint i = 0; i < elements.length; i++) {
            bool exists;
            for (uint x = 0; x < elements.length; x++) {
                exists = elements[i] == keys[x];
                if (exists) break;
            }
            assertTrue(exists, string.concat(
                'Element ', vm.toString(elements[i]), ' not found in keys'
            ));
        }
    }

    function test_keysAsString (
        uint32[10] memory uintElements
    ) public {
        string[] memory elements = new string[](uintElements.length);
        for (uint i = 0; i < elements.length; i++) {
            elements[i] = vm.toString(uintElements[i]);
        }
        for (uint i = 0; i < elements.length; i++) {
            vm.assume(bytes(elements[i]).length > 0);
            vm.assume(bytes(elements[i]).length <= 32);

            for (uint j = 0; j < elements.length; j++) {
                vm.assume(
                    i == j ||
                    keccak256(bytes(elements[i])) != keccak256(bytes(elements[j]))
                );
            }
        }

        for (uint i = 0; i < elements.length; i++) {
            hashmap.set(elements[i], i);
        }

        string[] memory keys = hashmap.keysAsString();
        assertEq(keys.length, elements.length);

        for (uint i = 0; i < elements.length; i++) {
            bool exists;
            for (uint x = 0; x < elements.length; x++) {
                exists = keccak256(bytes(elements[i])) == keccak256(bytes(keys[x]));
                if (exists) break;
            }
            assertTrue(exists, string.concat(
                'Element ', elements[i], ' not found in keys'
            ));
        }
    }

    function test_valuesAsBytes32 (
        bytes32[20] memory elements
    ) public {
        for (uint i = 0; i < elements.length; i++) {
            vm.assume(elements[i] != bytes32(0));

            for (uint j = 0; j < elements.length; j++) {
                vm.assume(i == j || elements[i] != elements[j]);
            }
        }

        for (uint i = 0; i < elements.length; i++) {
            hashmap.set(i + 1, elements[i]);
        }

        bytes32[] memory values = hashmap.valuesAsBytes32();
        assertEq(values.length, elements.length);

        for (uint i = 0; i < elements.length; i++) {
            bool exists;
            for (uint x = 0; x < elements.length; x++) {
                exists = elements[i] == values[x];
                if (exists) break;
            }
            assertTrue(exists, string.concat(
                'Element ', vm.toString(elements[i]), ' not found in keys'
            ));
        }
    }

    function test_valuesAsAddress (
        address[20] memory elements
    ) public {
        for (uint i = 0; i < elements.length; i++) {
            vm.assume(elements[i] != address(0));

            for (uint j = 0; j < elements.length; j++) {
                vm.assume(i == j || elements[i] != elements[j]);
            }
        }

        for (uint i = 0; i < elements.length; i++) {
            hashmap.set(i + 1, elements[i]);
        }

        address[] memory values = hashmap.valuesAsAddress();
        assertEq(values.length, elements.length);

        for (uint i = 0; i < elements.length; i++) {
            bool exists;
            for (uint x = 0; x < elements.length; x++) {
                exists = elements[i] == values[x];
                if (exists) break;
            }
            assertTrue(exists, string.concat(
                'Element ', vm.toString(elements[i]), ' not found in keys'
            ));
        }
    }

    function test_valuesAsBool () public {
        hashmap.set(uint(1), true);
        hashmap.set(uint(2), false);
        bool[] memory values = hashmap.valuesAsBool();
        assertEq(values.length, 2);
        assertTrue(values[0] == true || values[0] == false);
        assertTrue(values[1] == true || values[1] == false);
        assertTrue(values[0] != values[1]);
    }

    function test_valuesAsUint (
        uint[20] memory elements
    ) public {
        for (uint i = 0; i < elements.length; i++) {
            vm.assume(elements[i] != 0);

            for (uint j = 0; j < elements.length; j++) {
                vm.assume(i == j || elements[i] != elements[j]);
            }
        }

        for (uint i = 0; i < elements.length; i++) {
            hashmap.set(i + 1, elements[i]);
        }

        uint[] memory values = hashmap.valuesAsUint();
        assertEq(values.length, elements.length);

        for (uint i = 0; i < elements.length; i++) {
            bool exists;
            for (uint x = 0; x < elements.length; x++) {
                exists = elements[i] == values[x];
                if (exists) break;
            }
            assertTrue(exists, string.concat(
                'Element ', vm.toString(elements[i]), ' not found in keys'
            ));
        }
    }

    function test_valuesAsInt (
        int[20] memory elements
    ) public {
        for (uint i = 0; i < elements.length; i++) {
            vm.assume(elements[i] != 0);

            for (uint j = 0; j < elements.length; j++) {
                vm.assume(i == j || elements[i] != elements[j]);
            }
        }

        for (uint i = 0; i < elements.length; i++) {
            hashmap.set(i + 1, elements[i]);
        }

        int[] memory values = hashmap.valuesAsInt();
        assertEq(values.length, elements.length);

        for (uint i = 0; i < elements.length; i++) {
            bool exists;
            for (uint x = 0; x < elements.length; x++) {
                exists = elements[i] == values[x];
                if (exists) break;
            }
            assertTrue(exists, string.concat(
                'Element ', vm.toString(elements[i]), ' not found in keys'
            ));
        }
    }

    function test_valuesAsString (
        uint32[10] memory uintElements
    ) public {
        string[] memory elements = new string[](uintElements.length);
        for (uint i = 0; i < elements.length; i++) {
            elements[i] = vm.toString(uintElements[i]);
        }
        for (uint i = 0; i < elements.length; i++) {
            vm.assume(bytes(elements[i]).length > 0);
            vm.assume(bytes(elements[i]).length <= 32);

            for (uint j = 0; j < elements.length; j++) {
                vm.assume(
                    i == j ||
                    keccak256(bytes(elements[i])) != keccak256(bytes(elements[j]))
                );
            }
        }

        for (uint i = 0; i < elements.length; i++) {
            hashmap.set(i + 1, elements[i]);
        }

        string[] memory values = hashmap.valuesAsString();
        assertEq(values.length, elements.length);

        for (uint i = 0; i < elements.length; i++) {
            bool exists;
            for (uint x = 0; x < elements.length; x++) {
                exists = keccak256(bytes(elements[i])) == keccak256(bytes(values[x]));
                if (exists) break;
            }
            assertTrue(exists, string.concat(
                'Element ', elements[i], ' not found in keys'
            ));
        }
    }

    function test_containsFunctions (
        bytes32 b32,
        address addr,
        bool b,
        uint unum,
        int num,
        string memory str
    ) public {
        vm.assume(b32 != bytes32(0));
        vm.assume(addr != address(0));
        vm.assume(unum != 0);
        vm.assume(num != 0);
        vm.assume(bytes(str).length > 0);
        vm.assume(bytes(str).length <= 32);

        hashmap.set(b32, string("test"));
        hashmap.set(addr, string("test"));
        hashmap.set(b, string("test"));
        hashmap.set(unum, string("test"));
        hashmap.set(num, string("test"));
        hashmap.set(str, string("test"));

        assertTrue(hashmap.contains(b32));
        assertTrue(hashmap.contains(addr));
        assertTrue(hashmap.contains(b));
        assertTrue(hashmap.contains(unum));
        assertTrue(hashmap.contains(num));
        assertTrue(hashmap.contains(str));
    }

    function test_removeFunctions (
        bytes32 b32,
        address addr,
        bool b,
        uint unum,
        int num,
        uint32 _str
    ) public {
        vm.assume(b32 != bytes32(0));
        vm.assume(addr != address(0));
        vm.assume(unum != 0);
        vm.assume(num != 0);
        string memory str = vm.toString(_str);

        hashmap.set(b32, string("test"));
        hashmap.remove(b32);
        assertEq(hashmap.get(b32).asUint(), 0);

        hashmap.set(addr, string("test"));
        hashmap.remove(addr);
        assertEq(hashmap.get(addr).asUint(), 0);

        hashmap.set(b, string("test"));
        hashmap.remove(b);
        assertEq(hashmap.get(b).asUint(), 0);

        hashmap.set(unum, string("test"));
        hashmap.remove(unum);
        assertEq(hashmap.get(unum).asUint(), 0);

        hashmap.set(num, string("test"));
        hashmap.remove(num);
        assertEq(hashmap.get(num).asUint(), 0);

        hashmap.set(str, string("test"));
        hashmap.remove(str);
        assertEq(hashmap.get(str).asUint(), 0);
    }
}

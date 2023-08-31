// SPDX-License-Identifier: Unlicese
pragma solidity ^0.8.13;

import { HashMap, HashMapIterator, Entry, Element } from './HashMap.sol';

library ElementLib {
    function asBytes32 (Element self) internal pure returns (bytes32) {
        return Element.unwrap(self);
    }

    function asBool (Element self) internal pure returns (bool) {
        return int(uint(Element.unwrap(self))) > 0 ? true : false;
    }

    function asAddress (Element self) internal pure returns (address) {
        return address(bytes20(Element.unwrap(self)));
    }

    function asUint (Element self) internal pure returns (uint) {
        return uint(Element.unwrap(self));
    }

    function asInt (Element self) internal pure returns (int) {
        return int(uint(Element.unwrap(self)));
    }

    function asBytes (Element self) internal pure returns (bytes memory) {
        return abi.encode(Element.unwrap(self));
    }

    function asString (Element self) internal pure returns (string memory) {
        bytes memory bytesElement = abi.encode(Element.unwrap(self));
        bytes memory res;
        for (uint i = 0; i < bytesElement.length; i++) {
            if (bytesElement[i] == hex"00") continue;
            res = bytes.concat(res, bytesElement[i]);
        }
        return string(res);
    }
}

library HashMapAccessors {
    // bytes32 setters
    function set (HashMap storage self, bytes32 k, address v) internal {
        self.set(k, addressToB32(v));
    }

    function set (HashMap storage self, bytes32 k, bool v) internal {
        self.set(k, boolToB32(v));
    }

    function set (HashMap storage self, bytes32 k, uint v) internal {
        self.set(k, bytes32(v));
    }

    function set (HashMap storage self, bytes32 k, int v) internal {
        self.set(k, uint(v));
    }

    function set (HashMap storage self, bytes32 k, string memory v) internal {
        require(bytes(v).length <= 32);
        self.set(k, bytes32(bytes(v)));
    }

    // address setters
    function set (HashMap storage self, address k, bytes32 v) internal {
        self.set(addressToB32(k), v);
    }

    function set (HashMap storage self, address k, address v) internal {
        self.set(addressToB32(k), addressToB32(v));
    }

    function set (HashMap storage self, address k, bool v) internal {
        self.set(addressToB32(k), boolToB32(v));
    }

    function set (HashMap storage self, address k, uint v) internal {
        self.set(addressToB32(k), bytes32(v));
    }

    function set (HashMap storage self, address k, int v) internal {
        self.set(addressToB32(k), uint(v));
    }

    function set (HashMap storage self, address k, string memory v) internal {
        require(bytes(v).length <= 32);
        self.set(addressToB32(k), bytes32(bytes(v)));
    }

    // bool setters
    function set (HashMap storage self, bool k, bytes32 v) internal {
        self.set(boolToB32(k), v);
    }

    function set (HashMap storage self, bool k, bool v) internal {
        self.set(boolToB32(k), boolToB32(v));
    }

    function set (HashMap storage self, bool k, address v) internal {
        self.set(boolToB32(k), addressToB32(v));
    }

    function set (HashMap storage self, bool k, uint v) internal {
        self.set(boolToB32(k), bytes32(v));
    }

    function set (HashMap storage self, bool k, int v) internal {
        self.set(boolToB32(k), uint(v));
    }

    function set (HashMap storage self, bool k, string memory v) internal {
        require(bytes(v).length <= 32);
        self.set(boolToB32(k), bytes32(bytes(v)));
    }

    // uint setters
    function set (HashMap storage self, uint k, bytes32 v) internal {
        self.set(bytes32(k), v);
    }

    function set (HashMap storage self, uint k, bool v) internal {
        self.set(bytes32(k), boolToB32(v));
    }

    function set (HashMap storage self, uint k, address v) internal {
        self.set(bytes32(k), addressToB32(v));
    }

    function set (HashMap storage self, uint k, uint v) internal {
        self.set(bytes32(k), bytes32(v));
    }

    function set (HashMap storage self, uint k, int v) internal {
        self.set(bytes32(k), uint(v));
    }

    function set (HashMap storage self, uint k, string memory v) internal {
        require(bytes(v).length <= 32);
        self.set(bytes32(k), bytes32(bytes(v)));
    }

    // int setters
    function set (HashMap storage self, int k, bytes32 v) internal {
        self.set(uint(k), v);
    }

    function set (HashMap storage self, int k, bool v) internal {
        self.set(uint(k), boolToB32(v));
    }

    function set (HashMap storage self, int k, address v) internal {
        self.set(uint(k), addressToB32(v));
    }

    function set (HashMap storage self, int k, uint v) internal {
        self.set(uint(k), bytes32(v));
    }

    function set (HashMap storage self, int k, int v) internal {
        self.set(uint(k), uint(v));
    }

    function set (HashMap storage self, int k, string memory v) internal {
        require(bytes(v).length <= 32);
        self.set(uint(k), bytes32(bytes(v)));
    }

    // string setters
    function set (HashMap storage self, string memory k, bytes32 v) internal {
        require(bytes(k).length <= 32);
        self.set(bytes32(bytes(k)), v);
    }

    function set (HashMap storage self, string memory k, bool v) internal {
        require(bytes(k).length <= 32);
        self.set(bytes32(bytes(k)), boolToB32(v));
    }

    function set (HashMap storage self, string memory k, address v) internal {
        require(bytes(k).length <= 32);
        self.set(bytes32(bytes(k)), addressToB32(v));
    }

    function set (HashMap storage self, string memory k, uint v) internal {
        require(bytes(k).length <= 32);
        self.set(bytes32(bytes(k)), bytes32(v));
    }

    function set (HashMap storage self, string memory k, int v) internal {
        require(bytes(k).length <= 32);
        self.set(bytes32(bytes(k)), uint(v));
    }

    function set (HashMap storage self, string memory k, string memory v) internal {
        require(bytes(k).length <= 32);
        self.set(bytes32(bytes(k)), bytes32(bytes(v)));
    }

    // getters
    function get (HashMap storage self, address k) internal view returns (Element) {
        return self.get(addressToB32(k));
    }

    function get (HashMap storage self, bool k) internal view returns (Element) {
        return self.get(boolToB32(k));
    }

    function get (HashMap storage self, uint k) internal view returns (Element) {
        return self.get(bytes32(k));
    }

    function get (HashMap storage self, int k) internal view returns (Element) {
        return self.get(bytes32(uint(k)));
    }

    function get (HashMap storage self, string memory k) internal view returns (Element) {
        return self.get(bytes32(bytes(k)));
    }

    // values getters
    function valuesAsBytes32 (
        HashMap storage self
    ) internal view returns (bytes32[] memory values) {
        Element[] memory bvalues = self.values();
        values = new bytes32[](bvalues.length);
        for (uint i = 0; i < values.length; i++) {
            values[i] = bvalues[i].asBytes32();
        }
    }

    function valuesAsAddress (
        HashMap storage self
    ) internal view returns (address[] memory values) {
        Element[] memory bvalues = self.values();
        values = new address[](bvalues.length);
        for (uint i = 0; i < values.length; i++) {
            values[i] = bvalues[i].asAddress();
        }
    }

    function valuesAsBool (
        HashMap storage self
    ) internal view returns (bool[] memory values) {
        Element[] memory bvalues = self.values();
        values = new bool[](bvalues.length);
        for (uint i = 0; i < values.length; i++) {
            values[i] = bvalues[i].asBool();
        }
    }

    function valuesAsUint (
        HashMap storage self
    ) internal view returns (uint[] memory values) {
        Element[] memory bvalues = self.values();
        values = new uint[](bvalues.length);
        for (uint i = 0; i < values.length; i++) {
            values[i] = bvalues[i].asUint();
        }
    }

    function valuesAsInt (
        HashMap storage self
    ) internal view returns (int[] memory values) {
        Element[] memory bvalues = self.values();
        values = new int[](bvalues.length);
        for (uint i = 0; i < values.length; i++) {
            values[i] = bvalues[i].asInt();
        }
    }

    function valuesAsString (
        HashMap storage self
    ) internal view returns (string[] memory values) {
        Element[] memory bvalues = self.values();
        values = new string[](bvalues.length);
        for (uint i = 0; i < values.length; i++) {
            values[i] = bvalues[i].asString();
        }
    }

    // keys getters
    function keysAsBytes32 (
        HashMap storage self
    ) internal view returns (bytes32[] memory keys) {
        Element[] memory bKeys = self.keys();
        keys = new bytes32[](bKeys.length);
        for (uint i = 0; i < keys.length; i++) {
            keys[i] = bKeys[i].asBytes32();
        }
    }

    function keysAsAddress (
        HashMap storage self
    ) internal view returns (address[] memory keys) {
        Element[] memory bKeys = self.keys();
        keys = new address[](bKeys.length);
        for (uint i = 0; i < keys.length; i++) {
            keys[i] = bKeys[i].asAddress();
        }
    }

    function keysAsBool (
        HashMap storage self
    ) internal view returns (bool[] memory keys) {
        Element[] memory bKeys = self.keys();
        keys = new bool[](bKeys.length);
        for (uint i = 0; i < keys.length; i++) {
            keys[i] = bKeys[i].asBool();
        }
    }

    function keysAsUint (
        HashMap storage self
    ) internal view returns (uint[] memory keys) {
        Element[] memory bKeys = self.keys();
        keys = new uint[](bKeys.length);
        for (uint i = 0; i < keys.length; i++) {
            keys[i] = bKeys[i].asUint();
        }
    }

    function keysAsInt (
        HashMap storage self
    ) internal view returns (int[] memory keys) {
        Element[] memory bKeys = self.keys();
        keys = new int[](bKeys.length);
        for (uint i = 0; i < keys.length; i++) {
            keys[i] = bKeys[i].asInt();
        }
    }

    function keysAsBytes (
        HashMap storage self
    ) internal view returns (bytes[] memory keys) {
        Element[] memory bKeys = self.keys();
        keys = new bytes[](bKeys.length);
        for (uint i = 0; i < keys.length; i++) {
            keys[i] = bKeys[i].asBytes();
        }
    }

    function keysAsString (
        HashMap storage self
    ) internal view returns (string[] memory keys) {
        Element[] memory bKeys = self.keys();
        keys = new string[](bKeys.length);
        for (uint i = 0; i < keys.length; i++) {
            keys[i] = bKeys[i].asString();
        }
    }

    // removers
    function remove (HashMap storage self, address k) internal {
        self.remove(addressToB32(k));
    }

    function remove (HashMap storage self, bool k) internal {
        self.remove(boolToB32(k));
    }

    function remove (HashMap storage self, uint k) internal {
        self.remove(bytes32(k));
    }

    function remove (HashMap storage self, int k) internal {
        self.remove(bytes32(uint(k)));
    }

    function remove (HashMap storage self, string memory k) internal {
        self.remove(bytes32(bytes(k)));
    }

    // finders
    function contains (
        HashMap storage self,
        address k
    ) internal view returns (bool) {
        return self.contains(addressToB32(k));
    }

    function contains (
        HashMap storage self,
        bool k
    ) internal view returns (bool) {
        return self.contains(boolToB32(k));
    }

    function contains (
        HashMap storage self,
        uint k
    ) internal view returns (bool) {
        return self.contains(bytes32(k));
    }

    function contains (
        HashMap storage self,
        int k
    ) internal view returns (bool) {
        return self.contains(bytes32(uint(k)));
    }

    function contains (
        HashMap storage self,
        string memory k
    ) internal view returns (bool) {
        return self.contains(bytes32(bytes(k)));
    }
}

function boolToB32 (bool x) pure returns (bytes32 res) {
    int out = x ? int(1) : int(-1);
    assembly {
       res := out
    }
}

function b32ToBool (bytes32 x) pure returns (bool res) {
    int out;
    assembly {
        out := x
    }
    res = out == -1 ? false : true;
}

function addressToB32 (address x) pure returns (bytes32) {
    return bytes32(bytes20(x));
}

function b32ToAddress (bytes32 x) pure returns (address) {
    return address(bytes20(x));
}

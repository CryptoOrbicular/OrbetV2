// SPDX-License-Identifier: 0BSD

pragma solidity ^0.8.1;

contract Test {
    
    function createBet(bytes memory createBetData) public returns (bool) {
        
    }
    
    function checkBet(bytes memory data) public view returns (bool) {
        bytes1 operator;
        uint40 expiry;
        address contractAddr;
        bytes memory callData;
        bytes memory compareData;
        (operator, expiry, contractAddr, callData, compareData) = parseCriteriaHex(data);
        (bool success, bytes memory returnData) = address(contractAddr).staticcall(callData);
        require(success, "call failed");
        bool testBet;
        if (operator == 0x00) assembly { testBet := or(eq(mload(add(returnData, 0x20)), mload(add(compareData, 0x20))), lt(mload(add(returnData, 0x20)), mload(add(compareData, 0x20)))) }
        if (operator == 0x01) assembly { testBet := lt(mload(add(returnData, 0x20)), mload(add(compareData, 0x20))) }
        if (operator == 0x02) assembly { testBet := eq(mload(add(returnData, 0x20)), mload(add(compareData, 0x20))) }
        if (operator == 0x03) assembly { testBet := not(eq(mload(add(returnData, 0x20)), mload(add(compareData, 0x20)))) }
        if (operator == 0x04) assembly { testBet := or(eq(mload(add(returnData, 0x20)), mload(add(compareData, 0x20))), gt(mload(add(returnData, 0x20)), mload(add(compareData, 0x20)))) }
        if (operator == 0x05) assembly { testBet := gt(mload(add(returnData, 0x20)), mload(add(compareData, 0x20))) }
        return testBet;
    }
    
    function parseCriteriaHex(bytes memory data) public pure returns (bytes1, uint40, address, bytes memory, bytes memory) {
        bytes1 operator;
        uint40 expiry;
        bytes20 contractAddr;
        bytes32 callDataLengthBytes;
        assembly {
            operator := mload(add(data, 0x20))
            expiry := mload(add(data, 0x21))
            contractAddr := mload(add(data, 0x26))
            callDataLengthBytes := mload(add(data, 0x3A))
        }
        uint callDataLength = uint(callDataLengthBytes);
        bytes memory callData = new bytes(callDataLength);
        for (uint i = 0; i < callDataLength; i += 32) {
            assembly {
                let ptr := add(callData, add(i, 0x20))
                mstore(ptr, mload(add(data, add(i, 0x5A))))
            }
        }
        bytes memory compareData = new bytes(data.length - callDataLength - 58);
        for (uint i = 0; i < data.length; i += 32) {
            assembly {
                let ptr := add(compareData, add(i, 0x20))
                mstore(ptr, mload(add(data, add(i, add(callDataLength, 0x5A)))))
            }
        }
        return (operator, expiry, address(contractAddr), callData, compareData);
    }
    
}
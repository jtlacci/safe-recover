// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "safe-contracts/proxies/GnosisSafeProxyFactory.sol";
import "safe-contracts/proxies/GnosisSafeProxy.sol";
import "safe-contracts/GnosisSafe.sol";


contract SafeFarmer {
    GnosisSafeProxyFactory proxyFactory130 = GnosisSafeProxyFactory(0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2);
    address safeSingleton130 = 0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552;
    address safeSingleton130L2 = 0xfb1bffC9d739B8D520DaF37dF666da4C687191EA;
    address fallbackHandler130 = 0x017062a1dE2FE6b99BE3d9d37841FeD19F573804;

    function encodeCallData(address[] calldata owners, bytes calldata data) public view returns (bytes memory){
        return abi.encodeCall(GnosisSafe.setup,
            (owners, // owners
            1, // threshold
            address(0), // delegate call to
            data, // data
            fallbackHandler130, // fallback handler
            address(0), // payment token,
            0, // payment
            payable(0) // payment reciever
        ));
    }

    function createSafes(uint256 iterations) public {

        address [] memory owners = new address[](1);
        owners[0] = address(msg.sender);

        bytes memory data = this.encodeCallData(owners, bytes(" "));

        for (uint256 i = 0; i < iterations; i++) {
            proxyFactory130.createProxy(safeSingleton130L2, data);
        }

    }

    function createSafesTest(uint256 iterations) public returns(address[] memory){

        address [] memory owners = new address[](1);
        owners[0] = address(msg.sender);

        bytes memory data = this.encodeCallData(owners, bytes(" "));

        address[] memory returnData = new address[](iterations);

        for (uint256 i = 0; i < iterations; i++) {
            GnosisSafeProxy proxy = proxyFactory130.createProxy(safeSingleton130L2, data);
            returnData[i] = address(proxy);
        }

        return returnData;
    }

}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "safe-contracts/proxies/GnosisSafeProxyFactory.sol";
import "safe-contracts/proxies/GnosisSafeProxy.sol";
import "safe-contracts/GnosisSafe.sol";
import "../src/SafeFarmer.sol";

contract ContractTest is Test {
    GnosisSafeProxyFactory proxyFactory130 = GnosisSafeProxyFactory(0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2);
    address safeSingleton130 = 0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552;
    address safeSingleton130L2 = 0xfb1bffC9d739B8D520DaF37dF666da4C687191EA;
    address fallbackHandler130 = 0x017062a1dE2FE6b99BE3d9d37841FeD19F573804;

    // fire block creation: 14503404
    // fire safe 0x369C67771288D87Cdc794bd5f1211914B7FDC6db
    // fire contract nonce 14525

    // ballpark etherscan proxy creation page: https://etherscan.io/txs?a=0xa6b71e26c5e0845f74c812102ca7114b6a896ab2&ps=100&p=181
    //
    // not between 15200 - 17200

    function setUp() public {}

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

    function testGetNonce() public{
        console.log('proxyFactoryNonce', vm.getNonce(address(proxyFactory130)));
    }

    function testFarmerTargetNonce() public {

        address firstTargetSafe = 0x369C67771288D87Cdc794bd5f1211914B7FDC6db; // factory nonce 2740
        address secondTarget = 0x369C67771288D87Cdc794bd5f1211914B7FDC6db; // factory nonce 14525

        SafeFarmer safeFarmer = new SafeFarmer();

        uint64 targetNonce = 14525;

        vm.setNonce(address(proxyFactory130), targetNonce);
        console.log('proxyFactoryNonceTarget', targetNonce);
        
        address[] memory proxies = safeFarmer.createSafesTest(1);

        GnosisSafe safe = GnosisSafe(payable(proxies[0]));
        // address matches target
        assertEq(secondTarget, address(proxies[0]));
        // owner set correctly
        assertTrue(safe.isOwner(address(this)));
    }

    function testSearch() public {
        address target = 0x369C67771288D87Cdc794bd5f1211914B7FDC6db;

        SafeFarmer safeFarmer = new SafeFarmer();

        bool found = false;
        
        uint256 initialNonce = 14500;
        uint256 iterations = 100;

        vm.setNonce(address(proxyFactory130), 14500);
        console.log('proxyFactoryNonceStart', initialNonce);

        address[] memory proxies = safeFarmer.createSafesTest(iterations);

        for (uint256 i = 0; i < proxies.length; i++) {
           
           if(target == address(proxies[i])){
                console.log('proxyFactoryNonce',initialNonce + i);
                found = true;
           }
        }

        console.log('proxyFactoryNonceEnd', vm.getNonce(address(proxyFactory130)));
        assertTrue(found);
    }

    // function testTargetNonce() public {

    //     address firstTargetSafe = 0x369C67771288D87Cdc794bd5f1211914B7FDC6db; // factory nonce 2740
    //     address secondTarget = 0x369C67771288D87Cdc794bd5f1211914B7FDC6db; // factory nonce 14525

    //     address [] memory owners = new address[](1);
    //     owners[0] = address(this);

    //     bytes memory data = this.encodeCallData(owners, bytes(" "));

    //     vm.setNonce(address(proxyFactory130), 14525);
    //     GnosisSafeProxy proxy = proxyFactory130.createProxy(safeSingleton130L2, data);

    //     GnosisSafe safe = GnosisSafe(payable(proxy));
    //     // address matches target
    //     assertEq(secondTarget, address(proxy));
    //     // owner set correctly
    //     assertTrue(safe.isOwner(address(this)));
    // }

    // function testSearch() public {
        

    //     address target = 0x369C67771288D87Cdc794bd5f1211914B7FDC6db;

    //     bool found = false;
    //     vm.setNonce(address(proxyFactory130), 14200);
    //     console.log('proxyFactoryNonceStart', vm.getNonce(address(proxyFactory130)));

    //     for (uint256 i = 0; i < 1000; i++) {
    //        GnosisSafeProxy proxy = proxyFactory130.createProxy(safeSingleton130, " ");
    //        if(target == address(proxy)){
    //             console.log('proxyFactoryNonce', vm.getNonce(address(proxyFactory130)));
    //             found = true;
    //        }
    //     }

    //     console.log('proxyFactoryNonceEnd', vm.getNonce(address(proxyFactory130)));
    //     assertTrue(found);
    // }
}

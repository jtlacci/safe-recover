// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/SafeFarmer.sol";


contract SafeFarm is Script {
    address proxyFactory130 = 0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2;
    // SafeFarmer Address
    address safeFarmerAddress = 0xaa4699DD69458042dE0e90d3fFf78e4e9ca53d13;

    // ITERATIONS 
    uint256 numCalls = 10;
    uint256 numSafes = 60;

    function run() external {
        vm.startBroadcast();
        console.log('proxyFactoryNonceStart', vm.getNonce(proxyFactory130));

        SafeFarmer safeFarmer = SafeFarmer(safeFarmerAddress);

        if(safeFarmerAddress == address(0)){
            safeFarmer = new SafeFarmer();
            console.log('SafeFarmerDeployed ', address(safeFarmer));
        }
        
        for (uint256 i = 0; i < numCalls; i++) {
            safeFarmer.createSafes(numSafes);
        }
        
        console.log('proxyFactoryNonceEnd', vm.getNonce(proxyFactory130));
        vm.stopBroadcast();
    }
}
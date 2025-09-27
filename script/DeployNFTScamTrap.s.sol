// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/NFTScamTrap.sol";
import "../src/MockSuspiciousNFT.sol";
import "../src/NFTScamResponse.sol";

contract DeployNFTScamTrap is Script {
    function run() external {
        vm.startBroadcast();
        
        MockSuspiciousNFT nftContract = new MockSuspiciousNFT();
        console.log("MockSuspiciousNFT deployed at:", address(nftContract));
        
        NFTScamTrap trap = new NFTScamTrap(address(nftContract));
        console.log("NFTScamTrap deployed at:", address(trap));
        
        NFTScamResponse response = new NFTScamResponse();
        console.log("NFTScamResponse deployed at:", address(response));
        
        vm.stopBroadcast();
    }
}

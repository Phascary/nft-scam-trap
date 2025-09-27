// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/NFTScamTrap.sol";
import "../src/MockSuspiciousNFT.sol";

contract NFTScamTrapTest is Test {
    NFTScamTrap trap;
    MockSuspiciousNFT nftContract;
    
    function setUp() public {
        nftContract = new MockSuspiciousNFT();
        trap = new NFTScamTrap(address(nftContract));
    }
    
    function test_CollectDetectsScamNFTs() public view {
        bytes memory data = trap.collect();
        (uint256 totalNFTs, uint256 suspiciousCount,) = abi.decode(data, (uint256, uint256, uint256));
        
        assertEq(totalNFTs, 3); // 3 NFTs minted in constructor
        assertEq(suspiciousCount, 3); // All 3 contain scam keywords
    }
    
    function test_ShouldRespondWhenNewScamNFTMinted() public {
        bytes memory prevData = trap.collect();
        
        // Mint new scam NFT
        nftContract.mintSuspiciousNFT("Amazing Free NFT", "Get your free gift now!");
        
        bytes memory currData = trap.collect();
        
        bytes[] memory data = new bytes[](2);
        data[0] = currData;
        data[1] = prevData;
        
        (bool shouldRespond, bytes memory responseData) = trap.shouldRespond(data);
        assertTrue(shouldRespond);
        
        (uint256 totalNFTs, uint256 suspiciousCount,,) = abi.decode(responseData, (uint256, uint256, uint256, uint256));
        assertEq(totalNFTs, 4);
        assertEq(suspiciousCount, 4);
    }
    
    function test_NoResponseForLegitimateNFT() public {
        bytes memory prevData = trap.collect();
        
        // Mint legitimate NFT without scam keywords
        nftContract.mintSuspiciousNFT("Digital Art Piece", "Beautiful handcrafted artwork");
        
        bytes memory currData = trap.collect();
        
        bytes[] memory data = new bytes[](2);
        data[0] = currData;
        data[1] = prevData;
        
        (bool shouldRespond,) = trap.shouldRespond(data);
        assertFalse(shouldRespond);
    }
}

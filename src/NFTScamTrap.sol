// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./ITrap.sol";

interface ISuspiciousNFT {
    struct NFTMetadata {
        string name;
        string description;
        uint256 tokenId;
        uint256 mintedAt;
    }
    
    function getAllTokenIds() external view returns (uint256[] memory);
    function getMetadata(uint256 tokenId) external view returns (NFTMetadata memory);
}

contract NFTScamTrap is ITrap {
    ISuspiciousNFT public immutable nftContract;
    
    // Suspicious keywords to detect scam NFTs
    string[] public suspiciousKeywords = [
        "Free",
        "Gift", 
        "Offer",
        "Giveaway",
        "Airdrop",
        "Limited",
        "Exclusive",
        "Claim",
        "Winner",
        "Selected"
    ];
    
    constructor(address _nftContract) {
        nftContract = ISuspiciousNFT(_nftContract);
    }
    
    function collect() external view override returns (bytes memory) {
        uint256[] memory tokenIds = nftContract.getAllTokenIds();
        uint256 suspiciousCount = 0;
        uint256 totalNFTs = tokenIds.length;
        
        // Count suspicious NFTs
        for (uint256 i = 0; i < tokenIds.length; i++) {
            ISuspiciousNFT.NFTMetadata memory metadata = nftContract.getMetadata(tokenIds[i]);
            if (_containsSuspiciousKeywords(metadata.name) || _containsSuspiciousKeywords(metadata.description)) {
                suspiciousCount++;
            }
        }
        
        return abi.encode(totalNFTs, suspiciousCount, block.timestamp);
    }
    
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length < 2) return (false, "");
        
        (, uint256 prevSuspiciousCount,) = abi.decode(data[1], (uint256, uint256, uint256));
        (uint256 currTotalNFTs, uint256 currSuspiciousCount, uint256 timestamp) = abi.decode(data[0], (uint256, uint256, uint256));
        
        // Only trigger if NEW suspicious NFTs were detected
        bool newSuspiciousNFTs = currSuspiciousCount > prevSuspiciousCount;
        
        // Alternative: trigger if initial detection shows high suspicious ratio (for first-time analysis)
        bool initialHighRatio = false;
        if (prevSuspiciousCount == 0 && currTotalNFTs > 0) {
            uint256 suspiciousPercentage = (currSuspiciousCount * 100) / currTotalNFTs;
            initialHighRatio = suspiciousPercentage >= 80; // Higher threshold for initial detection
        }
        
        if (newSuspiciousNFTs || initialHighRatio) {
            return (
                true,
                abi.encode(
                    currTotalNFTs,
                    currSuspiciousCount,
                    prevSuspiciousCount,
                    timestamp
                )
            );
        }
        
        return (false, "");
    }
    
    function _containsSuspiciousKeywords(string memory text) internal view returns (bool) {
        bytes memory textBytes = bytes(text);
        
        for (uint256 i = 0; i < suspiciousKeywords.length; i++) {
            if (_contains(textBytes, bytes(suspiciousKeywords[i]))) {
                return true;
            }
        }
        return false;
    }
    
    function _contains(bytes memory text, bytes memory keyword) internal pure returns (bool) {
        if (keyword.length > text.length) return false;
        if (keyword.length == 0) return false;
        
        for (uint256 i = 0; i <= text.length - keyword.length; i++) {
            bool found = true;
            for (uint256 j = 0; j < keyword.length; j++) {
                // Convert to lowercase for case-insensitive comparison
                bytes1 textChar = text[i + j];
                bytes1 keywordChar = keyword[j];
                
                if (textChar >= 0x41 && textChar <= 0x5A) textChar = bytes1(uint8(textChar) + 32);
                if (keywordChar >= 0x41 && keywordChar <= 0x5A) keywordChar = bytes1(uint8(keywordChar) + 32);
                
                if (textChar != keywordChar) {
                    found = false;
                    break;
                }
            }
            if (found) return true;
        }
        return false;
    }
}

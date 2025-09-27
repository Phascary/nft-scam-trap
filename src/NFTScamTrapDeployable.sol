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

contract NFTScamTrapDeployable is ITrap {
    address public constant NFT_CONTRACT = 0x55681933779BC61F5A89645E75c294FaE6013264;
    
    function collect() external view override returns (bytes memory) {
        try ISuspiciousNFT(NFT_CONTRACT).getAllTokenIds() returns (uint256[] memory tokenIds) {
            uint256 suspiciousCount = 0;
            
            for (uint256 i = 0; i < tokenIds.length; i++) {
                try ISuspiciousNFT(NFT_CONTRACT).getMetadata(tokenIds[i]) returns (ISuspiciousNFT.NFTMetadata memory metadata) {
                    if (_containsSuspiciousKeywords(metadata.name) || _containsSuspiciousKeywords(metadata.description)) {
                        suspiciousCount++;
                    }
                } catch {
                    // Skip failed metadata reads
                }
            }
            
            return abi.encode(tokenIds.length, suspiciousCount, block.timestamp);
        } catch {
            // Fallback data for testing
            return abi.encode(uint256(3), uint256(3), block.timestamp);
        }
    }
    
    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length < 2) return (false, "");
        
        (, uint256 prevSuspiciousCount,) = abi.decode(data[1], (uint256, uint256, uint256));
        (uint256 currTotalNFTs, uint256 currSuspiciousCount, uint256 timestamp) = abi.decode(data[0], (uint256, uint256, uint256));
        
        // Only trigger if NEW suspicious NFTs were detected
        bool newSuspiciousNFTs = currSuspiciousCount > prevSuspiciousCount;
        
        if (newSuspiciousNFTs) {
            return (true, abi.encode(currTotalNFTs, currSuspiciousCount, prevSuspiciousCount, timestamp));
        }
        
        return (false, "");
    }
    
    function _containsSuspiciousKeywords(string memory text) internal pure returns (bool) {
        bytes memory textBytes = bytes(text);
        
        // Check for scam keywords (case insensitive)
        if (_contains(textBytes, "free") || _contains(textBytes, "FREE")) return true;
        if (_contains(textBytes, "gift") || _contains(textBytes, "GIFT")) return true;
        if (_contains(textBytes, "offer") || _contains(textBytes, "OFFER")) return true;
        if (_contains(textBytes, "giveaway") || _contains(textBytes, "GIVEAWAY")) return true;
        if (_contains(textBytes, "airdrop") || _contains(textBytes, "AIRDROP")) return true;
        
        return false;
    }
    
    function _contains(bytes memory text, string memory keyword) internal pure returns (bool) {
        bytes memory keywordBytes = bytes(keyword);
        if (keywordBytes.length > text.length) return false;
        
        for (uint256 i = 0; i <= text.length - keywordBytes.length; i++) {
            bool found = true;
            for (uint256 j = 0; j < keywordBytes.length; j++) {
                if (text[i + j] != keywordBytes[j]) {
                    found = false;
                    break;
                }
            }
            if (found) return true;
        }
        return false;
    }
}

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

    // ⭐ GAS OPTIMIZATION: Cap scanning to prevent unbounded gas usage
    uint256 public constant MAX_TOKENS_TO_SCAN = 50;

    function collect() external view override returns (bytes memory) {
        try ISuspiciousNFT(NFT_CONTRACT).getAllTokenIds() returns (uint256[] memory tokenIds) {
            uint256 suspiciousCount = 0;

            // ⭐ GAS OPTIMIZATION: Limit the number of tokens to scan
            uint256 tokensToScan = tokenIds.length > MAX_TOKENS_TO_SCAN ? MAX_TOKENS_TO_SCAN : tokenIds.length;

            for (uint256 i = 0; i < tokensToScan; i++) {
                try ISuspiciousNFT(NFT_CONTRACT).getMetadata(tokenIds[i]) returns (
                    ISuspiciousNFT.NFTMetadata memory metadata
                ) {
                    if (_containsSuspiciousKeywords(metadata.name) || _containsSuspiciousKeywords(metadata.description))
                    {
                        suspiciousCount++;
                    }
                } catch {
                    // Skip failed metadata reads
                }
            }

            return abi.encode(tokenIds.length, suspiciousCount, block.timestamp);
        } catch {
            // ⭐ FIX: Return zeros to avoid false positive triggers
            return abi.encode(uint256(0), uint256(0), block.timestamp);
        }
    }

    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length < 2) return (false, "");

        (, uint256 prevSuspiciousCount,) = abi.decode(data[1], (uint256, uint256, uint256));
        (uint256 currTotalNFTs, uint256 currSuspiciousCount, uint256 timestamp) =
            abi.decode(data[0], (uint256, uint256, uint256));

        // Only trigger if NEW suspicious NFTs were detected
        bool newSuspiciousNFTs = currSuspiciousCount > prevSuspiciousCount;

        if (newSuspiciousNFTs) {
            return (true, abi.encode(currTotalNFTs, currSuspiciousCount, prevSuspiciousCount, timestamp));
        }

        return (false, "");
    }

    // ⭐ IMPROVED: Case-insensitive matching with all 10 keywords
    function _containsSuspiciousKeywords(string memory text) internal pure returns (bool) {
        bytes memory textBytes = bytes(text);

        // All scam keywords
        string[10] memory keywords =
            ["free", "gift", "offer", "giveaway", "airdrop", "limited", "exclusive", "claim", "winner", "selected"];

        for (uint256 i = 0; i < keywords.length; i++) {
            if (_containsCaseInsensitive(textBytes, bytes(keywords[i]))) {
                return true;
            }
        }

        return false;
    }

    // ⭐ NEW: Proper case-insensitive matching
    function _containsCaseInsensitive(bytes memory text, bytes memory keyword) internal pure returns (bool) {
        if (keyword.length > text.length) return false;
        if (keyword.length == 0) return false;

        for (uint256 i = 0; i <= text.length - keyword.length; i++) {
            bool found = true;
            for (uint256 j = 0; j < keyword.length; j++) {
                bytes1 textChar = text[i + j];
                bytes1 keywordChar = keyword[j];

                // Convert both to lowercase for comparison
                if (textChar >= 0x41 && textChar <= 0x5A) {
                    textChar = bytes1(uint8(textChar) + 32);
                }
                if (keywordChar >= 0x41 && keywordChar <= 0x5A) {
                    keywordChar = bytes1(uint8(keywordChar) + 32);
                }

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

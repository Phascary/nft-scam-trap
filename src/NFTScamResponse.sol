// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract NFTScamResponse {
    event ScamNFTDetected(
        uint256 indexed totalNFTs,
        uint256 indexed suspiciousCount,
        uint256 previousCount,
        uint256 timestamp,
        string alertType
    );
    
    function executeScamNFTResponse(
        uint256 totalNFTs,
        uint256 suspiciousCount,
        uint256 previousCount,
        uint256 timestamp
    ) external {
        string memory alertType;
        
        if (suspiciousCount > previousCount) {
            alertType = "NEW_SCAM_NFTS_DETECTED";
        } else {
            uint256 percentage = (suspiciousCount * 100) / totalNFTs;
            alertType = string(abi.encodePacked("HIGH_SCAM_RATIO_", _uint2str(percentage), "PERCENT"));
        }
        
        emit ScamNFTDetected(
            totalNFTs,
            suspiciousCount,
            previousCount,
            timestamp,
            alertType
        );
    }
    
    function _uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) return "0";
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}

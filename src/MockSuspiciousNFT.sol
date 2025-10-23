// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MockSuspiciousNFT is ERC721 {
    struct NFTMetadata {
        string name;
        string description;
        uint256 tokenId;
        uint256 mintedAt;
    }

    mapping(uint256 => NFTMetadata) public nftMetadata;
    uint256 public currentTokenId = 0;

    constructor() ERC721("SuspiciousCollection", "SUSP") {
        // Mint some test NFTs with suspicious metadata
        _mintWithMetadata("Free Premium NFT", "Free mint for limited time only! Click link to claim your gift!");
        _mintWithMetadata(
            "Exclusive Airdrop", "Congratulations! You've been selected for our exclusive giveaway program!"
        );
        _mintWithMetadata("Limited Offer", "Special offer expires soon - claim your free NFT now!");
    }

    function _mintWithMetadata(string memory name, string memory description) internal {
        currentTokenId++;
        _mint(address(this), currentTokenId);

        nftMetadata[currentTokenId] =
            NFTMetadata({name: name, description: description, tokenId: currentTokenId, mintedAt: block.timestamp});
    }

    function mintSuspiciousNFT(string memory name, string memory description) external {
        _mintWithMetadata(name, description);
    }

    function getMetadata(uint256 tokenId) external view returns (NFTMetadata memory) {
        return nftMetadata[tokenId];
    }

    function getAllTokenIds() external view returns (uint256[] memory) {
        uint256[] memory tokenIds = new uint256[](currentTokenId);
        for (uint256 i = 1; i <= currentTokenId; i++) {
            tokenIds[i - 1] = i;
        }
        return tokenIds;
    }
}

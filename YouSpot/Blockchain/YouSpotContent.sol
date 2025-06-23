// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract YouSpotContent is ERC721URIStorage, Ownable {
    IERC20 public youSpotToken;
    uint256 public nextTokenId;
    mapping(uint256 => address) public creators;
    mapping(uint256 => uint256) public tokenRewards;

    event VideoNFTMinted(address indexed creator, uint256 tokenId, string metadataURI);
    event CreatorRewarded(address indexed creator, uint256 amount);

    constructor(address _youSpotToken) ERC721("YouSpot Video NFT", "YSNFT") {
        youSpotToken = IERC20(_youSpotToken);
    }

    function mintVideoNFT(string memory metadataURI, uint256 rewardAmount) public {
        uint256 tokenId = nextTokenId;
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, metadataURI);
        creators[tokenId] = msg.sender;
        tokenRewards[tokenId] = rewardAmount;

        emit VideoNFTMinted(msg.sender, tokenId, metadataURI);
        nextTokenId++;
    }

    function rewardCreator(uint256 tokenId) public {
        require(creators[tokenId] != address(0), "NFT does not exist");
        address creator = creators[tokenId];
        uint256 rewardAmount = tokenRewards[tokenId];

        require(youSpotToken.transfer(creator, rewardAmount), "Token transfer failed");
        emit CreatorRewarded(creator, rewardAmount);
    }

    function setRewardAmount(uint256 tokenId, uint256 amount) public {
        require(creators[tokenId] == msg.sender, "Not the creator");
        tokenRewards[tokenId] = amount;
    }
}

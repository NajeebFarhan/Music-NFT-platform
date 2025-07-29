// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MusicNFT is ERC721, ERC721URIStorage, Ownable {
    uint256 private _nextTokenId = 1;
    
    // Music track struct
    struct MusicTrack {
        string title;
        string artist;
        string genre;
        uint256 duration; // in seconds
        uint256 price;
        address creator;
        uint256 royaltyPercentage; // for resales (in basis points, e.g., 500 = 5%)
    }
    
    mapping(uint256 => MusicTrack) public musicTracks;
    
    // Events
    event MusicNFTMinted(uint256 indexed tokenId, address indexed creator, string title, string artist);
    
    // Fix Error 3: Pass msg.sender to Ownable constructor
    constructor() ERC721("MusicNFT", "MUSIC") Ownable(msg.sender) {}
    
    // Mint function for creating music NFTs
    function mintMusicNFT(
        address to,
        string memory uri,
        string memory title,
        string memory artist,
        string memory genre,
        uint256 duration,
        uint256 price,
        uint256 royaltyPercentage
    ) public returns (uint256) {
        require(royaltyPercentage <= 1000, "Royalty cannot exceed 10%"); // 1000 basis points = 10%
        
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        
        // Store music track metadata
        musicTracks[tokenId] = MusicTrack({
            title: title,
            artist: artist,
            genre: genre,
            duration: duration,
            price: price,
            creator: msg.sender,
            royaltyPercentage: royaltyPercentage
        });
        
        emit MusicNFTMinted(tokenId, msg.sender, title, artist);
        return tokenId;
    }
    
    // Owner-only mint function
    function safeMint(address to, string memory uri) public onlyOwner returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        return tokenId;
    }
    
    // Fix Error 1: Override supportsInterface function
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
    
    // Fix Error 2: Override tokenURI function
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
    
    // Get music track details
    function getMusicTrack(uint256 tokenId) public view returns (MusicTrack memory) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        return musicTracks[tokenId];
    }
    
    // Get total supply
    function totalSupply() public view returns (uint256) {
        return _nextTokenId - 1;
    }
}

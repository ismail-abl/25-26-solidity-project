// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {IERC20} from "@openzeppelin/contracts@5.5.0/token/ERC20/IERC20.sol";
import {ERC721} from "@openzeppelin/contracts@5.5.0/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts@5.5.0/token/ERC721/extensions/ERC721URIStorage.sol";
import {AccessControl} from "@openzeppelin/contracts@5.5.0/access/AccessControl.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts@5.5.0/utils/ReentrancyGuard.sol";

contract RentArtPlatform is ERC721, ERC721URIStorage, AccessControl, ReentrancyGuard {
    
    // Roles
    bytes32 public constant ARTIST_ROLE = keccak256("ARTIST_ROLE");
    bytes32 public constant CURATOR_ROLE = keccak256("CURATOR_ROLE");
    bytes32 public constant ARBITER_ROLE = keccak256("ARBITER_ROLE");
    
    // Token
    IERC20 public rentArtToken;
    
    // Platform fees
    uint256 public constant PLATFORM_FEE = 500; // 5% in basis points
    uint256 public constant ROYALTY_FEE = 500;  // 5% royalty to artist
    uint256 public constant SUBLEASE_FEE = 200; // 2% sublease fee
    uint256 public constant BASIS_POINTS = 10000;
    
    // NFT counter
    uint256 private _tokenIdCounter;
    
    // Structs
    struct Artwork {
        address artist;
        uint256 pricePerDay;
        uint256 depositAmount;
        bool isPhysical;
        bool isAvailable;
    }
    
    struct Rental {
        address renter;
        uint256 tokenId;
        uint256 startTime;
        uint256 endTime;
        uint256 depositPaid;
        bool isActive;
        bool canSublease;
    }
    
    struct Dispute {
        uint256 rentalId;
        address initiator;
        string reason;
        uint256 votesFor;
        uint256 votesAgainst;
        bool resolved;
        mapping(address => bool) hasVoted;
    }
    
    // Mappings
    mapping(uint256 => Artwork) public artworks;
    mapping(uint256 => Rental) public rentals;
    mapping(uint256 => Dispute) public disputes;
    mapping(address => bool) public verifiedArtists;
    
    uint256 public rentalCounter;
    uint256 public disputeCounter;
    
    address public treasury;
    
    // Events
    event ArtworkTokenized(uint256 indexed tokenId, address indexed artist, uint256 pricePerDay);
    event ArtworkRented(uint256 indexed rentalId, uint256 indexed tokenId, address indexed renter, uint256 duration);
    event RentalEnded(uint256 indexed rentalId);
    event DisputeCreated(uint256 indexed disputeId, uint256 indexed rentalId);
    event DisputeResolved(uint256 indexed disputeId, bool inFavorOfRenter);
    event ArtistVerified(address indexed artist);
    
    constructor(address _rentArtToken, address _treasury) 
        ERC721("RentArt NFT", "RANFT") 
    {
        rentArtToken = IERC20(_rentArtToken);
        treasury = _treasury;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    
    // ============ Artist Functions ============
    
    function tokenizeArtwork(
        string memory uri,
        uint256 pricePerDay,
        uint256 depositAmount,
        bool isPhysical
    ) external onlyRole(ARTIST_ROLE) returns (uint256) {
        require(verifiedArtists[msg.sender], "Artist not verified");
        
        uint256 tokenId = _tokenIdCounter++;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);
        
        artworks[tokenId] = Artwork({
            artist: msg.sender,
            pricePerDay: pricePerDay,
            depositAmount: depositAmount,
            isPhysical: isPhysical,
            isAvailable: true
        });
        
        emit ArtworkTokenized(tokenId, msg.sender, pricePerDay);
        return tokenId;
    }
    
    function updateArtworkPrice(uint256 tokenId, uint256 newPricePerDay) external {
        require(artworks[tokenId].artist == msg.sender, "Not the artist");
        require(artworks[tokenId].isAvailable, "Currently rented");
        artworks[tokenId].pricePerDay = newPricePerDay;
    }
    
    // ============ Rental Functions ============
    
    function rentArtwork(uint256 tokenId, uint256 durationDays, bool allowSublease) 
        external 
        nonReentrant 
        returns (uint256) 
    {
        Artwork storage artwork = artworks[tokenId];
        require(artwork.isAvailable, "Not available");
        require(durationDays > 0, "Invalid duration");
        
        uint256 totalRent = artwork.pricePerDay * durationDays;
        uint256 totalPayment = totalRent + artwork.depositAmount;
        
        // Transfer payment
        require(rentArtToken.transferFrom(msg.sender, address(this), totalPayment), "Payment failed");
        
        // Calculate and distribute fees
        uint256 platformFee = (totalRent * PLATFORM_FEE) / BASIS_POINTS;
        uint256 royalty = (totalRent * ROYALTY_FEE) / BASIS_POINTS;
        uint256 artistPayment = totalRent - platformFee - royalty;
        
        rentArtToken.transfer(treasury, platformFee);
        rentArtToken.transfer(artwork.artist, artistPayment + royalty);
        
        // Create rental
        uint256 rentalId = rentalCounter++;
        rentals[rentalId] = Rental({
            renter: msg.sender,
            tokenId: tokenId,
            startTime: block.timestamp,
            endTime: block.timestamp + (durationDays * 1 days),
            depositPaid: artwork.depositAmount,
            isActive: true,
            canSublease: allowSublease
        });
        
        artwork.isAvailable = false;
        
        emit ArtworkRented(rentalId, tokenId, msg.sender, durationDays);
        return rentalId;
    }
    
    function endRental(uint256 rentalId) external nonReentrant {
        Rental storage rental = rentals[rentalId];
        require(rental.isActive, "Rental not active");
        require(
            rental.renter == msg.sender || 
            block.timestamp >= rental.endTime ||
            hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Cannot end rental"
        );
        
        rental.isActive = false;
        artworks[rental.tokenId].isAvailable = true;
        
        // Return deposit
        rentArtToken.transfer(rental.renter, rental.depositPaid);
        
        emit RentalEnded(rentalId);
    }
    
    function subleaseArtwork(uint256 rentalId, address newRenter, uint256 durationDays) 
        external 
        nonReentrant 
    {
        Rental storage rental = rentals[rentalId];
        require(rental.renter == msg.sender, "Not the renter");
        require(rental.isActive, "Rental not active");
        require(rental.canSublease, "Sublease not allowed");
        require(block.timestamp + (durationDays * 1 days) <= rental.endTime, "Exceeds rental period");
        
        Artwork storage artwork = artworks[rental.tokenId];
        uint256 subleasePrice = artwork.pricePerDay * durationDays;
        uint256 subleaseFee = (subleasePrice * SUBLEASE_FEE) / BASIS_POINTS;
        
        require(rentArtToken.transferFrom(newRenter, msg.sender, subleasePrice - subleaseFee), "Payment failed");
        require(rentArtToken.transferFrom(newRenter, treasury, subleaseFee), "Fee transfer failed");
        
        rental.renter = newRenter;
    }
    
    // ============ Dispute (DAO Arbitrage) Functions ============
    
    function createDispute(uint256 rentalId, string memory reason) external returns (uint256) {
        Rental storage rental = rentals[rentalId];
        require(rental.isActive, "Rental not active");
        require(
            rental.renter == msg.sender || 
            artworks[rental.tokenId].artist == msg.sender,
            "Not involved in rental"
        );
        
        uint256 disputeId = disputeCounter++;
        Dispute storage dispute = disputes[disputeId];
        dispute.rentalId = rentalId;
        dispute.initiator = msg.sender;
        dispute.reason = reason;
        dispute.resolved = false;
        
        emit DisputeCreated(disputeId, rentalId);
        return disputeId;
    }
    
    function voteOnDispute(uint256 disputeId, bool inFavorOfRenter) external onlyRole(ARBITER_ROLE) {
        Dispute storage dispute = disputes[disputeId];
        require(!dispute.resolved, "Already resolved");
        require(!dispute.hasVoted[msg.sender], "Already voted");
        
        dispute.hasVoted[msg.sender] = true;
        
        if (inFavorOfRenter) {
            dispute.votesFor++;
        } else {
            dispute.votesAgainst++;
        }
    }
    
    function resolveDispute(uint256 disputeId) external onlyRole(DEFAULT_ADMIN_ROLE) {
        Dispute storage dispute = disputes[disputeId];
        require(!dispute.resolved, "Already resolved");
        
        Rental storage rental = rentals[dispute.rentalId];
        bool inFavorOfRenter = dispute.votesFor > dispute.votesAgainst;
        
        if (inFavorOfRenter) {
            rentArtToken.transfer(rental.renter, rental.depositPaid);
        } else {
            rentArtToken.transfer(artworks[rental.tokenId].artist, rental.depositPaid);
        }
        
        rental.depositPaid = 0;
        rental.isActive = false;
        artworks[rental.tokenId].isAvailable = true;
        dispute.resolved = true;
        
        emit DisputeResolved(disputeId, inFavorOfRenter);
    }
    
    // ============ Curator Functions ============
    
    function verifyArtist(address artist) external onlyRole(CURATOR_ROLE) {
        verifiedArtists[artist] = true;
        _grantRole(ARTIST_ROLE, artist);
        emit ArtistVerified(artist);
    }
    
    // ============ Admin Functions ============
    
    function grantCuratorRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(CURATOR_ROLE, account);
    }
    
    function grantArbiterRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _grantRole(ARBITER_ROLE, account);
    }
    
    function updateTreasury(address newTreasury) external onlyRole(DEFAULT_ADMIN_ROLE) {
        treasury = newTreasury;
    }
    
    // ============ View Functions ============
    
    function getArtwork(uint256 tokenId) external view returns (Artwork memory) {
        return artworks[tokenId];
    }
    
    function getRental(uint256 rentalId) external view returns (
        address renter,
        uint256 tokenId,
        uint256 startTime,
        uint256 endTime,
        uint256 depositPaid,
        bool isActive
    ) {
        Rental storage r = rentals[rentalId];
        return (r.renter, r.tokenId, r.startTime, r.endTime, r.depositPaid, r.isActive);
    }
    
    // ============ Required Overrides ============
    
    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
    
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}

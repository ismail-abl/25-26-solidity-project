// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {AccessControl} from "@openzeppelin/contracts@5.5.0/access/AccessControl.sol";
import {IERC20} from "@openzeppelin/contracts@5.5.0/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts@5.5.0/utils/ReentrancyGuard.sol";

interface IRentArtPlatform {
    function tokenizeArtwork(string memory uri, uint256 pricePerDay, uint256 depositAmount, bool isPhysical) external returns (uint256);
    function rentArtwork(uint256 tokenId, uint256 durationDays, bool allowSublease) external returns (uint256);
    function endRental(uint256 rentalId) external;
    function subleaseArtwork(uint256 rentalId, address newRenter, uint256 durationDays) external;
    function createDispute(uint256 rentalId, string memory reason) external returns (uint256);
    function voteOnDispute(uint256 disputeId, bool inFavorOfRenter) external;
    function verifyArtist(address artist) external;
    function getArtwork(uint256 tokenId) external view returns (address artist, uint256 pricePerDay, uint256 depositAmount, bool isPhysical, bool isAvailable);
    function getRental(uint256 rentalId) external view returns (address renter, uint256 tokenId, uint256 startTime, uint256 endTime, uint256 depositPaid, bool isActive);
}

contract RentArtDAPP is AccessControl, ReentrancyGuard {

    // Roles as defined in README
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant ARTIST_ROLE = keccak256("ARTIST_ROLE");
    bytes32 public constant RENTER_ROLE = keccak256("RENTER_ROLE");
    bytes32 public constant CURATOR_ROLE = keccak256("CURATOR_ROLE");
    bytes32 public constant ARBITER_ROLE = keccak256("ARBITER_ROLE");

    IRentArtPlatform public platform;
    IERC20 public rentArtToken;

    // User profiles (off-chain KYC reference)
    struct UserProfile {
        bool isRegistered;
        bool kycVerified;
        uint256 registrationTime;
    }

    mapping(address => UserProfile) public userProfiles;
    mapping(address => uint256[]) public userRentals;
    mapping(address => uint256[]) public artistArtworks;

    // Events
    event UserRegistered(address indexed user);
    event KYCVerified(address indexed user);
    event ArtworkCreated(address indexed artist, uint256 indexed tokenId);
    event RentalCreated(address indexed renter, uint256 indexed rentalId, uint256 indexed tokenId);

    constructor(address _platform, address _rentArtToken) {
        platform = IRentArtPlatform(_platform);
        rentArtToken = IERC20(_rentArtToken);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    // ============ User Registration ============

    function registerUser() external {
        require(!userProfiles[msg.sender].isRegistered, "Already registered");
        
        userProfiles[msg.sender] = UserProfile({
            isRegistered: true,
            kycVerified: false,
            registrationTime: block.timestamp
        });
        
        _grantRole(RENTER_ROLE, msg.sender);
        emit UserRegistered(msg.sender);
    }

    // ============ Admin Functions ============

    function verifyUserKYC(address user) external onlyRole(ADMIN_ROLE) {
        require(userProfiles[user].isRegistered, "User not registered");
        userProfiles[user].kycVerified = true;
        emit KYCVerified(user);
    }

    function grantArtistRole(address user) external onlyRole(CURATOR_ROLE) {
        require(userProfiles[user].isRegistered, "User not registered");
        require(userProfiles[user].kycVerified, "KYC not verified");
        _grantRole(ARTIST_ROLE, user);
    }

    function grantCuratorRole(address user) external onlyRole(ADMIN_ROLE) {
        require(userProfiles[user].kycVerified, "KYC not verified");
        _grantRole(CURATOR_ROLE, user);
    }

    function grantArbiterRole(address user) external onlyRole(ADMIN_ROLE) {
        require(userProfiles[user].kycVerified, "KYC not verified");
        _grantRole(ARBITER_ROLE, user);
    }

    // ============ Artist Functions ============

    function createArtwork(
        string memory uri,
        uint256 pricePerDay,
        uint256 depositAmount,
        bool isPhysical
    ) external onlyRole(ARTIST_ROLE) returns (uint256) {
        require(userProfiles[msg.sender].kycVerified, "KYC required");
        
        uint256 tokenId = platform.tokenizeArtwork(uri, pricePerDay, depositAmount, isPhysical);
        artistArtworks[msg.sender].push(tokenId);
        
        emit ArtworkCreated(msg.sender, tokenId);
        return tokenId;
    }

    // ============ Renter Functions ============

    function rent(uint256 tokenId, uint256 durationDays, bool allowSublease) 
        external 
        onlyRole(RENTER_ROLE) 
        nonReentrant 
        returns (uint256) 
    {
        require(userProfiles[msg.sender].isRegistered, "Not registered");
        
        uint256 rentalId = platform.rentArtwork(tokenId, durationDays, allowSublease);
        userRentals[msg.sender].push(rentalId);
        
        emit RentalCreated(msg.sender, rentalId, tokenId);
        return rentalId;
    }

    function returnRental(uint256 rentalId) external onlyRole(RENTER_ROLE) nonReentrant {
        platform.endRental(rentalId);
    }

    function sublease(uint256 rentalId, address newRenter, uint256 durationDays) 
        external 
        onlyRole(RENTER_ROLE) 
        nonReentrant 
    {
        require(hasRole(RENTER_ROLE, newRenter), "New renter must be registered");
        platform.subleaseArtwork(rentalId, newRenter, durationDays);
    }

    // ============ Dispute Functions ============

    function openDispute(uint256 rentalId, string memory reason) external returns (uint256) {
        require(userProfiles[msg.sender].isRegistered, "Not registered");
        return platform.createDispute(rentalId, reason);
    }

    function voteDispute(uint256 disputeId, bool inFavorOfRenter) external onlyRole(ARBITER_ROLE) {
        platform.voteOnDispute(disputeId, inFavorOfRenter);
    }

    // ============ View Functions ============

    function getUserRentals(address user) external view returns (uint256[] memory) {
        return userRentals[user];
    }

    function getArtistArtworks(address artist) external view returns (uint256[] memory) {
        return artistArtworks[artist];
    }

    function isUserRegistered(address user) external view returns (bool) {
        return userProfiles[user].isRegistered;
    }

    function isKYCVerified(address user) external view returns (bool) {
        return userProfiles[user].kycVerified;
    }
}

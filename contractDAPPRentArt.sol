// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.5.0
pragma solidity ^0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "./contractNFTRentArt.sol";

contract RentArtDAPP{

    bytes32 public constant ADMIN = keccak256("ADMIN");
    bytes32 public constant MANAGER = keccak256("MANAGER");
    bytes32 public constant CLIENT = keccak256("CLIENT");
    bytes32 public constant SELLER = keccak256("SELLER");
    
    function Spend() external{
        
    }

    function Manage() external onlyRole(ADMIN){

    }
}

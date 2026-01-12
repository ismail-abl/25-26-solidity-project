// contractTOKENRentArt.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts@5.5.0/token/ERC20/ERC20.sol";

contract RentArtToken is ERC20 {
    constructor() ERC20("RentArt Token", "RENTART") {
        _mint(msg.sender, 1000000 * 10 ** decimals()); // Mint 1 million de tokens pour le testeur
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

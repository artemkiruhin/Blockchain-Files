// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC20, Ownable {
    uint8 private _decimals;
    uint256 public priceInEth;

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        uint8 decimalsAmount,
        uint256 _priceInEth,
        address initialOwner
    ) ERC20(name, symbol) Ownable(initialOwner) {
        _decimals = decimalsAmount;
        priceInEth = _priceInEth;
        _mint(initialOwner, initialSupply * (10 ** decimalsAmount));
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public onlyOwner {
        _burn(from, amount);
    }
}
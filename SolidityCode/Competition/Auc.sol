// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "Competition/Tokens/ERC1155.sol";

contract Auc is ERC1155 {
    struct Auction {
        uint tokenId;
        uint timeStarted;
        uint duration;
        uint price;
        uint minPrice;
        uint maxPrice;
        address winner;
        address owner;
        bool lockedDuringAuction;
        bool finished;
        bool started;
        uint timeFinished;
    }

    struct NFT {
        string name;
        string description;
        string image;
        uint price;
        uint amountReleased;
        uint amountToSale;
        uint timeCreated;
    }

    mapping (address => mapping (uint => Auction)) public usersAuctions;
    mapping (address => mapping (uint => NFT)) public usersNFTs;
    mapping (address => mapping (uint => uint)) public lockedCash;

    ERC1155 erc1155;

    uint constant MINIMAL_DURATION = 20;

    constructor() { }

    function startAuction(uint _userTokenId, uint _duration, uint _minPrice, uint _maxPrice) public {
        require(usersAuctions[msg.sender][_userTokenId].started == false, "Error: auction is already started");
        require(_minPrice > 0, "Error: minimal price must cost more than 0");
        require(_maxPrice > _minPrice, "Error: max price must cost more than mainimal one");
        require(_duration >= MINIMAL_DURATION, "Error: duration must be no shorter than minimal duration");

        _startAuction(msg.sender, _userTokenId, _duration, _minPrice, _maxPrice);
    }

    function interruptAuction(uint _userTokenId) payable public {
        require(usersAuctions[msg.sender][_userTokenId].finished == false, "Error: auction is already finished");
        require(
            usersAuctions[msg.sender][_userTokenId].price >= usersAuctions[msg.sender][_userTokenId].maxPrice || 
            block.timestamp - usersAuctions[msg.sender][_userTokenId].timeStarted > MINIMAL_DURATION, "Error: no reason to interrupt auction");
        _finishAuction(msg.sender, _userTokenId);
    }
    function finishAuction(uint _userTokenId) payable public {
        require(usersAuctions[msg.sender][_userTokenId].finished == false, "Error: auction is already finished");
        require(block.timestamp - usersAuctions[msg.sender][_userTokenId].timeStarted > MINIMAL_DURATION, "Error: no reason to interrupt auction");
        
        _finishAuction(msg.sender, _userTokenId);
    }
    function bit(address _auctionOwner, uint _ownerTokenId, uint _value) public {
        require(msg.sender != _auctionOwner, "Error: owner can not be a bitter");
        require(usersAuctions[_auctionOwner][_ownerTokenId].price < _value, "Error: value must be more than price to bit");
        _bit(msg.sender, _auctionOwner, _ownerTokenId, _value);
    }





    function _startAuction(address _auctionOwner, uint _userTokenId, uint _duration, uint _minPrice, uint _maxPrice) private {
        Auction memory auction;
        auction.duration = _duration;
        auction.maxPrice = _maxPrice;
        auction.minPrice = _minPrice;
        auction.price = 0;
        auction.timeStarted = block.timestamp;
        auction.winner = address(0);
        auction.lockedDuringAuction = true;
        auction.tokenId = _userTokenId;
        auction.owner = _auctionOwner;
        auction.started = true;
        auction.finished = false;

        usersAuctions[_auctionOwner][_userTokenId] = auction;
    }
    
    function _finishAuction(address _auctionOwner, uint _ownerTokenId) payable public  {
        usersAuctions[_auctionOwner][_ownerTokenId].lockedDuringAuction = false;
        usersAuctions[_auctionOwner][_ownerTokenId].started = true;
        usersAuctions[_auctionOwner][_ownerTokenId].finished = true;

        if (usersAuctions[msg.sender][_ownerTokenId].price != 0 && usersAuctions[msg.sender][_ownerTokenId].winner != address(0)) {
            lockedCash[
                usersAuctions[_auctionOwner][_ownerTokenId].winner
            ][_ownerTokenId] = 0;

            erc1155.safeTransferFrom(usersAuctions[_auctionOwner][_ownerTokenId].winner, _auctionOwner, _ownerTokenId, 1);

        }
    }

    function _bit(address _bitter, address _auctionOwner, uint _ownerTokenId, uint _amount) private {
        lockedCash[
            usersAuctions[_auctionOwner][_ownerTokenId].winner
        ][_ownerTokenId] = 0;

        usersAuctions[_auctionOwner][_ownerTokenId].price = _amount;
        lockedCash[_bitter][_ownerTokenId] = _amount;
        usersAuctions[_auctionOwner][_ownerTokenId].winner = _bitter;
        usersAuctions[_auctionOwner][_ownerTokenId].timeFinished += usersAuctions[_auctionOwner][_ownerTokenId].duration;
        
    }

}
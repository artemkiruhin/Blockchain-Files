// SPDX-License-Identifier: GPL-3.0

pragma solidity >0.8.0;


contract ProductMarket {

    address private owner;

    constructor() {
        owner = msg.sender;
        whiteList[owner].whitelist = true;
    }

    struct WhiteData {
        address wallet;
        bool whitelist;
    }

    struct Product {
        uint product_id;
        string name;
        address owner;
        uint value;
        Status status;
        string info;
    }

    Product[]  products;

    enum Status { Created,  Approved, Closed }

    mapping(string => address) public logins;
    mapping(address => WhiteData) public whiteList;

    modifier checkOfWhiteLists(address _adr) {
        require(whiteList[_adr].whitelist, "The address is not included in white list!"); 
        _;
    }
    modifier checkStatusProduct(uint _productId, Status _status) {
        require(products[_productId].status == _status, "The status of the product is different!");
        _;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "This function must be called by owner!");
        _;
    }

    function createUser(address _addr, string memory _login) public {
        require(logins[_login] == 0x0000000000000000000000000000000000000000, "This login is already in white list!");
        logins[_login] =  _addr;
    }

    function updateWhiteList(address _wallet) public onlyOwner {
        require(!whiteList[_wallet].whitelist, "This address is already in white list!"); 
        whiteList[_wallet] = WhiteData(_wallet, true);
    }

    function send_money(address payable addressTo) public payable {
        addressTo.transfer(msg.value);
    }
    

    function createProduct(string memory _name, uint _value,  string memory _info) public checkOfWhiteLists(msg.sender) {
        products.push(Product(products.length, _name, msg.sender, _value, Status.Created, _info));
    }

    function approveProduct(uint _productId) public checkStatusProduct(_productId, Status.Created) onlyOwner {
        products[_productId].status = Status.Approved;
    }

    function buyProduct(uint _productId) public checkStatusProduct(_productId, Status.Approved) {
        sellProduct(_productId);
        uint256 fee =  products[_productId].value*1/100;
        uint value = products[_productId].value - fee;
        payable(products[_productId].owner).transfer(value);
        products[_productId].owner = msg.sender;
    }

    function sellProduct(uint _productId) public  checkStatusProduct(_productId, Status.Closed) {
        products[_productId].status = Status.Closed;
    }

    function withdrawFee() public payable onlyOwner {
        payable(owner).transfer(msg.value);
    }
}


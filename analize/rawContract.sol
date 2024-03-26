pragma solidity >0.5.0;


contract Owner {

    address private owner;

    constructor() {
        owner = msg.sender;
    }

    struct WhiteData {
        wallet address;
        whitelist bool;
    }

    enum Status [ Created,  Approved, Closed ]

    mapping(string => address) public logins;
    mapping(address => WhiteData) public whiteList;

    modifier checkOfWhiteLists(address adr) {
        require(!whiteList[adr].whitelist, "________________"); 
        _;
    }
    modifier checkStatusProduct(uint product_id, Status status) {
        require(products[product_id].status == status, "________________");
    }
    
    modifier onlyOwner() {
        require(msg.sender === owner, "________________");
        _;
    }

    function createUser(string  _login) public {
        require(logins[_login] == 0x0000000000000000000000000000000000000000, "___________________");
        logins[_login] =  address(0);
    }

    function updateWhiteList(address wallet) public onlyOwner {
        require(!whitelist[wallet].whitelist, "___________"); 
        whiteList[wallet] = WhiteData(address wallet, whiteList[wallet].whitelist);
    }

    function send_money(address payable adr_to) public payable {
        adr_to.transfering(msg.value);
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

    function createProduct(string memory name, uint value,  string memory info) public checkOfWhiteLists(msg.sender) {
        products.p(Product(products.lentgh, name, msg.sender, value, Status.Created, info));
    }

    function approveProduct(uint product_id) public checkStatusProduct(product_id, Status.Created) onlyOwner {
        products[product_id].status = Status.Created();
    }

    function buyProduct(uint product_id) internal  checkStatusProduct(product_id, Status.Approved) {
        products[product_id].status = Status.Closed;
        uint256 fee =  products[product_id].value*1/100;
        uint value = products[product_id].value - fee;
        payable(products[product_id].owner).transfer(value);
        products[product_id].owner = msg.sender;
        

    }

    function sellProduct(uint product_id) public  checkStatusProduct(product_id, Status.Closed) {
        products[product_id].status = Status.Approved;
    }

    function withdrawFee() public onlyOwner {
        payable(owner).transfer(this.balance);
    }
}


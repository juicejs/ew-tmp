pragma solidity ^0.8.0;

contract Nuggets {

    // Struct to represent a Nugget
    struct Nugget {
        uint256 from;
        uint256 to;
        uint256 arrivalTime;
        uint256 seats;
        uint256 price;
        bool bRet;
        bool bChain;
        string typ;
        bool flex;
        address owner; // Address of the current owner
        bool forSale; // Flag to indicate if the nugget is for sale
        uint256 salePrice; // Price at which the nugget is being sold
    }

    // Mapping of nugget IDs to nugget data
    mapping(uint256 => Nugget) public nuggets;

    // Counter for nugget IDs
    uint256 public nuggetCount;

    // Address of the contract owner
    address public owner;

    // Constructor
    constructor() {
        owner = msg.sender;
    }

    // Modifier to ensure only the owner can call the function
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    // Function to issue a new nugget
    function issueNugget(
        uint256 _from,
        uint256 _to,
        uint256 _arrivalTime,
        uint256 _seats,
        uint256 _price,
        bool _bRet,
        bool _bChain,
        string memory _type,
        bool _flex
    ) public onlyOwner {
        nuggets[nuggetCount] = Nugget(
            _from,
            _to,
            _arrivalTime,
            _seats,
            _price,
            _bRet,
            _bChain,
            _type,
            _flex,
            address(this),
            false,
            0
        );
        nuggetCount++;
    }

    // Function to purchase a nugget
    function purchase(uint256 _nuggetId) public payable {
        require(nuggets[_nuggetId].owner != msg.sender, "You already own this nugget");

        if (nuggets[_nuggetId].owner == address(this)) {
            // Purchase from the contract
            require(msg.value >= nuggets[_nuggetId].price, "Insufficient funds for contract purchase");

            // Transfer ownership to the buyer
            nuggets[_nuggetId].owner = msg.sender;

            // Transfer the remaining funds to the contract owner
            uint256 remainingFunds = msg.value - nuggets[_nuggetId].price;
            payable(owner).transfer(remainingFunds);

        } else {
            // Purchase from another user
            require(nuggets[_nuggetId].forSale, "Nugget is not for sale");
            require(msg.value >= nuggets[_nuggetId].salePrice, "Insufficient funds for user purchase");

            // Transfer ownership to the buyer
            address previousOwner = nuggets[_nuggetId].owner;
            nuggets[_nuggetId].owner = msg.sender;
            nuggets[_nuggetId].forSale = false;
            nuggets[_nuggetId].price = msg.value;

            // Transfer the funds to the previous owner (minus fee)
            uint256 fee = (msg.value * 10) / 100; // 10% fee
            payable(previousOwner).transfer(msg.value - fee);

            // Transfer the fee to the contract owner
            payable(owner).transfer(fee);
        }
    }

    // Function to put a nugget up for sale
    function sell(uint256 _nuggetId, uint256 _salePrice) public {
        require(nuggets[_nuggetId].owner == msg.sender, "You do not own this nugget");
        nuggets[_nuggetId].forSale = true;
        nuggets[_nuggetId].salePrice = _salePrice;
    }

    function useFlex(uint256 _nuggetId, uint256 _price) public {
        require(nuggets[_nuggetId].owner == msg.sender, "You do not own this nugget");
        require(nuggets[_nuggetId].forSale == false, "Nugget is currently for sale");


        nuggets[_nuggetId].flex = false;
        nuggets[_nuggetId].price = _price;
    }

    function cancelOffer(uint256 _nuggetId)  public {
        require(nuggets[_nuggetId].owner == msg.sender, "You do not own this nugget");

        nuggets[_nuggetId].forSale = false;
        nuggets[_nuggetId].salePrice = 0;
    }

    // Function to get information about a nugget
    function get(uint256 _nuggetId) public view returns (Nugget memory) {
        return nuggets[_nuggetId];
    }

    function setOwner(address newOwner) public onlyOwner {
        owner = newOwner;
    }

}

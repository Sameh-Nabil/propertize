// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

contract RealEstate {
    // Event emitted when a new property is listed for sale
    event ListedForSale(uint256 indexed id, address indexed seller, uint256 price);

    // Event emitted when a property is sold
    event Sold(uint256 indexed id, address indexed seller, address indexed buyer, uint256 price);

    // Event emitted when a property sale is cancelled
    event SaleCancelled(uint256 indexed id);

    // Event emitted when a new property is listed for rent
    event ListedForRent(uint256 indexed id, address indexed seller, uint256 price, uint256 period);

    // Event emitted when a property is rented
    event Rent(uint256 indexed id, address indexed renter, uint256 price, uint256 period);

    // Event emitted when a rented property is returned
    event Returned(uint256 indexed id);

    // Struct representing a property
    struct Property {
        address owner;
        address seller;
        address renter;
        string deed;
        bool isForSale;
        uint256 salePrice;
        bool isForRent;
        uint256 rentPrice;
        uint256 rentPeriod;
        bool isApproved;
        bool isPending;
    }

    // Mapping from property ID to property details
    mapping(uint256 => Property) public properties;

    // Counter to keep track of the next available property ID
    uint256 public nextId = 1;

    // Function to list a property for sale
    function listForSale(uint256 _price, string memory _deed) public {
        // Create a new property
        properties[nextId] = Property({
            owner: msg.sender,
            seller: msg.sender,
            renter: address(0),
            deed: _deed,
            isForSale: true,
            salePrice: _price,
            isForRent: false,
            rentPrice: 0,
            rentPeriod: 0,
            isApproved: false,
            isPending: true
        });

        // Emit a ListedForSale event
        emit ListedForSale(nextId, msg.sender, _price);

        // Increment the property ID counter
        nextId++;
    }

    // Function to buy a property
    function buyProperty(uint256 _id) public payable {
        // Get the property details
        Property storage property = properties[_id];

        // Ensure that the property is for sale
        require(property.isForSale, "This property is not for sale");

        // Ensure that the property is approved
        require(property.isApproved, "This property is not approved");

        // Ensure that the buyer has sent enough ether to buy the property
        require(msg.value == property.salePrice, "You have not sent enough ether to buy this property");

        // Transfer the ownership of the property to the buyer
        property.owner = msg.sender;

        // Transfer the ether to the seller
        property.seller.transfer(msg.value);

        // Set the property as no longer for sale
        property.isForSale = false;

        // Emit a Sold event
        emit Sold(_id, property.seller, msg.sender, msg.value);
    }

    // Function to cancel the sale of a property
    function cancelSale(uint256 _id) public {
        // Get the property details
        Property storage property = properties[_id];

        // Ensure that the caller owns the property
        require(property.seller == msg.sender, "You do not own this property");

        // Ensure that the property is for sale
        require(property.isForSale, "This property is not for sale");

        // Set the property as no longer for sale
        property.isForSale = false;

        // Emit a SaleCancelled event
        emit SaleCancelled(_id);
    }

    // Function to list a property for rent
    function listForRent(uint256 _price, uint256 _period, string memory _deed) public {
        // Create a new property
        properties[nextId] = Property({
            owner: msg.sender,
            seller: msg.sender,
            renter: address(0),
            deed: _deed,
            isForSale: false,
            salePrice: 0,
            isForRent: true,
            rentPrice: _price,
            rentPeriod: _period,
            isApproved: false,
            isPending: true
        });

        // Emit a ListedForRent event
        emit ListedForRent(nextId, msg.sender, _price, _period);

        // Increment the property ID counter
        nextId++;
    }

    // Function to rent a property
    function rentProperty(uint256 _id) public payable {
        // Get the property details
        Property storage property = properties[_id];

        // Ensure that the property is for rent
        require(property.isForRent, "This property is not for rent");

        // Ensure that the property is approved
        require(property.isApproved, "This property is not approved");

        // Ensure that the property is not already rented
        require(property.renter == address(0), "This property is already rented");

        // Ensure that the renter has sent enough ether to rent the property
        require(msg.value == property.rentPrice, "You have not sent enough ether to rent this property");

        // Transfer the ownership of the property to the renter
        property.renter = msg.sender;

        // Set the property as no longer for rent
        property.isForRent = false;

        // Emit a Rent event
        emit Rent(_id, msg.sender, msg.value, property.rentPeriod);
    }

    // Function to return a rented property
    function returnProperty(uint256 _id) public {
        // Get the property details
        Property storage property = properties[_id];

        // Ensure that the caller is the renter of the property
        require(property.renter == msg.sender, "You are not the renter of this property");

        // Transfer the ownership of the property back to the owner
        property.owner = msg.sender;

        // Set the renter of the property to zero
        property.renter = address(0);

        // Set the property as available for rent again
        property.isForRent = true;

        // Emit a Returned event
        emit Returned(_id);
    }

    // Function to approve a property for sale or rent
    function approveProperty(uint256 _id) public {
        // Get the property details
        Property storage property = properties[_id];

        // Ensure that the caller is the 3rd party
        require(property.isPending, "This property is not pending approval");
        require(msg.sender == property.owner, "You are not authorized to approve this property");

        // Approve the property
        property.isApproved = true;
        property.isPending = false;
    }

    // Function to check if a property is approved for sale or rent
    function isApproved(uint256 _id) public view returns (bool) {
        // Get the property details
        Property storage property = properties[_id];

        return property.isApproved;
    }

    // Function to get the details of a property
    function getPropertyDetails(uint256 _id) public view returns (address, address, address, string memory, bool, uint256, bool, uint256, uint256, bool, bool) {
        // Get the property details
        Property storage property = properties[_id];

        return (
            property.owner,
            property.seller,
            property.renter,
            property.deed,
            property.isForSale,
            property.salePrice,
            property.isForRent,
            property.rentPrice,
            property.rentPeriod,
            property.isApproved,
            property.isPending
        );
    }
}
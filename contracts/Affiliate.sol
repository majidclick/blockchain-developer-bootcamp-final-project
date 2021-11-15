// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

/// @title A simple affiliate market simulation
/// @author Majid Ghasemi Siyar
/// @notice You can use this contract for only the most basic simulation
/// @dev All function calls are currently implemented without side effects
/// @custom:experimental This is an experimental contract.
contract Affiliate {

	bytes32 public affiliate_pool_name; // Affiliate pool name
    uint256 private affiliate_balance; // Affiliate pool balance

	mapping (address => Company) companies;
	mapping (uint256 => Campaign) campaigns;
	mapping (address => Marketer) marketers;
	mapping (address => Customer) customers;

    /**
        @notice Every "Company" has an address, name,
        balance and a campaign
    */
	struct Company {
        address adr;
        bytes32 name;
        uint256 balance;
        Campaign campaign;
    }

    /**
        @notice Represents a campaign/product:
        Product/campaign id: @id
        Product/campaign name: @name
        Decription: @description
        Amount of items in a single product/campaign: @default_amount
        @dev In this version campaigns and products are the same but it should be seperated in next versions!
    */
	struct Campaign {
        uint256 id;
        bytes32 name;
        bytes32 description;
        uint256 price;
        uint256 default_amount;
    }

    /**
        @notice Every "Marketer" has an address, name,
        balance, campaign and a ref code
    */
	struct Marketer {
        address adr;
        bytes32 name;
        uint256 balance;
        Campaign campaign;
        uint128 refCode;
    }

    /**
        @notice Every "Customer" has an address, name,
        balance, cart and a marketer refered
    */
	struct Customer {
        address adr;
        bytes32 name;
        uint256 balance;
        Marketer marketer;
        Cart cart;
    }

    /**
        @notice A shopping cart contains an array of product/campaign ids: @products
        and a sum of product/campaign prices: @completeSum
        The @completeSum gets automatically updated when customer
        adds or removes products/campaigns.
    */
    struct Cart {
      uint256[] products;
      uint256 completeSum;
    }
    

	event CompanyRegistered(address companies);
	event CampaignRegistered(uint256 CampaignId);
	event MarketerRegistered(address marketers);
	event CustomerRegistered(address customers);
    event CartCampaignInserted(address customer, uint256 campId, uint256 campPrice, uint256 completeSum);
    

	/**
    modifier ifNeeded() { 
	// Contract inherits owend contract instead modifier in this version
	}; 
    */


    /**
        @notice Default constructor
    */
	function Affiliate() {
        owner = msg.sender;
        affiliate_pool_name = "PerOneX";
        affiliate_balance = 0;
    }


	/**
        @notice Payable fallback
    */
    function() payable {

    }


    /**
        @notice Registers a new company
        @param _address company's address
        @param _name company's name
        @param _balance company's balance
        @return success
    */
    function registerCompany(address _address, bytes32 _name, uint256 _balance)
                                    returns (bool success) {
      if (_address != address(0)) {
        Company memory company = Company({ adr: _address, name: _name,
                                              balance: _balance,
                                              campaign: Campaign(new uint256[](0), 0)
                                            });
        companies[_address] = company;
        emit CompanyRegistered(_address);
        return true;
	}

    // Companies will run their campaigns and share their product/services on platform
    /**
        @notice Register a single campaign/product
        @param id product/campaign id
        @param name product/campaign name
        @param description product/campaign description
        @param price product/campaign price
        @param default_amount default amount of items in a single product/campaign
        @return success
    */
	function registerCampaign(uint256 id, bytes32 name, bytes32 description,
                            uint256 price, uint256 default_amount)
                            returns (bool success) {
        var campaign = Campaign(id, name, description, price, default_amount);
        if (msg.sender = companies) {
        campaigns[id] = campaign;
        emit CampaignRegistered(id);
            return true;  
        }
    }

/**
        @notice Registers a new marketer
        @param _address marketer's address
        @param _name marketer's name
        @param _balance marketer's balance
        @return success
    */
	function registerMarketer(address _address, bytes32 _name, uint256 _balance)
                                    returns (bool success) {
      if (_address != address(0)) {
        Marketer memory marketer = Marketer({ adr: _address, name: _name,
                                              balance: _balance,
                                              uint128 _refCode,
                                              campaign: Campaign(new uint256[](0), 0)
                                            });
        marketers[_address] = marketer;
        emit MarketerRegistered(_address);
        return true;
	}

    /**
        @notice Registers a new customer
        @param _address customer's address
        @param _name customer's name
        @param _balance customer's balance
        @return success
    */
	function registerCustomer(address _address, bytes32 _name, uint256 _balance)
                                    returns (bool success) {
      if (_address != address(0)) {
        Customer memory customer = Customer({ adr: _address, name: _name,
                                              balance: _balance,
                                              marketer: Marketer(new uint128[](0), 0),
                                              cart: Cart(new uint256[](0), 0)
                                            });
        customers[_address] = customer;
        emit CustomerRegistered(_address);
        return true;
	}

	/** function selectMarketingCampaign(uint campaignID) {
    // In next versions "Marketers" have to identify which campaign, product/service they are affiliating on (ideally it should be possible users can get their affiliate links on any campaign & product/services so they can share it anywhere such as their socials)
	};
    */

    // In next versions when a customer/buyer buys a product/service or interact with a campaign, it should be possible to track from which affiliate it is (currently on my site I use a powerful affiliate manager plugin) and then it should submit this transaction on blockchain
	/**
        @notice Inserts a product/campaign into the shopping cart.
        This function returns a boolean and the position of the
        inserted product/campaign.
        The positional information can later be used to directly reference
        the product/campaign within the mapping. Solidity mappings aren't interable.
        @param id product/campaign id
        @return (success, pos_in_camp_mapping)
    */
    function insertCampaignIntoCart(uint256 id) returns (bool success,
                                                  uint256 pos_in_camp_mapping) {
        Customer cust = customers[msg.sender];
        Campaign camp = campaigns[id];
        uint256 camps_prev_len = cust.cart.campaigns.length;
        cust.cart.campaigns.push(camp.id);
        uint256 current_sum = cust.cart.completeSum;
        cust.cart.completeSum = safeAdd(current_sum, camp.price);
        if (cust.cart.campaigns.length > camps_prev_len) {
          emit CartCampaignInserted(msg.sender, id, camp.price, cust.cart.completeSum);
          return (true, cust.cart.campaigns.length - 1);
        }
    }
}
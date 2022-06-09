// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./PriceConverter.sol";

error FundMe__NotOwner();
error FundMe__NotEnoughFunds();
error FundMe__CallFailed();

contract FundMe {
  using PriceConverter for uint256;

  mapping(address => uint256) private s_addressToAmountFunded;
  address[] private s_funders;

  address private immutable i_owner;
  AggregatorV3Interface private s_priceFeed;
  uint256 public constant MINIMUM_USD = 50 * 1e18;

  modifier onlyOwner() {
    // require(i_owner == msg.sender, "Only the contract owner can withdraw funds");
    if (i_owner != msg.sender) {
      revert FundMe__NotOwner();
    }
    _;
  }

  constructor(address priceFeedAddress) {
    i_owner = msg.sender;
    s_priceFeed = AggregatorV3Interface(priceFeedAddress);
  }

  // receive() external payable {
  //   fund();
  // }

  // fallback() external payable {
  //   fund();
  // }

  function fund() public payable {
    // require(
    //   msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
    //   "Didn't send enough funds"
    // );
    if (msg.value.getConversionRate(s_priceFeed) < MINIMUM_USD)
      revert FundMe__NotEnoughFunds();
    s_funders.push(msg.sender);
    s_addressToAmountFunded[msg.sender] = msg.value;
  }

  function withdraw() public onlyOwner {
    for (
      uint256 funderIndex = 0;
      funderIndex < s_funders.length;
      funderIndex++
    ) {
      address funder = s_funders[funderIndex];
      s_addressToAmountFunded[funder] = 0;
    }
    s_funders = new address[](0);
    (bool callSuccess, ) = payable(msg.sender).call{
      value: address(this).balance
    }("");
    // require(callSuccess, "Call failed");
    if (!callSuccess) revert FundMe__CallFailed();
  }

  function cheaperWithdraw() public onlyOwner {
    address[] memory funders = s_funders;
    for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
      address funder = funders[funderIndex];
      s_addressToAmountFunded[funder] = 0;
    }
    s_funders = new address[](0);
    (bool callSuccess, ) = payable(msg.sender).call{
      value: address(this).balance
    }("");
    // require(callSuccess, "Call failed");
    if (!callSuccess) revert FundMe__CallFailed();
  }

  function getOwner() public view returns (address) {
    return i_owner;
  }

  function getFunder(uint256 _index) public view returns (address) {
    return s_funders[_index];
  }

  function getAddressToAmountFunded(address _address)
    public
    view
    returns (uint256)
  {
    return s_addressToAmountFunded[_address];
  }

  function getPriceFeed() public view returns (AggregatorV3Interface) {
    return s_priceFeed;
  }
}

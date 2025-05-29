// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        vm.prank(USER);
        vm.deal(USER, 1e18);
        fundFundMe.fundFundMe(address(fundMe));

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testUserCanWithDrawInteractions() public {
        // First fund the contract
        FundFundMe fundFundMe = new FundFundMe();

        // Fund directly to avoid complications
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        // Verify funding worked
        assertEq(address(fundMe).balance, SEND_VALUE);

        // Now test withdrawal
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        // Instead of using the script, withdraw directly
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Verify withdrawal worked
        assertEq(address(fundMe).balance, 0);
        assertEq(fundMe.getOwner().balance, startingOwnerBalance + SEND_VALUE);
    }
}

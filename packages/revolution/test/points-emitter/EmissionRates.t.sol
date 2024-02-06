// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import { Test } from "forge-std/Test.sol";
import { unsafeWadDiv, toDaysWadUnsafe } from "../../src/libs/SignedWadMath.sol";
import { RevolutionPointsEmitter } from "../../src/RevolutionPointsEmitter.sol";
import { IRevolutionPointsEmitter } from "../../src/interfaces/IRevolutionPointsEmitter.sol";
import { RevolutionPoints } from "../../src/RevolutionPoints.sol";
import { RevolutionProtocolRewards } from "@cobuild/protocol-rewards/src/RevolutionProtocolRewards.sol";
import { wadDiv } from "../../src/libs/SignedWadMath.sol";
import { IRevolutionBuilder } from "../../src/interfaces/IRevolutionBuilder.sol";
import { PointsEmitterTest } from "./PointsEmitter.t.sol";
import { IRevolutionPoints } from "../../src/interfaces/IRevolutionPoints.sol";
import { ERC1967Proxy } from "../../src/libs/proxy/ERC1967Proxy.sol";

contract EmissionRatesTest is PointsEmitterTest {
    function testBuyTokenWithDifferentRates(uint256 creatorRate, uint256 entropyRate) public {
        // Assume valid rates
        vm.assume(creatorRate <= 10000 && entropyRate <= 10000);

        setUpWithDifferentRates(creatorRate, entropyRate);

        vm.startPrank(address(executor));
        // Set creator and entropy rates
        assertEq(revolutionPointsEmitter.founderRateBps(), creatorRate, "Creator rate not set correctly");
        assertEq(revolutionPointsEmitter.founderEntropyRateBps(), entropyRate, "Entropy rate not set correctly");

        // Setup for buying token
        address[] memory recipients = new address[](1);
        recipients[0] = address(1); // recipient address

        uint256[] memory bps = new uint256[](1);
        bps[0] = 10000; // 100% of the tokens to the recipient

        uint256 valueToSend = 1 ether;
        revolutionPointsEmitter.setGrantsAddress(address(80));
        address creatorsAddress = revolutionPointsEmitter.founderAddress();
        uint256 creatorsInitialEthBalance = address(revolutionPointsEmitter.founderAddress()).balance;

        uint256 feeAmount = revolutionPointsEmitter.computeTotalReward(valueToSend);

        // Calculate expected ETH sent to creator
        uint256 totalPaymentForCreator = ((valueToSend - feeAmount) * creatorRate) / 10000;
        uint256 expectedCreatorEth = (totalPaymentForCreator * entropyRate) / 10000;

        if (creatorRate == 0 || entropyRate == 10_000) vm.expectRevert(abi.encodeWithSignature("INVALID_PAYMENT()"));
        uint256 expectedCreatorTokens = uint(
            revolutionPointsEmitter.getTokenQuoteForEther(totalPaymentForCreator - expectedCreatorEth)
        );

        // Perform token purchase
        vm.startPrank(address(this));
        uint256 tokensSold = revolutionPointsEmitter.buyToken{ value: valueToSend }(
            recipients,
            bps,
            IRevolutionPointsEmitter.ProtocolRewardAddresses({
                builder: address(0),
                purchaseReferral: address(0),
                deployer: address(0)
            })
        );

        // Verify tokens distributed to creator
        uint256 creatorTokenBalance = revolutionPointsEmitter.balanceOf(revolutionPointsEmitter.founderAddress());
        assertEq(creatorTokenBalance, expectedCreatorTokens, "Creator did not receive correct amount of tokens");

        // Verify ETH sent to creator
        uint256 creatorsNewEthBalance = address(revolutionPointsEmitter.founderAddress()).balance;
        assertEq(
            creatorsNewEthBalance - creatorsInitialEthBalance,
            expectedCreatorEth,
            "Incorrect ETH amount sent to creator"
        );

        // Verify tokens distributed to recipient
        uint256 recipientTokenBalance = revolutionPointsEmitter.balanceOf(address(1));
        assertEq(recipientTokenBalance, tokensSold, "Recipient did not receive correct amount of tokens");
    }

    function testGetTokenPrice() public {
        vm.startPrank(address(0));

        vm.deal(address(0), 100000 ether);
        vm.stopPrank();

        int256 priceAfterManyPurchases = revolutionPointsEmitter.buyTokenQuote(1e18);

        // Simulate the passage of time
        uint256 daysElapsed = 221;
        vm.warp(block.timestamp + daysElapsed * 1 days);

        int256 priceAfterManyDays = revolutionPointsEmitter.buyTokenQuote(1e18);

        // Assert that the price is greater than zero
        assertGt(priceAfterManyDays, 0, "Price should never hit zero");
    }

    function testBuyTokenTotalVal() public {
        vm.startPrank(address(0));

        address[] memory recipients = new address[](1);
        recipients[0] = address(1);

        uint256[] memory bps = new uint256[](1);
        bps[0] = 10_000;

        vm.deal(address(0), 100000 ether);

        vm.stopPrank();
        // set setCreatorsAddress
        vm.prank(address(executor));
        revolutionPointsEmitter.setGrantsAddress(address(100));

        setUpWithDifferentRates(0, 0);

        vm.startPrank(address(0));

        revolutionPointsEmitter.buyToken{ value: 1e18 }(
            recipients,
            bps,
            IRevolutionPointsEmitter.ProtocolRewardAddresses({
                builder: address(0),
                purchaseReferral: address(0),
                deployer: address(0)
            })
        );

        // save treasury ETH balance
        uint256 treasuryEthBalance = address(revolutionPointsEmitter.owner()).balance;
        // save buyer token balance
        uint256 buyerTokenBalance = revolutionPointsEmitter.balanceOf(address(1));

        // save protocol fees
        uint256 protocolFees = (1e18 * 250) / 10_000;

        // convert token balances to ETH
        uint256 buyerTokenBalanceEth = uint256(revolutionPointsEmitter.buyTokenQuote(buyerTokenBalance));

        // Sent in ETH should be almost equal (account for precision/rounding) to total ETH plus token value in ETH
        assertGt(1e18 * 2, treasuryEthBalance + protocolFees + buyerTokenBalanceEth, "");
    }

    function testBuyingTwiceAmountIsNotMoreThanTwiceEmittedTokens() public {
        vm.startPrank(address(0));

        address[] memory recipients = new address[](1);
        recipients[0] = address(1);

        uint256[] memory bps = new uint256[](1);
        bps[0] = 10_000;

        revolutionPointsEmitter.buyToken{ value: 1e18 }(
            recipients,
            bps,
            IRevolutionPointsEmitter.ProtocolRewardAddresses({
                builder: address(0),
                purchaseReferral: address(0),
                deployer: address(0)
            })
        );
        uint256 firstAmount = revolutionPointsEmitter.balanceOf(address(1));

        revolutionPointsEmitter.buyToken{ value: 1e18 }(
            recipients,
            bps,
            IRevolutionPointsEmitter.ProtocolRewardAddresses({
                builder: address(0),
                purchaseReferral: address(0),
                deployer: address(0)
            })
        );
        uint256 secondAmountDifference = revolutionPointsEmitter.balanceOf(address(1)) - firstAmount;

        assert(secondAmountDifference <= 2 * revolutionPointsEmitter.totalSupply());
    }

    //if buyToken is called with payment 0, then it should revert with INVALID_PAYMENT()
    function test_revertNoPayment() public {
        vm.startPrank(address(0));

        address[] memory recipients = new address[](1);
        recipients[0] = address(1);

        uint256[] memory bps = new uint256[](1);
        bps[0] = 10_000;

        vm.expectRevert(abi.encodeWithSignature("INVALID_PAYMENT()"));
        revolutionPointsEmitter.buyToken{ value: 0 }(
            recipients,
            bps,
            IRevolutionPointsEmitter.ProtocolRewardAddresses({
                builder: address(0),
                purchaseReferral: address(1),
                deployer: address(0)
            })
        );
    }

    function test_correctEmitted(uint256 founderRateBps, uint256 entropyRateBps) public {
        // Assume valid rates
        vm.assume(founderRateBps > 0 && founderRateBps < 10000 && entropyRateBps < 10000);

        setUpWithDifferentRates(founderRateBps, entropyRateBps);

        vm.startPrank(revolutionPointsEmitter.owner());

        vm.stopPrank();

        vm.deal(address(this), 100000 ether);

        //expect balance to start out at 0
        assertEq(revolutionPoints.balanceOf(revolutionPointsEmitter.founderAddress()), 0, "Balance should start at 0");

        address[] memory recipients = new address[](1);
        recipients[0] = address(1);

        uint256[] memory bps = new uint256[](1);
        bps[0] = 10_000;

        //expect recipient0 balance to start out at 0
        assertEq(revolutionPoints.balanceOf(address(1)), 0, "Balance should start at 0");

        //get msg value remaining
        uint256 msgValueRemaining = 1 ether - revolutionPointsEmitter.computeTotalReward(1 ether);

        //Share of purchase amount to send to owner
        uint256 toPayOwner = (msgValueRemaining * (10_000 - founderRateBps)) / 10_000;

        //Ether directly sent to creators
        uint256 creatorDirectPayment = ((msgValueRemaining - toPayOwner) * entropyRateBps) / 10_000;

        //get expected tokens for creators
        int256 expectedAmountForCreators = revolutionPointsEmitter.getTokenQuoteForEther(
            msgValueRemaining - toPayOwner - creatorDirectPayment
        );

        //get expected tokens for recipient0
        int256 expectedAmountForRecipient0 = getTokenQuoteForEtherHelper(toPayOwner, expectedAmountForCreators);

        revolutionPointsEmitter.buyToken{ value: 1 ether }(
            recipients,
            bps,
            IRevolutionPointsEmitter.ProtocolRewardAddresses({
                builder: address(0),
                purchaseReferral: address(0),
                deployer: address(0)
            })
        );

        //assert that creatorsAddress balance is correct
        assertEq(
            uint(revolutionPoints.balanceOf(revolutionPointsEmitter.founderAddress())),
            uint(expectedAmountForCreators),
            "Creators should have correct balance"
        );

        // assert that recipient0 balance is correct
        assertEq(
            uint(revolutionPoints.balanceOf(address(1))),
            uint(expectedAmountForRecipient0),
            "Recipient0 should have correct balance"
        );
    }

    function test_BuyingFunctionBreaksAfterAPeriodOfTime(
        uint256 creatorRate,
        uint256 entropyRate,
        uint256 randomTime
    ) public {
        randomTime = bound(randomTime, 300 days, 700 days);
        // Assume valid rates
        vm.assume(creatorRate <= 10000 && entropyRate <= 10000);

        uint256 currentTime = 1702801400;

        // warp to a more realistic time
        vm.warp(block.timestamp + currentTime);

        setUpWithDifferentRates(creatorRate, entropyRate);

        vm.startPrank(address(executor));
        // Set creator and entropy rates
        assertEq(revolutionPointsEmitter.founderRateBps(), creatorRate, "Creator rate not set correctly");
        assertEq(revolutionPointsEmitter.founderEntropyRateBps(), entropyRate, "Entropy rate not set correctly");

        // Setup for buying token
        address[] memory recipients = new address[](1);
        recipients[0] = address(1); // recipient address

        uint256[] memory bps = new uint256[](1);
        bps[0] = 10000; // 100% of the tokens to the recipient

        uint256 valueToSend = 1 ether;

        // Perform token purchase
        vm.startPrank(address(this));
        uint256 tokensSold = revolutionPointsEmitter.buyToken{ value: valueToSend }(
            recipients,
            bps,
            IRevolutionPointsEmitter.ProtocolRewardAddresses({
                builder: address(0),
                purchaseReferral: address(0),
                deployer: address(0)
            })
        );
    }

    function _calculateBuyTokenPaymentShares(
        uint256 msgValueRemaining
    ) internal view returns (IRevolutionPointsEmitter.BuyTokenPaymentShares memory buyTokenPaymentShares) {
        // If rewards are expired, founder gets 0
        uint256 founderPortion = revolutionPointsEmitter.founderRateBps();

        if (block.timestamp > revolutionPointsEmitter.founderRewardsExpirationDate()) {
            founderPortion = 0;
        }

        // Calculate share of purchase amount reserved for buyers
        buyTokenPaymentShares.buyersGovernancePayment =
            msgValueRemaining -
            ((msgValueRemaining * founderPortion) / 10_000);

        // Calculate ether directly sent to founder
        buyTokenPaymentShares.founderDirectPayment =
            (msgValueRemaining * founderPortion * revolutionPointsEmitter.founderEntropyRateBps()) /
            10_000 /
            10_000;

        // Calculate ether spent on founder governance tokens
        buyTokenPaymentShares.founderGovernancePayment =
            ((msgValueRemaining * founderPortion) / 10_000) -
            buyTokenPaymentShares.founderDirectPayment;
    }

    // Test that founder rewards expire after a set expiration time
    function test_FounderRewardsExpireCorrectly(uint256 creatorRate, uint256 entropyRate) public {
        uint256 valueToSend = 1 ether;

        // Calculate value left after sharing protocol rewards
        uint256 msgValueRemaining = valueToSend - revolutionPointsEmitter.computeTotalReward(valueToSend);

        creatorRate = bound(creatorRate, 1, 10000);
        entropyRate = bound(entropyRate, 1, 10000);
        uint256 expiryDuration = 3650 days;
        // expiryDuration = bound(expiryDuration, 0, 3650 days); // Set expiry to 1 year from now, bounded to ensure it's within a valid range
        setUpWithDifferentRatesAndExpiry(creatorRate, entropyRate, block.timestamp + expiryDuration);

        address founderAddress = revolutionPointsEmitter.founderAddress();

        // Warp to just before the expiry
        vm.warp(block.timestamp + expiryDuration - 1 days);

        IRevolutionPointsEmitter.BuyTokenPaymentShares memory buyTokenPaymentSharesOg = _calculateBuyTokenPaymentShares(
            msgValueRemaining
        );

        vm.expectEmit(true, true, true, true);
        emit IRevolutionPointsEmitter.PurchaseFinalized(
            address(this),
            valueToSend,
            buyTokenPaymentSharesOg.buyersGovernancePayment + buyTokenPaymentSharesOg.founderGovernancePayment,
            valueToSend - msgValueRemaining,
            buyTokenPaymentSharesOg.buyersGovernancePayment > 0
                ? uint256(
                    revolutionPointsEmitter.getTokenQuoteForEther(buyTokenPaymentSharesOg.buyersGovernancePayment)
                )
                : 0,
            buyTokenPaymentSharesOg.founderGovernancePayment > 0
                ? uint256(
                    revolutionPointsEmitter.getTokenQuoteForEther(buyTokenPaymentSharesOg.founderGovernancePayment)
                )
                : 0,
            buyTokenPaymentSharesOg.founderDirectPayment
        );

        // Perform token purchase just before expiry
        performTokenPurchase(valueToSend);

        uint256 pointsBalanceBeforeExpiry = revolutionPoints.balanceOf(founderAddress);
        uint256 ethBalanceBeforeExpiry = address(founderAddress).balance;

        // Check founder balance just before expiry
        if (entropyRate < 10000) {
            assertGt(pointsBalanceBeforeExpiry, 0, "Founder should have points rewards before expiry");
        }
        assertGt(ethBalanceBeforeExpiry, 0, "Founder should have eth rewards before expiry");

        // Warp to just after the expiry
        vm.warp(block.timestamp + expiryDuration + 1 days);

        IRevolutionPointsEmitter.BuyTokenPaymentShares memory buyTokenPaymentShares = _calculateBuyTokenPaymentShares(
            msgValueRemaining
        );

        vm.expectEmit(true, true, true, true);
        emit IRevolutionPointsEmitter.PurchaseFinalized(
            address(this),
            valueToSend,
            buyTokenPaymentShares.buyersGovernancePayment + buyTokenPaymentShares.founderGovernancePayment,
            valueToSend - msgValueRemaining,
            uint256(revolutionPointsEmitter.getTokenQuoteForPayment(valueToSend)),
            0,
            0
        );

        // Perform token purchase just after expiry
        performTokenPurchase(valueToSend);

        assertEq(
            pointsBalanceBeforeExpiry,
            revolutionPoints.balanceOf(founderAddress),
            "Founder should not receive points rewards after expiry"
        );

        assertEq(
            ethBalanceBeforeExpiry,
            address(founderAddress).balance,
            "Founder should not receive eth rewards after expiry"
        );

        vm.expectEmit(true, true, true, true);
        emit IRevolutionPointsEmitter.PurchaseFinalized(
            address(this),
            valueToSend,
            buyTokenPaymentShares.buyersGovernancePayment + buyTokenPaymentShares.founderGovernancePayment,
            valueToSend - msgValueRemaining,
            uint256(revolutionPointsEmitter.getTokenQuoteForEther(msgValueRemaining)),
            0,
            0
        );

        // Perform token purchase just after expiry
        performTokenPurchase(valueToSend);
    }

    function performTokenPurchase(uint256 valueToSend) internal {
        address[] memory recipients = new address[](1);
        recipients[0] = address(1); // recipient address

        uint256[] memory bps = new uint256[](1);
        bps[0] = 10000; // 100% of the tokens to the recipient

        // Perform token purchase
        vm.startPrank(address(this));
        revolutionPointsEmitter.buyToken{ value: valueToSend }(
            recipients,
            bps,
            IRevolutionPointsEmitter.ProtocolRewardAddresses({
                builder: address(0),
                purchaseReferral: address(0),
                deployer: address(0)
            })
        );
        vm.stopPrank();
    }

    // Test that founder rewards expire after a set expiration time
    function test_FounderRewardsExpireForQuoteUtils(uint256 creatorRate, uint256 entropyRate) public {
        uint256 valueToSend = 1 ether;

        // Calculate value left after sharing protocol rewards
        uint256 msgValueRemaining = valueToSend - revolutionPointsEmitter.computeTotalReward(valueToSend);

        creatorRate = bound(creatorRate, 1, 10000);
        entropyRate = bound(entropyRate, 1, 10000);
        uint256 expiryDuration = 3650 days;
        // expiryDuration = bound(expiryDuration, 0, 3650 days); // Set expiry to 1 year from now, bounded to ensure it's within a valid range
        setUpWithDifferentRatesAndExpiry(creatorRate, entropyRate, block.timestamp + expiryDuration);

        // Warp to just before the expiry
        vm.warp(block.timestamp + expiryDuration - 1 days);

        IRevolutionPointsEmitter.BuyTokenPaymentShares memory buyTokenPaymentSharesOg = _calculateBuyTokenPaymentShares(
            msgValueRemaining
        );

        //expect getTokenQuoteForEther (buyergovernancepayment) == getTokenForPayment (valueToSend) since founder has rewards
        assertEq(
            buyTokenPaymentSharesOg.buyersGovernancePayment > 0
                ? uint256(
                    revolutionPointsEmitter.getTokenQuoteForEther(buyTokenPaymentSharesOg.buyersGovernancePayment)
                )
                : 0,
            uint256(revolutionPointsEmitter.getTokenQuoteForPayment(valueToSend))
        );

        // Warp to just after the expiry
        vm.warp(block.timestamp + expiryDuration + 1 days);

        IRevolutionPointsEmitter.BuyTokenPaymentShares memory buyTokenPaymentShares = _calculateBuyTokenPaymentShares(
            msgValueRemaining
        );

        //get token quote for ether doesn't account for founder rewards or protocol rewards
        //get token quote for payment accounts for founder rewards and protocol rewards

        assertEq(
            uint256(revolutionPointsEmitter.getTokenQuoteForEther(buyTokenPaymentShares.buyersGovernancePayment)),
            uint256(revolutionPointsEmitter.getTokenQuoteForEther(msgValueRemaining)),
            "Token quote for payment and ether should be equal for buyerGov payment"
        );

        //expect getTokenQuoteForEther (msgValueRemaining) ==  getTokenQuoteForPayment (valueToSend) since founder has no rewards
        assertEq(
            uint256(revolutionPointsEmitter.getTokenQuoteForPayment(valueToSend)),
            uint256(revolutionPointsEmitter.getTokenQuoteForEther(msgValueRemaining)),
            "Token quote for payment and ether should be equal"
        );
    }
}

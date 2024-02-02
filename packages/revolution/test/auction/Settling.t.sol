// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import { AuctionHouseTest } from "./AuctionHouse.t.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ICultureIndex } from "../../src/interfaces/ICultureIndex.sol";
import { IRevolutionToken } from "../../src/interfaces/IRevolutionToken.sol";
import { MockWETH } from "../mock/MockWETH.sol";
import { toDaysWadUnsafe } from "../../src/libs/SignedWadMath.sol";

contract AuctionHouseSettleTest is AuctionHouseTest {
    // Fallback function to allow contract to receive Ether
    receive() external payable {}

    function test__VotesCount(uint8 nDays) public {
        createDefaultArtPiece();
        createDefaultArtPiece();

        vm.roll(vm.getBlockNumber() + 1);

        auction.unpause();

        uint256 bidAmount = auction.reservePrice();
        vm.deal(address(11), bidAmount);
        vm.startPrank(address(11));
        auction.createBid{ value: bidAmount }(0, address(11), address(0)); // Assuming first auction's tokenId is 0
        vm.stopPrank();

        vm.warp(block.timestamp + auction.duration() + nDays); // Fast forward time to end the auction

        createDefaultArtPiece();
        auction.settleCurrentAndCreateNewAuction();
        vm.roll(vm.getBlockNumber() + 1);

        assertEq(revolutionToken.ownerOf(0), address(11), "Token should be transferred to the highest bidder");
        // cultureIndex currentVotes of highest bidder should be 10
        assertEq(
            cultureIndex.votingPower().getVotesWithWeights(address(11), 1, cultureIndex.tokenVoteWeight()),
            cultureIndex.tokenVoteWeight(),
            "Highest bidder should have 10 votes"
        );
    }

    function test__OwnerPayment(uint8 nDays) public {
        createDefaultArtPiece();
        createDefaultArtPiece();
        vm.roll(vm.getBlockNumber() + 1); // roll block number to enable voting snapshot

        auction.unpause();

        uint256 bidAmount = auction.reservePrice();
        vm.deal(address(11), bidAmount);
        vm.startPrank(address(11));
        auction.createBid{ value: bidAmount }(0, address(11), address(0)); // Assuming first auction's tokenId is 0
        vm.stopPrank();

        vm.warp(block.timestamp + auction.duration() + nDays); // Fast forward time to end the auction

        createDefaultArtPiece();
        auction.settleCurrentAndCreateNewAuction();
        vm.roll(vm.getBlockNumber() + 1);

        //calculate fee
        uint256 auctioneerPayment = (bidAmount * (10_000 - auction.creatorRateBps())) / 10_000;

        //amount spent on governance
        uint256 etherToSpendOnGovernanceTotal = (bidAmount * auction.creatorRateBps()) /
            10_000 -
            (bidAmount * (auction.entropyRateBps() * auction.creatorRateBps())) /
            10_000 /
            10_000;

        uint256 feeAmount = revolutionPointsEmitter.computeTotalReward(etherToSpendOnGovernanceTotal);

        uint256 msgValueRemaining = etherToSpendOnGovernanceTotal - feeAmount;

        uint256 pointsEmitterValueGrants = (msgValueRemaining * revolutionPointsEmitter.grantsRateBps()) / 10_000;
        uint256 pointsEmitterValueGrantsDirect = (pointsEmitterValueGrants * revolutionPointsEmitter.entropyRateBps()) /
            10_000;
        uint256 pointsEmitterValueGrantsGov = pointsEmitterValueGrants - pointsEmitterValueGrantsDirect;

        uint256 pointsEmitterValueOwner = msgValueRemaining - pointsEmitterValueGrants;

        assertEq(
            address(executor).balance,
            auctioneerPayment + pointsEmitterValueOwner + pointsEmitterValueGrantsGov,
            "Bid amount minus entropy should be transferred to the auction house owner"
        );
    }

    function test__SettlingAuctionWithNoBids(uint8 nDays) public {
        uint256 tokenId = createDefaultArtPiece();
        createDefaultArtPiece();
        vm.roll(vm.getBlockNumber() + 1); // roll block number to enable voting snapshot

        auction.unpause();

        vm.warp(block.timestamp + auction.duration() + nDays); // Fast forward time to end the auction

        // Assuming revolutionToken.burn is called for auctions with no bids
        vm.expectEmit(true, true, true, true);
        emit IRevolutionToken.RevolutionTokenBurned(tokenId);

        auction.settleCurrentAndCreateNewAuction();
    }

    function test__SettlingAuctionPrematurely() public {
        createDefaultArtPiece();
        createDefaultArtPiece();

        vm.roll(vm.getBlockNumber() + 1); // roll block number to enable voting snapshot

        auction.unpause();

        vm.expectRevert();
        auction.settleAuction(); // Attempt to settle before the auction ends
    }

    function test__TransferFailureAndFallbackToWETH(uint256 amount) public {
        vm.assume(amount > revolutionPointsEmitter.minPurchaseAmount());
        vm.assume(amount > auction.reservePrice());
        vm.assume(amount < revolutionPointsEmitter.maxPurchaseAmount());

        createDefaultArtPiece();
        createDefaultArtPiece();
        vm.roll(vm.getBlockNumber() + 1); // roll block number to enable voting snapshot

        auction.unpause();

        address recipient = address(new ContractThatRejectsEther());

        auction.transferOwnership(recipient);

        vm.startPrank(address(auction));

        vm.deal(address(auction), amount);
        auction.createBid{ value: amount }(0, address(this), address(0)); // Assuming first auction's tokenId is 0

        // Initially, recipient should have 0 ether and 0 WETH
        assertEq(recipient.balance, 0);
        assertEq(IERC20(address(weth)).balanceOf(recipient), 0);

        //go in future
        vm.warp(block.timestamp + auction.duration() + 1); // Fast forward time to end the auction

        auction.settleCurrentAndCreateNewAuction();

        // Check if the recipient received WETH instead of Ether
        uint256 creatorRate = auction.creatorRateBps();
        assertEq(IERC20(address(weth)).balanceOf(recipient), (amount * (10_000 - creatorRate)) / 10_000);
        assertEq(recipient.balance, 0); // Ether balance should still be 0
        //make sure voting weight on culture index is 721 vote weight for winning bidder
        assertEq(
            cultureIndex.votingPower().getVotesWithWeights(address(this), 1, cultureIndex.tokenVoteWeight()),
            cultureIndex.tokenVoteWeight(),
            "Highest bidder should have 10 votes"
        );
    }

    function test__TransferToEOA() public {
        createDefaultArtPiece();
        createDefaultArtPiece();
        vm.roll(vm.getBlockNumber() + 1); // roll block number to enable voting snapshot

        auction.unpause();

        address recipient = address(0x123); // Some EOA address
        uint256 amount = 1 ether;

        auction.transferOwnership(recipient);

        vm.startPrank(address(auction));
        vm.deal(address(auction), amount);
        auction.createBid{ value: amount }(0, address(this), address(0)); // Assuming first auction's tokenId is 0

        // Initially, recipient should have 0 ether
        assertEq(recipient.balance, 0);

        //go in future
        vm.warp(block.timestamp + auction.duration() + 1); // Fast forward time to end the auction

        auction.settleCurrentAndCreateNewAuction();

        // Check if the recipient received Ether
        uint256 creatorRate = auction.creatorRateBps();
        assertEq(recipient.balance, (amount * (10_000 - creatorRate)) / 10_000);
        //make sure voting weight on culture index is 721 vote weight for winning bidder
        assertEq(
            cultureIndex.votingPower().getVotesWithWeights(address(this), 1, cultureIndex.tokenVoteWeight()),
            cultureIndex.tokenVoteWeight(),
            "Highest bidder should have 10 votes"
        );
    }

    function test__TransferToContractWithoutReceiveOrFallback(uint256 amount) public {
        vm.assume(amount > revolutionPointsEmitter.minPurchaseAmount());
        vm.assume(amount > auction.reservePrice());
        vm.assume(amount < revolutionPointsEmitter.maxPurchaseAmount());

        createDefaultArtPiece();
        createDefaultArtPiece();
        vm.roll(vm.getBlockNumber() + 1); // roll block number to enable voting snapshot

        auction.unpause();

        address recipient = address(new ContractWithoutReceiveOrFallback());

        auction.transferOwnership(recipient);

        vm.startPrank(address(auction));

        vm.deal(address(auction), amount);
        auction.createBid{ value: amount }(0, address(this), address(0)); // Assuming first auction's tokenId is 0

        // Initially, recipient should have 0 ether and 0 WETH
        assertEq(recipient.balance, 0);
        assertEq(IERC20(address(weth)).balanceOf(recipient), 0);

        //go in future
        vm.warp(block.timestamp + auction.duration() + 1); // Fast forward time to end the auction

        auction.settleCurrentAndCreateNewAuction();

        // Check if the recipient received WETH instead of Ether
        uint256 creatorRate = auction.creatorRateBps();

        assertEq(IERC20(address(weth)).balanceOf(recipient), (amount * (10_000 - creatorRate)) / 10_000);
        assertEq(recipient.balance, 0); // Ether balance should still be 0
        //make sure voting weight on culture index is 721 vote weight for winning bidder
        assertEq(
            cultureIndex.votingPower().getVotesWithWeights(address(this), 1, cultureIndex.tokenVoteWeight()),
            cultureIndex.tokenVoteWeight(),
            "Highest bidder should have 10 votes"
        );
    }

    function getTokenQuoteForEtherHelper(uint256 etherAmount, int256 supply) public view returns (int gainedX) {
        // Note: By using toDaysWadUnsafe(block.timestamp - startTime) we are establishing that 1 "unit of time" is 1 day.
        // solhint-disable-next-line not-rely-on-time
        return
            revolutionPointsEmitter.vrgda().yToX({
                timeSinceStart: toDaysWadUnsafe(block.timestamp - revolutionPointsEmitter.startTime()),
                sold: supply,
                amount: int(etherAmount)
            });
    }

    function getCreatorGovernancePayoutHelper(uint bidAmount) public returns (uint) {
        // Ether going to owner of the auction
        uint256 auctioneerPayment = (bidAmount * (10_000 - auction.creatorRateBps())) / 10_000;

        //Total amount of ether going to creator
        uint256 creatorsAuctionShare = bidAmount - auctioneerPayment;
        uint256 ethPaidToCreators = (creatorsAuctionShare * auction.entropyRateBps()) / (10_000);
        // uint256 ethPaidToCreators = 0;
        // for (uint256 i = 0; i < numCreators; i++) {
        //     uint256 paymentAmount = (entropyRateAmount * creators[i].bps) / (10_000 * 10_000);
        //     ethPaidToCreators += paymentAmount;
        // }

        //amount to buy creators governance with
        uint256 creatorPointsEther = (creatorsAuctionShare - ethPaidToCreators);

        uint256 msgValueRemaining = creatorPointsEther - revolutionPointsEmitter.computeTotalReward(creatorPointsEther);

        uint256 grantsShare = (msgValueRemaining * revolutionPointsEmitter.grantsRateBps()) / 10_000;
        uint256 buyersShare = msgValueRemaining - grantsShare;
        uint256 grantsDirectPayment = (grantsShare * revolutionPointsEmitter.entropyRateBps()) / 10_000;
        uint256 grantsGovernancePayment = grantsShare - grantsDirectPayment;

        int256 expectedGrantsGovernanceTokenPayout = revolutionPointsEmitter.getTokenQuoteForEther(
            grantsGovernancePayment
        );

        return uint256(getTokenQuoteForEtherHelper(buyersShare, expectedGrantsGovernanceTokenPayout));
    }

    //assuming dao owns both auction and revolutionPointsEmitter
    function getDAOPayout(uint bidAmount) public returns (uint) {
        // Ether going to owner of the auction
        uint256 auctioneerPayment = (bidAmount * (10_000 - auction.creatorRateBps())) / 10_000;

        //Total amount of ether going to creator
        uint256 creatorsAuctionShare = bidAmount - auctioneerPayment;

        uint256 creatorPointsEther = (creatorsAuctionShare * (10_000 - auction.entropyRateBps())) / 10_000;

        uint256 msgValueRemaining = creatorPointsEther - revolutionPointsEmitter.computeTotalReward(creatorPointsEther);

        uint256 grantsShare = (msgValueRemaining * revolutionPointsEmitter.grantsRateBps()) / 10_000;
        uint256 buyersShare = msgValueRemaining - grantsShare;
        uint256 grantsDirectPayment = grantsShare;
        uint256 grantsGovernancePayment = grantsShare - grantsDirectPayment;

        return auctioneerPayment + grantsGovernancePayment + buyersShare;
    }

    function getGrantsDirectPayment(uint bidAmount) public returns (uint) {
        uint256 creatorsAuctionShare = (bidAmount * auction.creatorRateBps()) / 10_000;
        uint256 creatorsGovernancePayment = (creatorsAuctionShare * (10_000 - auction.entropyRateBps())) / 10_000;

        uint256 msgValueRemaining = creatorsGovernancePayment -
            revolutionPointsEmitter.computeTotalReward(creatorsGovernancePayment);

        uint256 grantsShare = (msgValueRemaining * revolutionPointsEmitter.grantsRateBps()) / 10_000;
        uint256 buyersShare = msgValueRemaining - grantsShare;
        return (grantsShare * revolutionPointsEmitter.entropyRateBps()) / 10_000;
    }

    function test__SettlingAuctionWithMultipleCreators(uint8 nCreators) public {
        vm.stopPrank();
        vm.assume(nCreators > 0);
        vm.assume(nCreators < cultureIndex.MAX_NUM_CREATORS());

        address[] memory creatorAddresses = new address[](nCreators);
        uint256[] memory creatorBps = new uint256[](nCreators);
        uint256 totalBps = 0;

        // Assume n creators with equal share
        for (uint256 i = 0; i < nCreators; i++) {
            creatorAddresses[i] = address(uint160(i + 1)); // Example creator addresses
            if (i == nCreators - 1) {
                creatorBps[i] = 10_000 - totalBps;
            } else {
                creatorBps[i] = (10_000) / (nCreators - 1);
            }

            totalBps += creatorBps[i];
        }

        //mint points
        vm.prank(address(revolutionPointsEmitter));
        revolutionPoints.mint(address(this), 1000);
        vm.roll(vm.getBlockNumber() + 1);

        uint256 oldPieceId = createDefaultArtPiece();

        //mint 1 more token
        vm.prank(address(revolutionPointsEmitter));
        revolutionPoints.mint(address(this), 1000);
        vm.roll(vm.getBlockNumber() + 1);

        uint256 pieceId = createArtPieceMultiCreator(
            "Multi Creator Art",
            "An art piece with multiple creators",
            ICultureIndex.MediaType.IMAGE,
            "ipfs://multi-creator-art",
            "",
            "",
            creatorAddresses,
            creatorBps
        );

        vm.roll(vm.getBlockNumber() + 1); // roll block number to enable voting snapshot

        //mint tokens and vote for piece
        vm.prank(address(this));
        cultureIndex.vote(pieceId);
        cultureIndex.vote(oldPieceId);

        vm.prank(address(executor));
        auction.unpause();

        vm.deal(address(21_000), auction.reservePrice() + 1 ether);
        vm.startPrank(address(21_000));
        auction.createBid{ value: auction.reservePrice() }(0, address(21_000), address(0));
        vm.stopPrank();

        vm.warp(block.timestamp + auction.duration() + 1); // Fast forward time to end the auction

        // Track balances before auction settlement
        uint256[] memory balancesBefore = new uint256[](creatorAddresses.length);
        uint256[] memory mockWETHBalancesBefore = new uint256[](creatorAddresses.length);
        uint256[] memory governanceTokenBalancesBefore = new uint256[](creatorAddresses.length);
        for (uint256 i = 0; i < creatorAddresses.length; i++) {
            balancesBefore[i] = address(creatorAddresses[i]).balance;
            governanceTokenBalancesBefore[i] = revolutionPoints.balanceOf(creatorAddresses[i]);
            mockWETHBalancesBefore[i] = MockWETH(payable(weth)).balanceOf(creatorAddresses[i]);
        }

        uint256 expectedGovernanceTokenPayout = getCreatorGovernancePayoutHelper(auction.reservePrice());

        auction.settleCurrentAndCreateNewAuction();

        //assert auctionHouse balance is 0
        assertEq(address(auction).balance, 0);

        // Verify each creator's payout
        for (uint256 i = 0; i < creatorAddresses.length; i++) {
            uint256 expectedEtherShare = uint256(
                ((auction.reservePrice()) * creatorBps[i] * auction.creatorRateBps()) / 10_000 / 10_000
            );

            //either the creator gets ETH or WETH
            assertEq(
                address(creatorAddresses[i]).balance - balancesBefore[i] > 0
                    ? address(creatorAddresses[i]).balance - balancesBefore[i]
                    : MockWETH(payable(weth)).balanceOf(creatorAddresses[i]) - mockWETHBalancesBefore[i],
                (expectedEtherShare * auction.entropyRateBps()) / 10_000,
                "Incorrect ETH payout for creator"
            );

            assertEq(
                revolutionPoints.balanceOf(creatorAddresses[i]) - governanceTokenBalancesBefore[i],
                uint256((expectedGovernanceTokenPayout * creatorBps[i]) / 10_000),
                "Incorrect governance token payout for creator"
            );
        }

        // Verify ownership of the token
        assertEq(revolutionToken.ownerOf(0), address(21_000), "Token should be transferred to the highest bidder");
        // Verify voting weight on culture index is 721 vote weight for winning bidder
        assertEq(
            cultureIndex.votingPower().getVotesWithWeights(address(21_000), 1, cultureIndex.tokenVoteWeight()),
            cultureIndex.tokenVoteWeight(),
            "Highest bidder should have 10 votes"
        );
    }

    function test__SettlingAuctionWithWinningBidAndCreatorPayout(uint256 bidAmount) public {
        vm.assume(bidAmount > revolutionPointsEmitter.minPurchaseAmount());
        vm.assume(bidAmount > auction.reservePrice());
        vm.assume(bidAmount < revolutionPointsEmitter.maxPurchaseAmount());

        uint256 tokenId = createArtPiece(
            "Art Piece",
            "A new art piece",
            ICultureIndex.MediaType.IMAGE,
            "ipfs://image",
            "",
            "",
            address(0x1),
            10_000
        );
        vm.roll(vm.getBlockNumber() + 1); // roll block number to enable voting snapshot

        auction.unpause();

        vm.deal(address(21_000), bidAmount);
        vm.startPrank(address(21_000));
        auction.createBid{ value: bidAmount }(tokenId, address(21_000), address(0));
        vm.stopPrank();

        vm.warp(block.timestamp + auction.duration() + 1); // Fast forward time to end the auction

        // Track ETH balances
        uint256 balanceBeforeCreator = address(0x1).balance;
        uint256 balanceBeforeOwner = address(dao).balance;

        uint256 expectedGovernanceTokens = getCreatorGovernancePayoutHelper(bidAmount);

        //create default art piece and roll
        createDefaultArtPiece();
        vm.roll(vm.getBlockNumber() + 1);

        auction.settleCurrentAndCreateNewAuction();

        // Ether going to owner of the auction
        uint256 auctioneerPayment = (bidAmount * (10_000 - auction.creatorRateBps())) / 10_000;

        //Total amount of ether going to creator
        uint256 creatorsShare = bidAmount - auctioneerPayment;

        uint256 creatorsDirectPayment = (creatorsShare * (auction.entropyRateBps())) / 10_000;

        uint256 creatorsGovernancePayment = creatorsShare - creatorsDirectPayment;

        // Checking if the creator received their share
        assertEq(
            address(0x1).balance - balanceBeforeCreator,
            creatorsDirectPayment,
            "Creator did not receive the correct amount of ETH"
        );

        uint256 expectedGrantsDirectPayout = getGrantsDirectPayment(bidAmount);

        assertApproxEqAbs(
            address(revolutionPointsEmitter.creatorsAddress()).balance,
            expectedGrantsDirectPayout,
            // "Grants address did not receive the correct amount of ETH"
            10
        );

        assertApproxEqAbs(
            address(executor).balance - balanceBeforeOwner,
            getDAOPayout(bidAmount),
            10
            // "Owner did not receive the correct amount of ETH"
        );

        assertEq(
            revolutionToken.ownerOf(tokenId),
            address(21_000),
            "Token should be transferred to the highest bidder"
        );
        // Checking voting weight on culture index is 721 vote weight for winning bidder
        assertEq(
            cultureIndex.votingPower().getVotesWithWeights(address(21_000), 1, cultureIndex.tokenVoteWeight()),
            cultureIndex.tokenVoteWeight(),
            "Highest bidder should have 10 votes"
        );

        assertEq(
            revolutionPoints.balanceOf(address(0x1)),
            expectedGovernanceTokens,
            "Creator did not receive the correct amount of governance tokens"
        );
    }

    function test__EntropyPecentCannotLeadToDos(uint256 bidAmount) public {
        //set entropy to 9999
        auction.setEntropyRateBps(9999);

        // Ensure bidAmount is within bounds to make creatorGovernancePayment <= minPurchaseAmount
        uint256 minPurchaseAmount = revolutionPointsEmitter.minPurchaseAmount();
        uint256 minCreatorsShare = (minPurchaseAmount * 10_000) / (10_000 - auction.entropyRateBps());

        uint256 maxBidAmount = minCreatorsShare / (1 - (10_000 - auction.creatorRateBps()) / 10_000);

        bidAmount = bound(bidAmount, 1, maxBidAmount);

        // Ether going to owner of the auction
        uint256 auctioneerPayment = (bidAmount * (10_000 - auction.creatorRateBps())) / 10_000;

        //set reserve price to the bid amount
        auction.setReservePrice(bidAmount);

        // create 2 art pieces
        uint256 pieceId = createDefaultArtPiece();
        createDefaultArtPiece();

        // roll block number to enable voting snapshot
        vm.roll(vm.getBlockNumber() + 1);

        //deal alice some eth
        address alice = vm.addr(uint256(1001));
        vm.deal(alice, bidAmount);

        // start the first auction
        auction.unpause();
        vm.stopPrank();

        // have alice create a  bid
        vm.prank(alice);
        auction.createBid{ value: bidAmount }(0, alice, address(0));

        // warp to the end of the auction
        (, , , uint256 endTime, , , ) = auction.auction();
        vm.warp(endTime + 1);

        // create a new auction
        auction.settleCurrentAndCreateNewAuction();

        //ensure creator got no governance, but got ETH
        address creator = cultureIndex.getPieceById(pieceId).creators[0].creator;

        assertEq(revolutionPoints.balanceOf(creator), 0);

        //Total amount of ether going to creator
        uint256 creatorsShare = bidAmount - auctioneerPayment;

        assertEq(creator.balance, creatorsShare);
    }

    function test__SettleAuctionZeroEntropyRate() public {
        // set entropy rate to 0
        auction.setEntropyRateBps(0);

        createDefaultArtPiece();
        createDefaultArtPiece();
        vm.roll(vm.getBlockNumber() + 1); // roll block number to enable voting snapshot

        auction.unpause();

        address recipient = address(0x123); // Some EOA address
        uint256 amount = 1 ether;

        vm.startPrank(address(auction));
        vm.deal(address(auction), amount);
        auction.createBid{ value: amount }(0, address(this), address(0)); // Assuming first auction's tokenId is 0
        //go in future
        vm.warp(block.timestamp + auction.duration() + 1); // Fast forward time to end the auction

        auction.settleCurrentAndCreateNewAuction();
    }

    function test__RevertTopVotedPieceMeetsQuorum() public {
        vm.stopPrank();
        uint256 pointsSupply = 1000;

        vm.startPrank(address(revolutionPointsEmitter));
        revolutionPoints.mint(address(this), pointsSupply);
        vm.roll(vm.getBlockNumber() + 1);

        uint256 pieceId = createDefaultArtPiece();

        // Cast votes
        vm.startPrank(address(this));
        cultureIndex.vote(pieceId);

        // Mint token and govTokens, create a new piece and check fields
        vm.startPrank(address(executor));
        vm.roll(vm.getBlockNumber() + 1);

        auction.unpause();

        ICultureIndex.ArtPiece memory newPiece = cultureIndex.getPieceById(pieceId);
        vm.roll(vm.getBlockNumber() + 1);

        uint256 expectedTotalVotesSupply = pointsSupply;

        uint256 expectedQuorumVotes = (cultureIndex.quorumVotesBPS() * (expectedTotalVotesSupply)) / 10_000;
        assertEq(
            cultureIndex.quorumVotesForPiece(newPiece.pieceId),
            expectedQuorumVotes,
            "Quorum votes should be set correctly on creation"
        );

        // create art piece and vote for it again
        uint256 pieceId2 = createDefaultArtPiece();

        // roll
        vm.roll(vm.getBlockNumber() + 1);

        bool meetsQuorum = cultureIndex.topVotedPieceMeetsQuorum();
        assertTrue(!meetsQuorum, "Top voted piece should not meet quorum");

        // Cast votes
        vm.startPrank(address(this));
        cultureIndex.vote(pieceId2);

        // roll
        vm.roll(vm.getBlockNumber() + 1);

        meetsQuorum = cultureIndex.topVotedPieceMeetsQuorum();
        assertTrue(meetsQuorum, "Top voted piece should meet quorum");
    }

    function test_CreateAuctionWithoutSettle() public {
        vm.stopPrank();
        // mint points
        vm.prank(address(revolutionPointsEmitter));
        revolutionPoints.mint(address(this), 1000);

        vm.roll(vm.getBlockNumber() + 1);

        uint256 tokenId = createDefaultArtPiece();
        createDefaultArtPiece();

        //vote for tokenId
        vm.prank(address(this));
        cultureIndex.vote(tokenId);

        // roll
        vm.roll(vm.getBlockNumber() + 1);

        // Unpause the auction
        vm.prank(address(executor));
        auction.unpause();

        // warp to the end
        vm.warp(block.timestamp + auction.duration() + 1);

        //create and settle and expect revert
        vm.expectRevert(abi.encodeWithSignature("QUORUM_NOT_MET()"));
        auction.settleCurrentAndCreateNewAuction();

        // ensure auction is not paused and auction is not settled
        assertEq(auction.paused(), false, "Auction house should not be paused");

        (, , , , , , bool settled) = auction.auction();

        // Check that auction is not created
        assertEq(settled, false, "Auction should not be settled");
    }
}

contract ContractWithoutReceiveOrFallback {
    // This contract intentionally does not have receive() or fallback()
    // functions to test the behavior of sending Ether to such a contract.
}

contract ContractThatRejectsEther {
    // This contract has a receive() function that reverts any Ether transfers.
    receive() external payable {
        revert("Rejecting Ether transfer");
    }

    // Alternatively, you could use a fallback function that reverts.
    // fallback() external payable {
    //     revert("Rejecting Ether transfer");
    // }
}

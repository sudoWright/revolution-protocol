// SPDX-License-Identifier: GPL-3.0

/// @title Interface for Revolution Auction Houses

/*********************************
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░█████████░░█████████░░░ *
 * ░░░░░░██░░░████░░██░░░████░░░ *
 * ░░██████░░░████████░░░████░░░ *
 * ░░██░░██░░░████░░██░░░████░░░ *
 * ░░██░░██░░░████░░██░░░████░░░ *
 * ░░░░░░█████████░░█████████░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 * ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ *
 *********************************/

pragma solidity ^0.8.22;

import { IUpgradeManager } from "@cobuild/utility-contracts/src/interfaces/IUpgradeManager.sol";

interface IBaseContestEvents {
    event WinnerPaid(
        uint256 indexed pieceId,
        address[] winners,
        uint256 amount,
        uint256 protocolRewardsAmount,
        uint256 payoutSplit,
        uint256 payoutIndex
    );

    event EntropyRateUpdated(uint256 rate);
}

interface IBaseContest is IBaseContestEvents {
    ///                                                          ///
    ///                           ERRORS                         ///
    ///                                                          ///

    /// @dev Reverts if the function caller is not the manager.
    error NOT_MANAGER();

    /// @dev Reverts if address 0 is passed but not allowed
    error ADDRESS_ZERO();

    /// @dev Reverts if > PERCENTAGE_SCALE
    error INVALID_ENTROPY_RATE();

    /// @dev Reverts if the top voted piece does not meet quorum.
    error QUORUM_NOT_MET();

    /// @dev Reverts if the contest has already been paid out
    error CONTEST_ALREADY_PAID_OUT();

    /// @dev Reverts if the contest has not ended
    error CONTEST_NOT_ENDED();

    /// @dev Reverts if payout splits do not sum to PERCENTAGE_SCALE
    error INVALID_PAYOUT_SPLITS();

    /// @dev Reverts if payoutSplits are not descending
    error PAYOUT_SPLITS_NOT_DESCENDING();

    /// @dev Reverts if trying to payout contest with no balance
    error NO_BALANCE_TO_PAYOUT();

    /// @dev Reverts if trying to payout with no winners specified
    error NO_COUNT_SPECIFIED();

    /// @dev Reverts if no balance to withdraw
    error NO_BALANCE_TO_WITHDRAW();

    function setEntropyRate(uint256 _entropyRate) external;

    function WETH() external view returns (address);

    function manager() external returns (IUpgradeManager);

    function unpause() external;

    function pause() external;

    function getPayoutSplits() external view returns (uint256[] memory);

    function getPayoutSplitsCount() external view returns (uint256);

    function startTime() external view returns (uint256);

    function endTime() external view returns (uint256);

    /// @notice The contest parameters
    /// @param entropyRate The entropy rate of each contest - the portion of the creator's share that is directly sent to the creator in ETH
    /// @param endTime The end time of the contest.
    /// @param startTime The start time of the contest.
    /// @param payoutSplits How to split the prize pool between the winners
    struct BaseContestParams {
        uint256 entropyRate;
        uint256 startTime;
        uint256 endTime;
        uint256[] payoutSplits;
    }

    /**
     * @notice Initialize the auction house and base contracts.
     * @param initialOwner The address of the owner.
     * @param splitMain The address of the SplitMain splits creator contract.
     * @param cultureIndex The address of the CultureIndex contract holding submissions.
     * @param builderReward The address of the account to receive builder rewards.
     * @param weth The address of the WETH contract.
     * @param contestParams The auction params for auctions.
     */
    function initialize(
        address initialOwner,
        address splitMain,
        address cultureIndex,
        address builderReward,
        address weth,
        BaseContestParams calldata contestParams
    ) external;
}

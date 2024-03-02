// This file is automatically generated by code; do not manually update
// Last updated on 2024-03-02T21:24:30.853Z
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.22;

import { IVersionedContract } from "@cobuild/utility-contracts/src/interfaces/IVersionedContract.sol";

/// @title RevolutionVersion
/// @notice Base contract for versioning contracts
contract RevolutionVersion is IVersionedContract {
    /// @notice The version of the contract
    function contractVersion() external pure override returns (string memory) {
        return "0.4.6";
    }
}

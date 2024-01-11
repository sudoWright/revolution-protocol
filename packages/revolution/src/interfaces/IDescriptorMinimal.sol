// SPDX-License-Identifier: GPL-3.0

/// @title Common interface for Descriptor versions, as used by RevolutionToken

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

import { IArtRace } from "./IArtRace.sol";

interface IDescriptorMinimal {
    ///
    /// USED BY TOKEN
    ///

    function tokenURI(uint256 tokenId, IArtRace.ArtPieceMetadata memory metadata) external view returns (string memory);

    function dataURI(uint256 tokenId, IArtRace.ArtPieceMetadata memory metadata) external view returns (string memory);
}

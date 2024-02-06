// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import { Test } from "forge-std/Test.sol";
import { CultureIndex } from "../../src/culture-index/CultureIndex.sol";
import { MockERC20 } from "../mock/MockERC20.sol";
import { ICultureIndex, ICultureIndexEvents } from "../../src/interfaces/ICultureIndex.sol";
import { RevolutionPoints } from "../../src/RevolutionPoints.sol";
import { RevolutionBuilderTest } from "../RevolutionBuilder.t.sol";
import { ERC721CheckpointableUpgradeable } from "../../src/base/ERC721CheckpointableUpgradeable.sol";

/**
 * @title CultureIndex Required Data Test
 * @dev Test contract for CultureIndex
 */
contract CultureIndexRequiredDataTest is RevolutionBuilderTest {
    /**
     * @dev Setup function for each test case
     */
    function setUp() public virtual override {
        super.setUp();
        super.setMockParams();
    }

    function createSvg() public {
        createArtPiece(
            "Mona Lisa",
            "A masterpiece",
            ICultureIndex.MediaType.IMAGE,
            "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiIgc2hhcGUtcmVuZGVyaW5nPSJjcmlzcEVkZ2VzIiB4bWxuczp2PSJodHRwczovL3ZlY3RhLmlvL25hbm8iPjxzdHlsZT48IVtDREFUQVsuQntmaWxsOiNmZmZ9LkN7ZmlsbDojNjYzOTMxfV1dPjwvc3R5bGU+PGcgY2xhc3M9IkIiPjxwYXRoIGQ9Ik0wIDBoMXYxSDB6Ii8+PHBhdGggZD0iTTEgMGgxdjFIMXoiLz48cGF0aCBkPSJNMiAwaDF2MUgyeiIvPjxwYXRoIGQ9Ik0zIDBoMXYxSDN6Ii8+PHBhdGggZD0iTTQgMGgxdjFINHoiLz48cGF0aCBkPSJNNSAwaDF2MUg1eiIvPjxwYXRoIGQ9Ik02IDBoMXYxSDZ6Ii8+PHBhdGggZD0iTTcgMGgxdjFIN3oiLz48cGF0aCBkPSJNOCAwaDF2MUg4eiIvPjxwYXRoIGQ9Ik05IDBoMXYxSDl6Ii8+PHBhdGggZD0iTTEwIDBoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xMSAwaDF2MWgtMXoiLz48cGF0aCBkPSJNMTIgMGgxdjFoLTF6Ii8+PHBhdGggZD0iTTEzIDBoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNCAwaDF2MWgtMXoiLz48cGF0aCBkPSJNMTUgMGgxdjFoLTF6Ii8+PHBhdGggZD0iTTE2IDBoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNyAwaDF2MWgtMXoiLz48cGF0aCBkPSJNMTggMGgxdjFoLTF6Ii8+PHBhdGggZD0iTTE5IDBoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMCAwaDF2MWgtMXoiLz48cGF0aCBkPSJNMjEgMGgxdjFoLTF6Ii8+PHBhdGggZD0iTTIyIDBoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMyAwaDF2MWgtMXoiLz48cGF0aCBkPSJNMjQgMGgxdjFoLTF6Ii8+PHBhdGggZD0iTTI1IDBoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNiAwaDF2MWgtMXoiLz48cGF0aCBkPSJNMjcgMGgxdjFoLTF6Ii8+PHBhdGggZD0iTTI4IDBoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yOSAwaDF2MWgtMXoiLz48cGF0aCBkPSJNMzAgMGgxdjFoLTF6Ii8+PHBhdGggZD0iTTMxIDBoMXYxaC0xek0wIDFoMXYxSDB6Ii8+PHBhdGggZD0iTTEgMWgxdjFIMXoiLz48cGF0aCBkPSJNMiAxaDF2MUgyeiIvPjxwYXRoIGQ9Ik0zIDFoMXYxSDN6Ii8+PHBhdGggZD0iTTQgMWgxdjFINHoiLz48cGF0aCBkPSJNNSAxaDF2MUg1eiIvPjxwYXRoIGQ9Ik02IDFoMXYxSDZ6Ii8+PHBhdGggZD0iTTcgMWgxdjFIN3oiLz48cGF0aCBkPSJNOCAxaDF2MUg4eiIvPjxwYXRoIGQ9Ik05IDFoMXYxSDl6Ii8+PHBhdGggZD0iTTEwIDFoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xMSAxaDF2MWgtMXoiLz48cGF0aCBkPSJNMTIgMWgxdjFoLTF6Ii8+PHBhdGggZD0iTTEzIDFoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNCAxaDF2MWgtMXoiLz48cGF0aCBkPSJNMTUgMWgxdjFoLTF6Ii8+PHBhdGggZD0iTTE2IDFoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNyAxaDF2MWgtMXoiLz48cGF0aCBkPSJNMTggMWgxdjFoLTF6Ii8+PHBhdGggZD0iTTE5IDFoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMCAxaDF2MWgtMXoiLz48cGF0aCBkPSJNMjEgMWgxdjFoLTF6Ii8+PHBhdGggZD0iTTIyIDFoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMyAxaDF2MWgtMXoiLz48cGF0aCBkPSJNMjQgMWgxdjFoLTF6Ii8+PHBhdGggZD0iTTI1IDFoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNiAxaDF2MWgtMXoiLz48cGF0aCBkPSJNMjcgMWgxdjFoLTF6Ii8+PHBhdGggZD0iTTI4IDFoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yOSAxaDF2MWgtMXoiLz48cGF0aCBkPSJNMzAgMWgxdjFoLTF6Ii8+PHBhdGggZD0iTTMxIDFoMXYxaC0xek0wIDJoMXYxSDB6Ii8+PHBhdGggZD0iTTEgMmgxdjFIMXoiLz48cGF0aCBkPSJNMiAyaDF2MUgyeiIvPjxwYXRoIGQ9Ik0zIDJoMXYxSDN6Ii8+PHBhdGggZD0iTTQgMmgxdjFINHoiLz48cGF0aCBkPSJNNSAyaDF2MUg1eiIvPjxwYXRoIGQ9Ik02IDJoMXYxSDZ6Ii8+PHBhdGggZD0iTTcgMmgxdjFIN3oiLz48cGF0aCBkPSJNOCAyaDF2MUg4eiIvPjxwYXRoIGQ9Ik05IDJoMXYxSDl6Ii8+PHBhdGggZD0iTTEwIDJoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xMSAyaDF2MWgtMXoiLz48cGF0aCBkPSJNMTIgMmgxdjFoLTF6Ii8+PHBhdGggZD0iTTEzIDJoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNCAyaDF2MWgtMXoiLz48cGF0aCBkPSJNMTUgMmgxdjFoLTF6Ii8+PHBhdGggZD0iTTE2IDJoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNyAyaDF2MWgtMXoiLz48cGF0aCBkPSJNMTggMmgxdjFoLTF6Ii8+PHBhdGggZD0iTTE5IDJoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMCAyaDF2MWgtMXoiLz48cGF0aCBkPSJNMjEgMmgxdjFoLTF6Ii8+PHBhdGggZD0iTTIyIDJoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMyAyaDF2MWgtMXoiLz48cGF0aCBkPSJNMjQgMmgxdjFoLTF6Ii8+PHBhdGggZD0iTTI1IDJoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNiAyaDF2MWgtMXoiLz48cGF0aCBkPSJNMjcgMmgxdjFoLTF6Ii8+PHBhdGggZD0iTTI4IDJoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yOSAyaDF2MWgtMXoiLz48cGF0aCBkPSJNMzAgMmgxdjFoLTF6Ii8+PHBhdGggZD0iTTMxIDJoMXYxaC0xek0wIDNoMXYxSDB6Ii8+PHBhdGggZD0iTTEgM2gxdjFIMXoiLz48cGF0aCBkPSJNMiAzaDF2MUgyeiIvPjxwYXRoIGQ9Ik0zIDNoMXYxSDN6Ii8+PHBhdGggZD0iTTQgM2gxdjFINHoiLz48cGF0aCBkPSJNNSAzaDF2MUg1eiIvPjxwYXRoIGQ9Ik02IDNoMXYxSDZ6Ii8+PHBhdGggZD0iTTcgM2gxdjFIN3oiLz48cGF0aCBkPSJNOCAzaDF2MUg4eiIvPjxwYXRoIGQ9Ik05IDNoMXYxSDl6Ii8+PHBhdGggZD0iTTEwIDNoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xMSAzaDF2MWgtMXoiLz48cGF0aCBkPSJNMTIgM2gxdjFoLTF6Ii8+PHBhdGggZD0iTTEzIDNoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNCAzaDF2MWgtMXoiLz48cGF0aCBkPSJNMTUgM2gxdjFoLTF6Ii8+PHBhdGggZD0iTTE2IDNoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNyAzaDF2MWgtMXoiLz48cGF0aCBkPSJNMTggM2gxdjFoLTF6Ii8+PHBhdGggZD0iTTE5IDNoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMCAzaDF2MWgtMXoiLz48cGF0aCBkPSJNMjEgM2gxdjFoLTF6Ii8+PHBhdGggZD0iTTIyIDNoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMyAzaDF2MWgtMXoiLz48cGF0aCBkPSJNMjQgM2gxdjFoLTF6Ii8+PHBhdGggZD0iTTI1IDNoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNiAzaDF2MWgtMXoiLz48cGF0aCBkPSJNMjcgM2gxdjFoLTF6Ii8+PHBhdGggZD0iTTI4IDNoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yOSAzaDF2MWgtMXoiLz48cGF0aCBkPSJNMzAgM2gxdjFoLTF6Ii8+PHBhdGggZD0iTTMxIDNoMXYxaC0xek0wIDRoMXYxSDB6Ii8+PHBhdGggZD0iTTEgNGgxdjFIMXoiLz48cGF0aCBkPSJNMiA0aDF2MUgyeiIvPjxwYXRoIGQ9Ik0zIDRoMXYxSDN6Ii8+PHBhdGggZD0iTTQgNGgxdjFINHoiLz48cGF0aCBkPSJNNSA0aDF2MUg1eiIvPjxwYXRoIGQ9Ik02IDRoMXYxSDZ6Ii8+PHBhdGggZD0iTTcgNGgxdjFIN3oiLz48cGF0aCBkPSJNOCA0aDF2MUg4eiIvPjxwYXRoIGQ9Ik05IDRoMXYxSDl6Ii8+PHBhdGggZD0iTTEwIDRoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xMSA0aDF2MWgtMXoiLz48cGF0aCBkPSJNMTIgNGgxdjFoLTF6Ii8+PHBhdGggZD0iTTEzIDRoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNCA0aDF2MWgtMXoiLz48cGF0aCBkPSJNMTUgNGgxdjFoLTF6Ii8+PHBhdGggZD0iTTE2IDRoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNyA0aDF2MWgtMXoiLz48cGF0aCBkPSJNMTggNGgxdjFoLTF6Ii8+PHBhdGggZD0iTTE5IDRoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMCA0aDF2MWgtMXoiLz48cGF0aCBkPSJNMjEgNGgxdjFoLTF6Ii8+PHBhdGggZD0iTTIyIDRoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMyA0aDF2MWgtMXoiLz48cGF0aCBkPSJNMjQgNGgxdjFoLTF6Ii8+PHBhdGggZD0iTTI1IDRoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNiA0aDF2MWgtMXoiLz48cGF0aCBkPSJNMjcgNGgxdjFoLTF6Ii8+PHBhdGggZD0iTTI4IDRoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yOSA0aDF2MWgtMXoiLz48cGF0aCBkPSJNMzAgNGgxdjFoLTF6Ii8+PHBhdGggZD0iTTMxIDRoMXYxaC0xek0wIDVoMXYxSDB6Ii8+PHBhdGggZD0iTTEgNWgxdjFIMXoiLz48cGF0aCBkPSJNMiA1aDF2MUgyeiIvPjxwYXRoIGQ9Ik0zIDVoMXYxSDN6Ii8+PHBhdGggZD0iTTQgNWgxdjFINHoiLz48cGF0aCBkPSJNNSA1aDF2MUg1eiIvPjxwYXRoIGQ9Ik02IDVoMXYxSDZ6Ii8+PHBhdGggZD0iTTcgNWgxdjFIN3oiLz48cGF0aCBkPSJNOCA1aDF2MUg4eiIvPjxwYXRoIGQ9Ik05IDVoMXYxSDl6Ii8+PHBhdGggZD0iTTEwIDVoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xMSA1aDF2MWgtMXoiLz48cGF0aCBkPSJNMTIgNWgxdjFoLTF6Ii8+PHBhdGggZD0iTTEzIDVoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNCA1aDF2MWgtMXoiLz48cGF0aCBkPSJNMTUgNWgxdjFoLTF6Ii8+PHBhdGggZD0iTTE2IDVoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNyA1aDF2MWgtMXoiLz48cGF0aCBkPSJNMTggNWgxdjFoLTF6Ii8+PHBhdGggZD0iTTE5IDVoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMCA1aDF2MWgtMXoiLz48cGF0aCBkPSJNMjEgNWgxdjFoLTF6Ii8+PHBhdGggZD0iTTIyIDVoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMyA1aDF2MWgtMXoiLz48cGF0aCBkPSJNMjQgNWgxdjFoLTF6Ii8+PHBhdGggZD0iTTI1IDVoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNiA1aDF2MWgtMXoiLz48cGF0aCBkPSJNMjcgNWgxdjFoLTF6Ii8+PHBhdGggZD0iTTI4IDVoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yOSA1aDF2MWgtMXoiLz48cGF0aCBkPSJNMzAgNWgxdjFoLTF6Ii8+PHBhdGggZD0iTTMxIDVoMXYxaC0xek0wIDZoMXYxSDB6Ii8+PHBhdGggZD0iTTEgNmgxdjFIMXoiLz48cGF0aCBkPSJNMiA2aDF2MUgyeiIvPjxwYXRoIGQ9Ik0zIDZoMXYxSDN6Ii8+PHBhdGggZD0iTTQgNmgxdjFINHoiLz48cGF0aCBkPSJNNSA2aDF2MUg1eiIvPjxwYXRoIGQ9Ik02IDZoMXYxSDZ6Ii8+PHBhdGggZD0iTTcgNmgxdjFIN3oiLz48cGF0aCBkPSJNOCA2aDF2MUg4eiIvPjxwYXRoIGQ9Ik05IDZoMXYxSDl6Ii8+PHBhdGggZD0iTTEwIDZoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xMSA2aDF2MWgtMXoiLz48cGF0aCBkPSJNMTIgNmgxdjFoLTF6Ii8+PHBhdGggZD0iTTEzIDZoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNCA2aDF2MWgtMXoiLz48cGF0aCBkPSJNMTUgNmgxdjFoLTF6Ii8+PHBhdGggZD0iTTE2IDZoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNyA2aDF2MWgtMXoiLz48cGF0aCBkPSJNMTggNmgxdjFoLTF6Ii8+PHBhdGggZD0iTTE5IDZoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMCA2aDF2MWgtMXoiLz48cGF0aCBkPSJNMjEgNmgxdjFoLTF6Ii8+PHBhdGggZD0iTTIyIDZoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMyA2aDF2MWgtMXoiLz48cGF0aCBkPSJNMjQgNmgxdjFoLTF6Ii8+PHBhdGggZD0iTTI1IDZoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNiA2aDF2MWgtMXoiLz48cGF0aCBkPSJNMjcgNmgxdjFoLTF6Ii8+PHBhdGggZD0iTTI4IDZoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yOSA2aDF2MWgtMXoiLz48cGF0aCBkPSJNMzAgNmgxdjFoLTF6Ii8+PHBhdGggZD0iTTMxIDZoMXYxaC0xek0wIDdoMXYxSDB6Ii8+PHBhdGggZD0iTTEgN2gxdjFIMXoiLz48cGF0aCBkPSJNMiA3aDF2MUgyeiIvPjxwYXRoIGQ9Ik0zIDdoMXYxSDN6Ii8+PHBhdGggZD0iTTQgN2gxdjFINHoiLz48cGF0aCBkPSJNNSA3aDF2MUg1eiIvPjxwYXRoIGQ9Ik02IDdoMXYxSDZ6Ii8+PHBhdGggZD0iTTcgN2gxdjFIN3oiLz48cGF0aCBkPSJNOCA3aDF2MUg4eiIvPjxwYXRoIGQ9Ik05IDdoMXYxSDl6Ii8+PHBhdGggZD0iTTEwIDdoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xMSA3aDF2MWgtMXoiLz48cGF0aCBkPSJNMTIgN2gxdjFoLTF6Ii8+PHBhdGggZD0iTTEzIDdoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNCA3aDF2MWgtMXoiLz48cGF0aCBkPSJNMTUgN2gxdjFoLTF6Ii8+PHBhdGggZD0iTTE2IDdoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNyA3aDF2MWgtMXoiLz48cGF0aCBkPSJNMTggN2gxdjFoLTF6Ii8+PHBhdGggZD0iTTE5IDdoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMCA3aDF2MWgtMXoiLz48cGF0aCBkPSJNMjEgN2gxdjFoLTF6Ii8+PHBhdGggZD0iTTIyIDdoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMyA3aDF2MWgtMXoiLz48cGF0aCBkPSJNMjQgN2gxdjFoLTF6Ii8+PHBhdGggZD0iTTI1IDdoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNiA3aDF2MWgtMXoiLz48cGF0aCBkPSJNMjcgN2gxdjFoLTF6Ii8+PHBhdGggZD0iTTI4IDdoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yOSA3aDF2MWgtMXoiLz48cGF0aCBkPSJNMzAgN2gxdjFoLTF6Ii8+PHBhdGggZD0iTTMxIDdoMXYxaC0xek0wIDhoMXYxSDB6Ii8+PHBhdGggZD0iTTEgOGgxdjFIMXoiLz48cGF0aCBkPSJNMiA4aDF2MUgyeiIvPjxwYXRoIGQ9Ik0zIDhoMXYxSDN6Ii8+PHBhdGggZD0iTTQgOGgxdjFINHoiLz48cGF0aCBkPSJNNSA4aDF2MUg1eiIvPjxwYXRoIGQ9Ik02IDhoMXYxSDZ6Ii8+PHBhdGggZD0iTTcgOGgxdjFIN3oiLz48cGF0aCBkPSJNOCA4aDF2MUg4eiIvPjxwYXRoIGQ9Ik05IDhoMXYxSDl6Ii8+PHBhdGggZD0iTTEwIDhoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xMSA4aDF2MWgtMXoiLz48cGF0aCBkPSJNMTIgOGgxdjFoLTF6Ii8+PHBhdGggZD0iTTEzIDhoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNCA4aDF2MWgtMXoiLz48cGF0aCBkPSJNMTUgOGgxdjFoLTF6Ii8+PHBhdGggZD0iTTE2IDhoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNyA4aDF2MWgtMXoiLz48cGF0aCBkPSJNMTggOGgxdjFoLTF6Ii8+PHBhdGggZD0iTTE5IDhoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMCA4aDF2MWgtMXoiLz48cGF0aCBkPSJNMjEgOGgxdjFoLTF6Ii8+PHBhdGggZD0iTTIyIDhoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMyA4aDF2MWgtMXoiLz48cGF0aCBkPSJNMjQgOGgxdjFoLTF6Ii8+PHBhdGggZD0iTTI1IDhoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNiA4aDF2MWgtMXoiLz48cGF0aCBkPSJNMjcgOGgxdjFoLTF6Ii8+PHBhdGggZD0iTTI4IDhoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yOSA4aDF2MWgtMXoiLz48cGF0aCBkPSJNMzAgOGgxdjFoLTF6Ii8+PHBhdGggZD0iTTMxIDhoMXYxaC0xek0wIDloMXYxSDB6Ii8+PHBhdGggZD0iTTEgOWgxdjFIMXoiLz48cGF0aCBkPSJNMiA5aDF2MUgyeiIvPjxwYXRoIGQ9Ik0zIDloMXYxSDN6Ii8+PHBhdGggZD0iTTQgOWgxdjFINHoiLz48cGF0aCBkPSJNNSA5aDF2MUg1eiIvPjxwYXRoIGQ9Ik02IDloMXYxSDZ6Ii8+PHBhdGggZD0iTTcgOWgxdjFIN3oiLz48cGF0aCBkPSJNOCA5aDF2MUg4eiIvPjxwYXRoIGQ9Ik05IDloMXYxSDl6Ii8+PHBhdGggZD0iTTEwIDloMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xMSA5aDF2MWgtMXoiLz48cGF0aCBkPSJNMTIgOWgxdjFoLTF6Ii8+PHBhdGggZD0iTTEzIDloMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNCA5aDF2MWgtMXoiLz48cGF0aCBkPSJNMTUgOWgxdjFoLTF6Ii8+PHBhdGggZD0iTTE2IDloMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNyA5aDF2MWgtMXoiLz48cGF0aCBkPSJNMTggOWgxdjFoLTF6Ii8+PHBhdGggZD0iTTE5IDloMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMCA5aDF2MWgtMXoiLz48cGF0aCBkPSJNMjEgOWgxdjFoLTF6Ii8+PHBhdGggZD0iTTIyIDloMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMyA5aDF2MWgtMXoiLz48cGF0aCBkPSJNMjQgOWgxdjFoLTF6Ii8+PHBhdGggZD0iTTI1IDloMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNiA5aDF2MWgtMXoiLz48cGF0aCBkPSJNMjcgOWgxdjFoLTF6Ii8+PHBhdGggZD0iTTI4IDloMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yOSA5aDF2MWgtMXoiLz48cGF0aCBkPSJNMzAgOWgxdjFoLTF6Ii8+PHBhdGggZD0iTTMxIDloMXYxaC0xek0wIDEwaDF2MUgweiIvPjxwYXRoIGQ9Ik0xIDEwaDF2MUgxeiIvPjxwYXRoIGQ9Ik0yIDEwaDF2MUgyeiIvPjxwYXRoIGQ9Ik0zIDEwaDF2MUgzeiIvPjxwYXRoIGQ9Ik00IDEwaDF2MUg0eiIvPjxwYXRoIGQ9Ik01IDEwaDF2MUg1eiIvPjxwYXRoIGQ9Ik02IDEwaDF2MUg2eiIvPjxwYXRoIGQ9Ik03IDEwaDF2MUg3eiIvPjxwYXRoIGQ9Ik04IDEwaDF2MUg4eiIvPjxwYXRoIGQ9Ik05IDEwaDF2MUg5eiIvPjxwYXRoIGQ9Ik0xMCAxMGgxdjFoLTF6Ii8+PHBhdGggZD0iTTExIDEwaDF2MWgtMXoiLz48cGF0aCBkPSJNMTIgMTBoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xMyAxMGgxdjFoLTF6Ii8+PHBhdGggZD0iTTE0IDEwaDF2MWgtMXoiLz48cGF0aCBkPSJNMTUgMTBoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNiAxMGgxdjFoLTF6Ii8+PHBhdGggZD0iTTE3IDEwaDF2MWgtMXoiLz48cGF0aCBkPSJNMTggMTBoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xOSAxMGgxdjFoLTF6Ii8+PHBhdGggZD0iTTIwIDEwaDF2MWgtMXoiLz48cGF0aCBkPSJNMjEgMTBoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMiAxMGgxdjFoLTF6Ii8+PHBhdGggZD0iTTIzIDEwaDF2MWgtMXoiLz48cGF0aCBkPSJNMjQgMTBoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNSAxMGgxdjFoLTF6Ii8+PHBhdGggZD0iTTI2IDEwaDF2MWgtMXoiLz48cGF0aCBkPSJNMjcgMTBoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yOCAxMGgxdjFoLTF6Ii8+PHBhdGggZD0iTTI5IDEwaDF2MWgtMXoiLz48cGF0aCBkPSJNMzAgMTBoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0zMSAxMGgxdjFoLTF6TTAgMTFoMXYxSDB6Ii8+PHBhdGggZD0iTTEgMTFoMXYxSDF6Ii8+PHBhdGggZD0iTTIgMTFoMXYxSDJ6Ii8+PHBhdGggZD0iTTMgMTFoMXYxSDN6Ii8+PHBhdGggZD0iTTQgMTFoMXYxSDR6Ii8+PHBhdGggZD0iTTUgMTFoMXYxSDV6Ii8+PHBhdGggZD0iTTYgMTFoMXYxSDZ6Ii8+PHBhdGggZD0iTTcgMTFoMXYxSDd6Ii8+PC9nPjxnIGNsYXNzPSJDIj48cGF0aCBkPSJNOCAxMWgxdjFIOHoiLz48cGF0aCBkPSJNOSAxMWgxdjFIOXoiLz48cGF0aCBkPSJNMTAgMTFoMXYxaC0xeiIvPjwvZz48ZyBjbGFzcz0iQiI+PHBhdGggZD0iTTExIDExaDF2MWgtMXoiLz48cGF0aCBkPSJNMTIgMTFoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xMyAxMWgxdjFoLTF6Ii8+PHBhdGggZD0iTTE0IDExaDF2MWgtMXoiLz48cGF0aCBkPSJNMTUgMTFoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNiAxMWgxdjFoLTF6Ii8+PHBhdGggZD0iTTE3IDExaDF2MWgtMXoiLz48cGF0aCBkPSJNMTggMTFoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xOSAxMWgxdjFoLTF6Ii8+PHBhdGggZD0iTTIwIDExaDF2MWgtMXoiLz48L2c+PGcgY2xhc3M9IkMiPjxwYXRoIGQ9Ik0yMSAxMWgxdjFoLTF6Ii8+PHBhdGggZD0iTTIyIDExaDF2MWgtMXoiLz48cGF0aCBkPSJNMjMgMTFoMXYxaC0xeiIvPjwvZz48ZyBjbGFzcz0iQiI+PHBhdGggZD0iTTI0IDExaDF2MWgtMXoiLz48cGF0aCBkPSJNMjUgMTFoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNiAxMWgxdjFoLTF6Ii8+PHBhdGggZD0iTTI3IDExaDF2MWgtMXoiLz48cGF0aCBkPSJNMjggMTFoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yOSAxMWgxdjFoLTF6Ii8+PHBhdGggZD0iTTMwIDExaDF2MWgtMXoiLz48cGF0aCBkPSJNMzEgMTFoMXYxaC0xek0wIDEyaDF2MUgweiIvPjxwYXRoIGQ9Ik0xIDEyaDF2MUgxeiIvPjxwYXRoIGQ9Ik0yIDEyaDF2MUgyeiIvPjxwYXRoIGQ9Ik0zIDEyaDF2MUgzeiIvPjxwYXRoIGQ9Ik00IDEyaDF2MUg0eiIvPjxwYXRoIGQ9Ik01IDEyaDF2MUg1eiIvPjxwYXRoIGQ9Ik02IDEyaDF2MUg2eiIvPjxwYXRoIGQ9Ik03IDEyaDF2MUg3eiIvPjwvZz48ZyBjbGFzcz0iQyI+PHBhdGggZD0iTTggMTJoMXYxSDh6Ii8+PHBhdGggZD0iTTkgMTJoMXYxSDl6Ii8+PHBhdGggZD0iTTEwIDEyaDF2MWgtMXoiLz48L2c+PGcgY2xhc3M9IkIiPjxwYXRoIGQ9Ik0xMSAxMmgxdjFoLTF6Ii8+PHBhdGggZD0iTTEyIDEyaDF2MWgtMXoiLz48cGF0aCBkPSJNMTMgMTJoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNCAxMmgxdjFoLTF6Ii8+PHBhdGggZD0iTTE1IDEyaDF2MWgtMXoiLz48cGF0aCBkPSJNMTYgMTJoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNyAxMmgxdjFoLTF6Ii8+PHBhdGggZD0iTTE4IDEyaDF2MWgtMXoiLz48cGF0aCBkPSJNMTkgMTJoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMCAxMmgxdjFoLTF6Ii8+PC9nPjxnIGNsYXNzPSJDIj48cGF0aCBkPSJNMjEgMTJoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMiAxMmgxdjFoLTF6Ii8+PHBhdGggZD0iTTIzIDEyaDF2MWgtMXoiLz48L2c+PGcgY2xhc3M9IkIiPjxwYXRoIGQ9Ik0yNCAxMmgxdjFoLTF6Ii8+PHBhdGggZD0iTTI1IDEyaDF2MWgtMXoiLz48cGF0aCBkPSJNMjYgMTJoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNyAxMmgxdjFoLTF6Ii8+PHBhdGggZD0iTTI4IDEyaDF2MWgtMXoiLz48cGF0aCBkPSJNMjkgMTJoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0zMCAxMmgxdjFoLTF6Ii8+PHBhdGggZD0iTTMxIDEyaDF2MWgtMXpNMCAxM2gxdjFIMHoiLz48cGF0aCBkPSJNMSAxM2gxdjFIMXoiLz48cGF0aCBkPSJNMiAxM2gxdjFIMnoiLz48cGF0aCBkPSJNMyAxM2gxdjFIM3oiLz48cGF0aCBkPSJNNCAxM2gxdjFINHoiLz48cGF0aCBkPSJNNSAxM2gxdjFINXoiLz48cGF0aCBkPSJNNiAxM2gxdjFINnoiLz48cGF0aCBkPSJNNyAxM2gxdjFIN3oiLz48L2c+PGcgY2xhc3M9IkMiPjxwYXRoIGQ9Ik04IDEzaDF2MUg4eiIvPjxwYXRoIGQ9Ik05IDEzaDF2MUg5eiIvPjxwYXRoIGQ9Ik0xMCAxM2gxdjFoLTF6Ii8+PC9nPjxnIGNsYXNzPSJCIj48cGF0aCBkPSJNMTEgMTNoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xMiAxM2gxdjFoLTF6Ii8+PHBhdGggZD0iTTEzIDEzaDF2MWgtMXoiLz48cGF0aCBkPSJNMTQgMTNoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNSAxM2gxdjFoLTF6Ii8+PHBhdGggZD0iTTE2IDEzaDF2MWgtMXoiLz48cGF0aCBkPSJNMTcgMTNoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xOCAxM2gxdjFoLTF6Ii8+PHBhdGggZD0iTTE5IDEzaDF2MWgtMXoiLz48cGF0aCBkPSJNMjAgMTNoMXYxaC0xeiIvPjwvZz48ZyBjbGFzcz0iQyI+PHBhdGggZD0iTTIxIDEzaDF2MWgtMXoiLz48cGF0aCBkPSJNMjIgMTNoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMyAxM2gxdjFoLTF6Ii8+PC9nPjxnIGNsYXNzPSJCIj48cGF0aCBkPSJNMjQgMTNoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNSAxM2gxdjFoLTF6Ii8+PHBhdGggZD0iTTI2IDEzaDF2MWgtMXoiLz48cGF0aCBkPSJNMjcgMTNoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yOCAxM2gxdjFoLTF6Ii8+PHBhdGggZD0iTTI5IDEzaDF2MWgtMXoiLz48cGF0aCBkPSJNMzAgMTNoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0zMSAxM2gxdjFoLTF6TTAgMTRoMXYxSDB6Ii8+PHBhdGggZD0iTTEgMTRoMXYxSDF6Ii8+PHBhdGggZD0iTTIgMTRoMXYxSDJ6Ii8+PHBhdGggZD0iTTMgMTRoMXYxSDN6Ii8+PHBhdGggZD0iTTQgMTRoMXYxSDR6Ii8+PHBhdGggZD0iTTUgMTRoMXYxSDV6Ii8+PHBhdGggZD0iTTYgMTRoMXYxSDZ6Ii8+PHBhdGggZD0iTTcgMTRoMXYxSDd6Ii8+PHBhdGggZD0iTTggMTRoMXYxSDh6Ii8+PHBhdGggZD0iTTkgMTRoMXYxSDl6Ii8+PHBhdGggZD0iTTEwIDE0aDF2MWgtMXoiLz48cGF0aCBkPSJNMTEgMTRoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xMiAxNGgxdjFoLTF6Ii8+PHBhdGggZD0iTTEzIDE0aDF2MWgtMXoiLz48cGF0aCBkPSJNMTQgMTRoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNSAxNGgxdjFoLTF6Ii8+PHBhdGggZD0iTTE2IDE0aDF2MWgtMXoiLz48cGF0aCBkPSJNMTcgMTRoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xOCAxNGgxdjFoLTF6Ii8+PHBhdGggZD0iTTE5IDE0aDF2MWgtMXoiLz48cGF0aCBkPSJNMjAgMTRoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMSAxNGgxdjFoLTF6Ii8+PHBhdGggZD0iTTIyIDE0aDF2MWgtMXoiLz48cGF0aCBkPSJNMjMgMTRoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNCAxNGgxdjFoLTF6Ii8+PHBhdGggZD0iTTI1IDE0aDF2MWgtMXoiLz48cGF0aCBkPSJNMjYgMTRoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNyAxNGgxdjFoLTF6Ii8+PHBhdGggZD0iTTI4IDE0aDF2MWgtMXoiLz48cGF0aCBkPSJNMjkgMTRoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0zMCAxNGgxdjFoLTF6Ii8+PHBhdGggZD0iTTMxIDE0aDF2MWgtMXpNMCAxNWgxdjFIMHoiLz48cGF0aCBkPSJNMSAxNWgxdjFIMXoiLz48cGF0aCBkPSJNMiAxNWgxdjFIMnoiLz48cGF0aCBkPSJNMyAxNWgxdjFIM3oiLz48cGF0aCBkPSJNNCAxNWgxdjFINHoiLz48cGF0aCBkPSJNNSAxNWgxdjFINXoiLz48cGF0aCBkPSJNNiAxNWgxdjFINnoiLz48cGF0aCBkPSJNNyAxNWgxdjFIN3oiLz48cGF0aCBkPSJNOCAxNWgxdjFIOHoiLz48cGF0aCBkPSJNOSAxNWgxdjFIOXoiLz48cGF0aCBkPSJNMTAgMTVoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xMSAxNWgxdjFoLTF6Ii8+PHBhdGggZD0iTTEyIDE1aDF2MWgtMXoiLz48cGF0aCBkPSJNMTMgMTVoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNCAxNWgxdjFoLTF6Ii8+PHBhdGggZD0iTTE1IDE1aDF2MWgtMXoiLz48cGF0aCBkPSJNMTYgMTVoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNyAxNWgxdjFoLTF6Ii8+PHBhdGggZD0iTTE4IDE1aDF2MWgtMXoiLz48cGF0aCBkPSJNMTkgMTVoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMCAxNWgxdjFoLTF6Ii8+PHBhdGggZD0iTTIxIDE1aDF2MWgtMXoiLz48cGF0aCBkPSJNMjIgMTVoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMyAxNWgxdjFoLTF6Ii8+PHBhdGggZD0iTTI0IDE1aDF2MWgtMXoiLz48cGF0aCBkPSJNMjUgMTVoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNiAxNWgxdjFoLTF6Ii8+PHBhdGggZD0iTTI3IDE1aDF2MWgtMXoiLz48cGF0aCBkPSJNMjggMTVoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yOSAxNWgxdjFoLTF6Ii8+PHBhdGggZD0iTTMwIDE1aDF2MWgtMXoiLz48cGF0aCBkPSJNMzEgMTVoMXYxaC0xek0wIDE2aDF2MUgweiIvPjxwYXRoIGQ9Ik0xIDE2aDF2MUgxeiIvPjxwYXRoIGQ9Ik0yIDE2aDF2MUgyeiIvPjxwYXRoIGQ9Ik0zIDE2aDF2MUgzeiIvPjxwYXRoIGQ9Ik00IDE2aDF2MUg0eiIvPjxwYXRoIGQ9Ik01IDE2aDF2MUg1eiIvPjxwYXRoIGQ9Ik02IDE2aDF2MUg2eiIvPjxwYXRoIGQ9Ik03IDE2aDF2MUg3eiIvPjxwYXRoIGQ9Ik04IDE2aDF2MUg4eiIvPjxwYXRoIGQ9Ik05IDE2aDF2MUg5eiIvPjxwYXRoIGQ9Ik0xMCAxNmgxdjFoLTF6Ii8+PHBhdGggZD0iTTExIDE2aDF2MWgtMXoiLz48cGF0aCBkPSJNMTIgMTZoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xMyAxNmgxdjFoLTF6Ii8+PHBhdGggZD0iTTE0IDE2aDF2MWgtMXoiLz48cGF0aCBkPSJNMTUgMTZoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNiAxNmgxdjFoLTF6Ii8+PHBhdGggZD0iTTE3IDE2aDF2MWgtMXoiLz48cGF0aCBkPSJNMTggMTZoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xOSAxNmgxdjFoLTF6Ii8+PHBhdGggZD0iTTIwIDE2aDF2MWgtMXoiLz48cGF0aCBkPSJNMjEgMTZoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMiAxNmgxdjFoLTF6Ii8+PHBhdGggZD0iTTIzIDE2aDF2MWgtMXoiLz48cGF0aCBkPSJNMjQgMTZoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNSAxNmgxdjFoLTF6Ii8+PHBhdGggZD0iTTI2IDE2aDF2MWgtMXoiLz48cGF0aCBkPSJNMjcgMTZoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yOCAxNmgxdjFoLTF6Ii8+PHBhdGggZD0iTTI5IDE2aDF2MWgtMXoiLz48cGF0aCBkPSJNMzAgMTZoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0zMSAxNmgxdjFoLTF6TTAgMTdoMXYxSDB6Ii8+PHBhdGggZD0iTTEgMTdoMXYxSDF6Ii8+PHBhdGggZD0iTTIgMTdoMXYxSDJ6Ii8+PHBhdGggZD0iTTMgMTdoMXYxSDN6Ii8+PHBhdGggZD0iTTQgMTdoMXYxSDR6Ii8+PHBhdGggZD0iTTUgMTdoMXYxSDV6Ii8+PHBhdGggZD0iTTYgMTdoMXYxSDZ6Ii8+PHBhdGggZD0iTTcgMTdoMXYxSDd6Ii8+PHBhdGggZD0iTTggMTdoMXYxSDh6Ii8+PHBhdGggZD0iTTkgMTdoMXYxSDl6Ii8+PHBhdGggZD0iTTEwIDE3aDF2MWgtMXoiLz48cGF0aCBkPSJNMTEgMTdoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xMiAxN2gxdjFoLTF6Ii8+PHBhdGggZD0iTTEzIDE3aDF2MWgtMXoiLz48cGF0aCBkPSJNMTQgMTdoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNSAxN2gxdjFoLTF6Ii8+PHBhdGggZD0iTTE2IDE3aDF2MWgtMXoiLz48cGF0aCBkPSJNMTcgMTdoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xOCAxN2gxdjFoLTF6Ii8+PHBhdGggZD0iTTE5IDE3aDF2MWgtMXoiLz48cGF0aCBkPSJNMjAgMTdoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMSAxN2gxdjFoLTF6Ii8+PHBhdGggZD0iTTIyIDE3aDF2MWgtMXoiLz48cGF0aCBkPSJNMjMgMTdoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNCAxN2gxdjFoLTF6Ii8+PHBhdGggZD0iTTI1IDE3aDF2MWgtMXoiLz48cGF0aCBkPSJNMjYgMTdoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNyAxN2gxdjFoLTF6Ii8+PHBhdGggZD0iTTI4IDE3aDF2MWgtMXoiLz48cGF0aCBkPSJNMjkgMTdoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0zMCAxN2gxdjFoLTF6Ii8+PHBhdGggZD0iTTMxIDE3aDF2MWgtMXpNMCAxOGgxdjFIMHoiLz48cGF0aCBkPSJNMSAxOGgxdjFIMXoiLz48cGF0aCBkPSJNMiAxOGgxdjFIMnoiLz48cGF0aCBkPSJNMyAxOGgxdjFIM3oiLz48cGF0aCBkPSJNNCAxOGgxdjFINHoiLz48cGF0aCBkPSJNNSAxOGgxdjFINXoiLz48cGF0aCBkPSJNNiAxOGgxdjFINnoiLz48cGF0aCBkPSJNNyAxOGgxdjFIN3oiLz48cGF0aCBkPSJNOCAxOGgxdjFIOHoiLz48cGF0aCBkPSJNOSAxOGgxdjFIOXoiLz48cGF0aCBkPSJNMTAgMThoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xMSAxOGgxdjFoLTF6Ii8+PHBhdGggZD0iTTEyIDE4aDF2MWgtMXoiLz48cGF0aCBkPSJNMTMgMThoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNCAxOGgxdjFoLTF6Ii8+PHBhdGggZD0iTTE1IDE4aDF2MWgtMXoiLz48cGF0aCBkPSJNMTYgMThoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNyAxOGgxdjFoLTF6Ii8+PHBhdGggZD0iTTE4IDE4aDF2MWgtMXoiLz48cGF0aCBkPSJNMTkgMThoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMCAxOGgxdjFoLTF6Ii8+PHBhdGggZD0iTTIxIDE4aDF2MWgtMXoiLz48cGF0aCBkPSJNMjIgMThoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMyAxOGgxdjFoLTF6Ii8+PHBhdGggZD0iTTI0IDE4aDF2MWgtMXoiLz48cGF0aCBkPSJNMjUgMThoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNiAxOGgxdjFoLTF6Ii8+PHBhdGggZD0iTTI3IDE4aDF2MWgtMXoiLz48cGF0aCBkPSJNMjggMThoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yOSAxOGgxdjFoLTF6Ii8+PHBhdGggZD0iTTMwIDE4aDF2MWgtMXoiLz48cGF0aCBkPSJNMzEgMThoMXYxaC0xek0wIDE5aDF2MUgweiIvPjxwYXRoIGQ9Ik0xIDE5aDF2MUgxeiIvPjxwYXRoIGQ9Ik0yIDE5aDF2MUgyeiIvPjxwYXRoIGQ9Ik0zIDE5aDF2MUgzeiIvPjxwYXRoIGQ9Ik00IDE5aDF2MUg0eiIvPjxwYXRoIGQ9Ik01IDE5aDF2MUg1eiIvPjxwYXRoIGQ9Ik02IDE5aDF2MUg2eiIvPjxwYXRoIGQ9Ik03IDE5aDF2MUg3eiIvPjxwYXRoIGQ9Ik04IDE5aDF2MUg4eiIvPjxwYXRoIGQ9Ik05IDE5aDF2MUg5eiIvPjxwYXRoIGQ9Ik0xMCAxOWgxdjFoLTF6Ii8+PHBhdGggZD0iTTExIDE5aDF2MWgtMXoiLz48cGF0aCBkPSJNMTIgMTloMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xMyAxOWgxdjFoLTF6Ii8+PHBhdGggZD0iTTE0IDE5aDF2MWgtMXoiLz48cGF0aCBkPSJNMTUgMTloMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNiAxOWgxdjFoLTF6Ii8+PHBhdGggZD0iTTE3IDE5aDF2MWgtMXoiLz48cGF0aCBkPSJNMTggMTloMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xOSAxOWgxdjFoLTF6Ii8+PHBhdGggZD0iTTIwIDE5aDF2MWgtMXoiLz48cGF0aCBkPSJNMjEgMTloMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMiAxOWgxdjFoLTF6Ii8+PHBhdGggZD0iTTIzIDE5aDF2MWgtMXoiLz48cGF0aCBkPSJNMjQgMTloMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNSAxOWgxdjFoLTF6Ii8+PHBhdGggZD0iTTI2IDE5aDF2MWgtMXoiLz48cGF0aCBkPSJNMjcgMTloMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yOCAxOWgxdjFoLTF6Ii8+PHBhdGggZD0iTTI5IDE5aDF2MWgtMXoiLz48cGF0aCBkPSJNMzAgMTloMXYxaC0xeiIvPjxwYXRoIGQ9Ik0zMSAxOWgxdjFoLTF6TTAgMjBoMXYxSDB6Ii8+PHBhdGggZD0iTTEgMjBoMXYxSDF6Ii8+PHBhdGggZD0iTTIgMjBoMXYxSDJ6Ii8+PHBhdGggZD0iTTMgMjBoMXYxSDN6Ii8+PHBhdGggZD0iTTQgMjBoMXYxSDR6Ii8+PHBhdGggZD0iTTUgMjBoMXYxSDV6Ii8+PHBhdGggZD0iTTYgMjBoMXYxSDZ6Ii8+PHBhdGggZD0iTTcgMjBoMXYxSDd6Ii8+PHBhdGggZD0iTTggMjBoMXYxSDh6Ii8+PHBhdGggZD0iTTkgMjBoMXYxSDl6Ii8+PHBhdGggZD0iTTEwIDIwaDF2MWgtMXoiLz48cGF0aCBkPSJNMTEgMjBoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xMiAyMGgxdjFoLTF6Ii8+PHBhdGggZD0iTTEzIDIwaDF2MWgtMXoiLz48cGF0aCBkPSJNMTQgMjBoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNSAyMGgxdjFoLTF6Ii8+PHBhdGggZD0iTTE2IDIwaDF2MWgtMXoiLz48cGF0aCBkPSJNMTcgMjBoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xOCAyMGgxdjFoLTF6Ii8+PHBhdGggZD0iTTE5IDIwaDF2MWgtMXoiLz48cGF0aCBkPSJNMjAgMjBoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMSAyMGgxdjFoLTF6Ii8+PHBhdGggZD0iTTIyIDIwaDF2MWgtMXoiLz48cGF0aCBkPSJNMjMgMjBoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNCAyMGgxdjFoLTF6Ii8+PHBhdGggZD0iTTI1IDIwaDF2MWgtMXoiLz48cGF0aCBkPSJNMjYgMjBoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNyAyMGgxdjFoLTF6Ii8+PHBhdGggZD0iTTI4IDIwaDF2MWgtMXoiLz48cGF0aCBkPSJNMjkgMjBoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0zMCAyMGgxdjFoLTF6Ii8+PHBhdGggZD0iTTMxIDIwaDF2MWgtMXpNMCAyMWgxdjFIMHoiLz48cGF0aCBkPSJNMSAyMWgxdjFIMXoiLz48cGF0aCBkPSJNMiAyMWgxdjFIMnoiLz48cGF0aCBkPSJNMyAyMWgxdjFIM3oiLz48cGF0aCBkPSJNNCAyMWgxdjFINHoiLz48cGF0aCBkPSJNNSAyMWgxdjFINXoiLz48cGF0aCBkPSJNNiAyMWgxdjFINnoiLz48cGF0aCBkPSJNNyAyMWgxdjFIN3oiLz48L2c+PGcgY2xhc3M9IkMiPjxwYXRoIGQ9Ik04IDIxaDF2MUg4eiIvPjxwYXRoIGQ9Ik05IDIxaDF2MUg5eiIvPjxwYXRoIGQ9Ik0xMCAyMWgxdjFoLTF6Ii8+PC9nPjxnIGNsYXNzPSJCIj48cGF0aCBkPSJNMTEgMjFoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xMiAyMWgxdjFoLTF6Ii8+PHBhdGggZD0iTTEzIDIxaDF2MWgtMXoiLz48cGF0aCBkPSJNMTQgMjFoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNSAyMWgxdjFoLTF6Ii8+PHBhdGggZD0iTTE2IDIxaDF2MWgtMXoiLz48cGF0aCBkPSJNMTcgMjFoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xOCAyMWgxdjFoLTF6Ii8+PHBhdGggZD0iTTE5IDIxaDF2MWgtMXoiLz48L2c+PGcgY2xhc3M9IkMiPjxwYXRoIGQ9Ik0yMCAyMWgxdjFoLTF6Ii8+PHBhdGggZD0iTTIxIDIxaDF2MWgtMXoiLz48cGF0aCBkPSJNMjIgMjFoMXYxaC0xeiIvPjwvZz48ZyBjbGFzcz0iQiI+PHBhdGggZD0iTTIzIDIxaDF2MWgtMXoiLz48cGF0aCBkPSJNMjQgMjFoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNSAyMWgxdjFoLTF6Ii8+PHBhdGggZD0iTTI2IDIxaDF2MWgtMXoiLz48cGF0aCBkPSJNMjcgMjFoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yOCAyMWgxdjFoLTF6Ii8+PHBhdGggZD0iTTI5IDIxaDF2MWgtMXoiLz48cGF0aCBkPSJNMzAgMjFoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0zMSAyMWgxdjFoLTF6TTAgMjJoMXYxSDB6Ii8+PHBhdGggZD0iTTEgMjJoMXYxSDF6Ii8+PHBhdGggZD0iTTIgMjJoMXYxSDJ6Ii8+PHBhdGggZD0iTTMgMjJoMXYxSDN6Ii8+PHBhdGggZD0iTTQgMjJoMXYxSDR6Ii8+PHBhdGggZD0iTTUgMjJoMXYxSDV6Ii8+PHBhdGggZD0iTTYgMjJoMXYxSDZ6Ii8+PHBhdGggZD0iTTcgMjJoMXYxSDd6Ii8+PC9nPjxnIGNsYXNzPSJDIj48cGF0aCBkPSJNOCAyMmgxdjFIOHoiLz48cGF0aCBkPSJNOSAyMmgxdjFIOXoiLz48cGF0aCBkPSJNMTAgMjJoMXYxaC0xeiIvPjwvZz48ZyBjbGFzcz0iQiI+PHBhdGggZD0iTTExIDIyaDF2MWgtMXoiLz48cGF0aCBkPSJNMTIgMjJoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xMyAyMmgxdjFoLTF6Ii8+PHBhdGggZD0iTTE0IDIyaDF2MWgtMXoiLz48cGF0aCBkPSJNMTUgMjJoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNiAyMmgxdjFoLTF6Ii8+PHBhdGggZD0iTTE3IDIyaDF2MWgtMXoiLz48cGF0aCBkPSJNMTggMjJoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xOSAyMmgxdjFoLTF6Ii8+PC9nPjxnIGNsYXNzPSJDIj48cGF0aCBkPSJNMjAgMjJoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMSAyMmgxdjFoLTF6Ii8+PHBhdGggZD0iTTIyIDIyaDF2MWgtMXoiLz48L2c+PGcgY2xhc3M9IkIiPjxwYXRoIGQ9Ik0yMyAyMmgxdjFoLTF6Ii8+PHBhdGggZD0iTTI0IDIyaDF2MWgtMXoiLz48cGF0aCBkPSJNMjUgMjJoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNiAyMmgxdjFoLTF6Ii8+PHBhdGggZD0iTTI3IDIyaDF2MWgtMXoiLz48cGF0aCBkPSJNMjggMjJoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yOSAyMmgxdjFoLTF6Ii8+PHBhdGggZD0iTTMwIDIyaDF2MWgtMXoiLz48cGF0aCBkPSJNMzEgMjJoMXYxaC0xek0wIDIzaDF2MUgweiIvPjxwYXRoIGQ9Ik0xIDIzaDF2MUgxeiIvPjxwYXRoIGQ9Ik0yIDIzaDF2MUgyeiIvPjxwYXRoIGQ9Ik0zIDIzaDF2MUgzeiIvPjxwYXRoIGQ9Ik00IDIzaDF2MUg0eiIvPjxwYXRoIGQ9Ik01IDIzaDF2MUg1eiIvPjxwYXRoIGQ9Ik02IDIzaDF2MUg2eiIvPjxwYXRoIGQ9Ik03IDIzaDF2MUg3eiIvPjwvZz48ZyBjbGFzcz0iQyI+PHBhdGggZD0iTTggMjNoMXYxSDh6Ii8+PHBhdGggZD0iTTkgMjNoMXYxSDl6Ii8+PHBhdGggZD0iTTEwIDIzaDF2MWgtMXoiLz48L2c+PGcgY2xhc3M9IkIiPjxwYXRoIGQ9Ik0xMSAyM2gxdjFoLTF6Ii8+PHBhdGggZD0iTTEyIDIzaDF2MWgtMXoiLz48cGF0aCBkPSJNMTMgMjNoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNCAyM2gxdjFoLTF6Ii8+PHBhdGggZD0iTTE1IDIzaDF2MWgtMXoiLz48cGF0aCBkPSJNMTYgMjNoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNyAyM2gxdjFoLTF6Ii8+PHBhdGggZD0iTTE4IDIzaDF2MWgtMXoiLz48cGF0aCBkPSJNMTkgMjNoMXYxaC0xeiIvPjwvZz48ZyBjbGFzcz0iQyI+PHBhdGggZD0iTTIwIDIzaDF2MWgtMXoiLz48cGF0aCBkPSJNMjEgMjNoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMiAyM2gxdjFoLTF6Ii8+PC9nPjxnIGNsYXNzPSJCIj48cGF0aCBkPSJNMjMgMjNoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNCAyM2gxdjFoLTF6Ii8+PHBhdGggZD0iTTI1IDIzaDF2MWgtMXoiLz48cGF0aCBkPSJNMjYgMjNoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNyAyM2gxdjFoLTF6Ii8+PHBhdGggZD0iTTI4IDIzaDF2MWgtMXoiLz48cGF0aCBkPSJNMjkgMjNoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0zMCAyM2gxdjFoLTF6Ii8+PHBhdGggZD0iTTMxIDIzaDF2MWgtMXpNMCAyNGgxdjFIMHoiLz48cGF0aCBkPSJNMSAyNGgxdjFIMXoiLz48cGF0aCBkPSJNMiAyNGgxdjFIMnoiLz48cGF0aCBkPSJNMyAyNGgxdjFIM3oiLz48cGF0aCBkPSJNNCAyNGgxdjFINHoiLz48cGF0aCBkPSJNNSAyNGgxdjFINXoiLz48cGF0aCBkPSJNNiAyNGgxdjFINnoiLz48cGF0aCBkPSJNNyAyNGgxdjFIN3oiLz48cGF0aCBkPSJNOCAyNGgxdjFIOHoiLz48cGF0aCBkPSJNOSAyNGgxdjFIOXoiLz48cGF0aCBkPSJNMTAgMjRoMXYxaC0xeiIvPjwvZz48ZyBjbGFzcz0iQyI+PHBhdGggZD0iTTExIDI0aDF2MWgtMXoiLz48cGF0aCBkPSJNMTIgMjRoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xMyAyNGgxdjFoLTF6Ii8+PHBhdGggZD0iTTE0IDI0aDF2MWgtMXoiLz48cGF0aCBkPSJNMTUgMjRoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNiAyNGgxdjFoLTF6Ii8+PHBhdGggZD0iTTE3IDI0aDF2MWgtMXoiLz48cGF0aCBkPSJNMTggMjRoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xOSAyNGgxdjFoLTF6Ii8+PC9nPjxnIGNsYXNzPSJCIj48cGF0aCBkPSJNMjAgMjRoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMSAyNGgxdjFoLTF6Ii8+PHBhdGggZD0iTTIyIDI0aDF2MWgtMXoiLz48cGF0aCBkPSJNMjMgMjRoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNCAyNGgxdjFoLTF6Ii8+PHBhdGggZD0iTTI1IDI0aDF2MWgtMXoiLz48cGF0aCBkPSJNMjYgMjRoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNyAyNGgxdjFoLTF6Ii8+PHBhdGggZD0iTTI4IDI0aDF2MWgtMXoiLz48cGF0aCBkPSJNMjkgMjRoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0zMCAyNGgxdjFoLTF6Ii8+PHBhdGggZD0iTTMxIDI0aDF2MWgtMXpNMCAyNWgxdjFIMHoiLz48cGF0aCBkPSJNMSAyNWgxdjFIMXoiLz48cGF0aCBkPSJNMiAyNWgxdjFIMnoiLz48cGF0aCBkPSJNMyAyNWgxdjFIM3oiLz48cGF0aCBkPSJNNCAyNWgxdjFINHoiLz48cGF0aCBkPSJNNSAyNWgxdjFINXoiLz48cGF0aCBkPSJNNiAyNWgxdjFINnoiLz48cGF0aCBkPSJNNyAyNWgxdjFIN3oiLz48cGF0aCBkPSJNOCAyNWgxdjFIOHoiLz48cGF0aCBkPSJNOSAyNWgxdjFIOXoiLz48cGF0aCBkPSJNMTAgMjVoMXYxaC0xeiIvPjwvZz48ZyBjbGFzcz0iQyI+PHBhdGggZD0iTTExIDI1aDF2MWgtMXoiLz48cGF0aCBkPSJNMTIgMjVoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xMyAyNWgxdjFoLTF6Ii8+PHBhdGggZD0iTTE0IDI1aDF2MWgtMXoiLz48cGF0aCBkPSJNMTUgMjVoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNiAyNWgxdjFoLTF6Ii8+PHBhdGggZD0iTTE3IDI1aDF2MWgtMXoiLz48cGF0aCBkPSJNMTggMjVoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xOSAyNWgxdjFoLTF6Ii8+PC9nPjxnIGNsYXNzPSJCIj48cGF0aCBkPSJNMjAgMjVoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMSAyNWgxdjFoLTF6Ii8+PHBhdGggZD0iTTIyIDI1aDF2MWgtMXoiLz48cGF0aCBkPSJNMjMgMjVoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNCAyNWgxdjFoLTF6Ii8+PHBhdGggZD0iTTI1IDI1aDF2MWgtMXoiLz48cGF0aCBkPSJNMjYgMjVoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNyAyNWgxdjFoLTF6Ii8+PHBhdGggZD0iTTI4IDI1aDF2MWgtMXoiLz48cGF0aCBkPSJNMjkgMjVoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0zMCAyNWgxdjFoLTF6Ii8+PHBhdGggZD0iTTMxIDI1aDF2MWgtMXpNMCAyNmgxdjFIMHoiLz48cGF0aCBkPSJNMSAyNmgxdjFIMXoiLz48cGF0aCBkPSJNMiAyNmgxdjFIMnoiLz48cGF0aCBkPSJNMyAyNmgxdjFIM3oiLz48cGF0aCBkPSJNNCAyNmgxdjFINHoiLz48cGF0aCBkPSJNNSAyNmgxdjFINXoiLz48cGF0aCBkPSJNNiAyNmgxdjFINnoiLz48cGF0aCBkPSJNNyAyNmgxdjFIN3oiLz48cGF0aCBkPSJNOCAyNmgxdjFIOHoiLz48cGF0aCBkPSJNOSAyNmgxdjFIOXoiLz48cGF0aCBkPSJNMTAgMjZoMXYxaC0xeiIvPjwvZz48ZyBjbGFzcz0iQyI+PHBhdGggZD0iTTExIDI2aDF2MWgtMXoiLz48cGF0aCBkPSJNMTIgMjZoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xMyAyNmgxdjFoLTF6Ii8+PHBhdGggZD0iTTE0IDI2aDF2MWgtMXoiLz48cGF0aCBkPSJNMTUgMjZoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNiAyNmgxdjFoLTF6Ii8+PHBhdGggZD0iTTE3IDI2aDF2MWgtMXoiLz48cGF0aCBkPSJNMTggMjZoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xOSAyNmgxdjFoLTF6Ii8+PC9nPjxnIGNsYXNzPSJCIj48cGF0aCBkPSJNMjAgMjZoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMSAyNmgxdjFoLTF6Ii8+PHBhdGggZD0iTTIyIDI2aDF2MWgtMXoiLz48cGF0aCBkPSJNMjMgMjZoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNCAyNmgxdjFoLTF6Ii8+PHBhdGggZD0iTTI1IDI2aDF2MWgtMXoiLz48cGF0aCBkPSJNMjYgMjZoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNyAyNmgxdjFoLTF6Ii8+PHBhdGggZD0iTTI4IDI2aDF2MWgtMXoiLz48cGF0aCBkPSJNMjkgMjZoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0zMCAyNmgxdjFoLTF6Ii8+PHBhdGggZD0iTTMxIDI2aDF2MWgtMXpNMCAyN2gxdjFIMHoiLz48cGF0aCBkPSJNMSAyN2gxdjFIMXoiLz48cGF0aCBkPSJNMiAyN2gxdjFIMnoiLz48cGF0aCBkPSJNMyAyN2gxdjFIM3oiLz48cGF0aCBkPSJNNCAyN2gxdjFINHoiLz48cGF0aCBkPSJNNSAyN2gxdjFINXoiLz48cGF0aCBkPSJNNiAyN2gxdjFINnoiLz48cGF0aCBkPSJNNyAyN2gxdjFIN3oiLz48cGF0aCBkPSJNOCAyN2gxdjFIOHoiLz48cGF0aCBkPSJNOSAyN2gxdjFIOXoiLz48cGF0aCBkPSJNMTAgMjdoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xMSAyN2gxdjFoLTF6Ii8+PHBhdGggZD0iTTEyIDI3aDF2MWgtMXoiLz48cGF0aCBkPSJNMTMgMjdoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNCAyN2gxdjFoLTF6Ii8+PHBhdGggZD0iTTE1IDI3aDF2MWgtMXoiLz48cGF0aCBkPSJNMTYgMjdoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNyAyN2gxdjFoLTF6Ii8+PHBhdGggZD0iTTE4IDI3aDF2MWgtMXoiLz48cGF0aCBkPSJNMTkgMjdoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMCAyN2gxdjFoLTF6Ii8+PHBhdGggZD0iTTIxIDI3aDF2MWgtMXoiLz48cGF0aCBkPSJNMjIgMjdoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMyAyN2gxdjFoLTF6Ii8+PHBhdGggZD0iTTI0IDI3aDF2MWgtMXoiLz48cGF0aCBkPSJNMjUgMjdoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNiAyN2gxdjFoLTF6Ii8+PHBhdGggZD0iTTI3IDI3aDF2MWgtMXoiLz48cGF0aCBkPSJNMjggMjdoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yOSAyN2gxdjFoLTF6Ii8+PHBhdGggZD0iTTMwIDI3aDF2MWgtMXoiLz48cGF0aCBkPSJNMzEgMjdoMXYxaC0xek0wIDI4aDF2MUgweiIvPjxwYXRoIGQ9Ik0xIDI4aDF2MUgxeiIvPjxwYXRoIGQ9Ik0yIDI4aDF2MUgyeiIvPjxwYXRoIGQ9Ik0zIDI4aDF2MUgzeiIvPjxwYXRoIGQ9Ik00IDI4aDF2MUg0eiIvPjxwYXRoIGQ9Ik01IDI4aDF2MUg1eiIvPjxwYXRoIGQ9Ik02IDI4aDF2MUg2eiIvPjxwYXRoIGQ9Ik03IDI4aDF2MUg3eiIvPjxwYXRoIGQ9Ik04IDI4aDF2MUg4eiIvPjxwYXRoIGQ9Ik05IDI4aDF2MUg5eiIvPjxwYXRoIGQ9Ik0xMCAyOGgxdjFoLTF6Ii8+PHBhdGggZD0iTTExIDI4aDF2MWgtMXoiLz48cGF0aCBkPSJNMTIgMjhoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xMyAyOGgxdjFoLTF6Ii8+PHBhdGggZD0iTTE0IDI4aDF2MWgtMXoiLz48cGF0aCBkPSJNMTUgMjhoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNiAyOGgxdjFoLTF6Ii8+PHBhdGggZD0iTTE3IDI4aDF2MWgtMXoiLz48cGF0aCBkPSJNMTggMjhoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xOSAyOGgxdjFoLTF6Ii8+PHBhdGggZD0iTTIwIDI4aDF2MWgtMXoiLz48cGF0aCBkPSJNMjEgMjhoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMiAyOGgxdjFoLTF6Ii8+PHBhdGggZD0iTTIzIDI4aDF2MWgtMXoiLz48cGF0aCBkPSJNMjQgMjhoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNSAyOGgxdjFoLTF6Ii8+PHBhdGggZD0iTTI2IDI4aDF2MWgtMXoiLz48cGF0aCBkPSJNMjcgMjhoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yOCAyOGgxdjFoLTF6Ii8+PHBhdGggZD0iTTI5IDI4aDF2MWgtMXoiLz48cGF0aCBkPSJNMzAgMjhoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0zMSAyOGgxdjFoLTF6TTAgMjloMXYxSDB6Ii8+PHBhdGggZD0iTTEgMjloMXYxSDF6Ii8+PHBhdGggZD0iTTIgMjloMXYxSDJ6Ii8+PHBhdGggZD0iTTMgMjloMXYxSDN6Ii8+PHBhdGggZD0iTTQgMjloMXYxSDR6Ii8+PHBhdGggZD0iTTUgMjloMXYxSDV6Ii8+PHBhdGggZD0iTTYgMjloMXYxSDZ6Ii8+PHBhdGggZD0iTTcgMjloMXYxSDd6Ii8+PHBhdGggZD0iTTggMjloMXYxSDh6Ii8+PHBhdGggZD0iTTkgMjloMXYxSDl6Ii8+PHBhdGggZD0iTTEwIDI5aDF2MWgtMXoiLz48cGF0aCBkPSJNMTEgMjloMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xMiAyOWgxdjFoLTF6Ii8+PHBhdGggZD0iTTEzIDI5aDF2MWgtMXoiLz48cGF0aCBkPSJNMTQgMjloMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNSAyOWgxdjFoLTF6Ii8+PHBhdGggZD0iTTE2IDI5aDF2MWgtMXoiLz48cGF0aCBkPSJNMTcgMjloMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xOCAyOWgxdjFoLTF6Ii8+PHBhdGggZD0iTTE5IDI5aDF2MWgtMXoiLz48cGF0aCBkPSJNMjAgMjloMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMSAyOWgxdjFoLTF6Ii8+PHBhdGggZD0iTTIyIDI5aDF2MWgtMXoiLz48cGF0aCBkPSJNMjMgMjloMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNCAyOWgxdjFoLTF6Ii8+PHBhdGggZD0iTTI1IDI5aDF2MWgtMXoiLz48cGF0aCBkPSJNMjYgMjloMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNyAyOWgxdjFoLTF6Ii8+PHBhdGggZD0iTTI4IDI5aDF2MWgtMXoiLz48cGF0aCBkPSJNMjkgMjloMXYxaC0xeiIvPjxwYXRoIGQ9Ik0zMCAyOWgxdjFoLTF6Ii8+PHBhdGggZD0iTTMxIDI5aDF2MWgtMXpNMCAzMGgxdjFIMHoiLz48cGF0aCBkPSJNMSAzMGgxdjFIMXoiLz48cGF0aCBkPSJNMiAzMGgxdjFIMnoiLz48cGF0aCBkPSJNMyAzMGgxdjFIM3oiLz48cGF0aCBkPSJNNCAzMGgxdjFINHoiLz48cGF0aCBkPSJNNSAzMGgxdjFINXoiLz48cGF0aCBkPSJNNiAzMGgxdjFINnoiLz48cGF0aCBkPSJNNyAzMGgxdjFIN3oiLz48cGF0aCBkPSJNOCAzMGgxdjFIOHoiLz48cGF0aCBkPSJNOSAzMGgxdjFIOXoiLz48cGF0aCBkPSJNMTAgMzBoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xMSAzMGgxdjFoLTF6Ii8+PHBhdGggZD0iTTEyIDMwaDF2MWgtMXoiLz48cGF0aCBkPSJNMTMgMzBoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNCAzMGgxdjFoLTF6Ii8+PHBhdGggZD0iTTE1IDMwaDF2MWgtMXoiLz48cGF0aCBkPSJNMTYgMzBoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNyAzMGgxdjFoLTF6Ii8+PHBhdGggZD0iTTE4IDMwaDF2MWgtMXoiLz48cGF0aCBkPSJNMTkgMzBoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMCAzMGgxdjFoLTF6Ii8+PHBhdGggZD0iTTIxIDMwaDF2MWgtMXoiLz48cGF0aCBkPSJNMjIgMzBoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMyAzMGgxdjFoLTF6Ii8+PHBhdGggZD0iTTI0IDMwaDF2MWgtMXoiLz48cGF0aCBkPSJNMjUgMzBoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNiAzMGgxdjFoLTF6Ii8+PHBhdGggZD0iTTI3IDMwaDF2MWgtMXoiLz48cGF0aCBkPSJNMjggMzBoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yOSAzMGgxdjFoLTF6Ii8+PHBhdGggZD0iTTMwIDMwaDF2MWgtMXoiLz48cGF0aCBkPSJNMzEgMzBoMXYxaC0xek0wIDMxaDF2MUgweiIvPjxwYXRoIGQ9Ik0xIDMxaDF2MUgxeiIvPjxwYXRoIGQ9Ik0yIDMxaDF2MUgyeiIvPjxwYXRoIGQ9Ik0zIDMxaDF2MUgzeiIvPjxwYXRoIGQ9Ik00IDMxaDF2MUg0eiIvPjxwYXRoIGQ9Ik01IDMxaDF2MUg1eiIvPjxwYXRoIGQ9Ik02IDMxaDF2MUg2eiIvPjxwYXRoIGQ9Ik03IDMxaDF2MUg3eiIvPjxwYXRoIGQ9Ik04IDMxaDF2MUg4eiIvPjxwYXRoIGQ9Ik05IDMxaDF2MUg5eiIvPjxwYXRoIGQ9Ik0xMCAzMWgxdjFoLTF6Ii8+PHBhdGggZD0iTTExIDMxaDF2MWgtMXoiLz48cGF0aCBkPSJNMTIgMzFoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xMyAzMWgxdjFoLTF6Ii8+PHBhdGggZD0iTTE0IDMxaDF2MWgtMXoiLz48cGF0aCBkPSJNMTUgMzFoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xNiAzMWgxdjFoLTF6Ii8+PHBhdGggZD0iTTE3IDMxaDF2MWgtMXoiLz48cGF0aCBkPSJNMTggMzFoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0xOSAzMWgxdjFoLTF6Ii8+PHBhdGggZD0iTTIwIDMxaDF2MWgtMXoiLz48cGF0aCBkPSJNMjEgMzFoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yMiAzMWgxdjFoLTF6Ii8+PHBhdGggZD0iTTIzIDMxaDF2MWgtMXoiLz48cGF0aCBkPSJNMjQgMzFoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yNSAzMWgxdjFoLTF6Ii8+PHBhdGggZD0iTTI2IDMxaDF2MWgtMXoiLz48cGF0aCBkPSJNMjcgMzFoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0yOCAzMWgxdjFoLTF6Ii8+PHBhdGggZD0iTTI5IDMxaDF2MWgtMXoiLz48cGF0aCBkPSJNMzAgMzFoMXYxaC0xeiIvPjxwYXRoIGQ9Ik0zMSAzMWgxdjFoLTF6Ii8+PC9nPjwvc3ZnPg==",
            "",
            "",
            address(0x1),
            10000
        );
    }

    function test__largeSVG() public {
        super.setCultureIndexParams(
            "Vrbs",
            "Our community Vrbs. Must be 32x32.",
            10,
            1,
            200,
            0,
            0,
            ICultureIndex.PieceMaximums({ name: 100, description: 2100, image: 64_000, text: 256, animationUrl: 100 }),
            ICultureIndex.MediaType.IMAGE,
            ICultureIndex.RequiredMediaPrefix.SVG
        );

        super.deployMock();

        createSvg();

        // expect revert on NONE
        vm.expectRevert(abi.encodeWithSignature("INVALID_MEDIA_TYPE()"));
        createArtPiece("Mona Lisa", "A masterpiece", ICultureIndex.MediaType.NONE, "", "", "", address(0x1), 10000);
    }
}
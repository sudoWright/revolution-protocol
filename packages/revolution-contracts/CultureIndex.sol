// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { IERC20 } from "./IERC20.sol";

contract CultureIndex {
    /// @notice The ERC20 token used for voting
    IERC20 public votingToken;

    // Initialize ERC20 Token in the constructor
    constructor(address _votingToken) {
        votingToken = IERC20(_votingToken);
    }

    // Add an enum for media types
    enum MediaType {
        NONE,
        IMAGE,
        ANIMATION,
        AUDIO,
        TEXT,
        OTHER
    }

    // Struct for art piece metadata
    struct ArtPieceMetadata {
        string name;
        string description;
        MediaType mediaType;
        string image; // optional
        string text; // optional
        string animationUrl; // optional
    }

    // Struct for creator with basis points
    struct CreatorBps {
        address creator;
        uint256 bps; // Basis points, must sum up to 10,000 for each ArtPiece
    }

    // Struct for art piece
    struct ArtPiece {
        uint256 id;
        ArtPieceMetadata metadata;
        CreatorBps[] creators;
    }

    // Struct for voter
    struct Voter {
        address voterAddress;
        uint256 weight;
    }

    /// @notice The list of all pieces
    mapping(uint256 => ArtPiece) public pieces;

    /// @notice The total number of pieces
    uint256 public pieceCount;

    /// @notice The list of all votes for a piece
    mapping(uint256 => Voter[]) public votes;

    /// @notice The total voting weight for a piece
    mapping(uint256 => uint256) public totalVoteWeights;

    /// @notice A mapping to keep track of whether the voter voted for the piece
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    /// @notice The event emitted when a new piece is created
    event PieceCreated(
        uint256 indexed id,
        address indexed sender,
        string name,
        string description,
        string image,
        string animationUrl
    );

    /// @notice The event emitted when a vote is cast
    event VoteCast(uint256 indexed pieceId, address indexed voter, uint256 weight);

    /// @notice The events emitted for the respective creators of a piece
    event PieceCreatorAdded(uint256 indexed id, address indexed creatorAddress, uint256 bps);

    /**
     * @notice Validates the media type and associated data.
     * @param metadata The metadata associated with the art piece.
     *
     * Requirements:
     * - The media type must be one of the defined types in the MediaType enum.
     * - The corresponding media data must not be empty.
     */
    function validateMediaType(ArtPieceMetadata memory metadata) internal pure {
        require(uint8(metadata.mediaType) > 0 && uint8(metadata.mediaType) <= 5, "Invalid media type");

        if (metadata.mediaType == MediaType.IMAGE) {
            require(bytes(metadata.image).length > 0, "Image URL must be provided");
        } else if (metadata.mediaType == MediaType.ANIMATION) {
            require(bytes(metadata.animationUrl).length > 0, "Video URL must be provided");
        } else if (metadata.mediaType == MediaType.TEXT) {
            require(bytes(metadata.text).length > 0, "Text must be provided");
        }
    }

    /**
     * @notice Gets the total basis points from an array of creators.
     * @param creatorArray An array of Creator structs containing address and basis points.
     * @return Returns the total basis points calculated from the array of creators.
     *
     * Requirements:
     * - The `creatorArray` must not contain any zero addresses.
     * - The function will return the total basis points which must be checked to be exactly 10,000.
     */
    function getTotalBpsFromCreators(CreatorBps[] memory creatorArray) internal pure returns (uint256) {
        uint256 totalBps = 0;
        for (uint i = 0; i < creatorArray.length; i++) {
            require(creatorArray[i].creator != address(0), "Invalid creator address");
            totalBps += creatorArray[i].bps;
        }
        return totalBps;
    }

    /**
     * @notice Creates a new piece of art with associated metadata and creators.
     * @param metadata The metadata associated with the art piece, including name, description, image, and optional animation URL.
     * @param creatorArray An array of creators who contributed to the piece, along with their respective basis points that must sum up to 10,000.
     * @return Returns the unique ID of the newly created art piece.
     *
     * Emits a {PieceCreated} event for the newly created piece.
     * Emits a {PieceCreatorAdded} event for each creator added to the piece.
     *
     * Requirements:
     * - `metadata` must include name, description, and image. Animation URL is optional.
     * - `creatorArray` must not contain any zero addresses.
     * - The sum of basis points in `creatorArray` must be exactly 10,000.
     */
    function createPiece(ArtPieceMetadata memory metadata, CreatorBps[] memory creatorArray) public returns (uint256) {
        uint256 totalBps = getTotalBpsFromCreators(creatorArray);
        require(totalBps == 10_000, "Total BPS must sum up to 10,000");

        // Validate the media type and associated data
        validateMediaType(metadata);

        pieceCount++;
        ArtPiece storage newPiece = pieces[pieceCount];

        newPiece.id = pieceCount;
        newPiece.metadata = metadata;

        for (uint i = 0; i < creatorArray.length; i++) {
            newPiece.creators.push(creatorArray[i]);
        }

        emit PieceCreated(
            pieceCount,
            msg.sender,
            metadata.name,
            metadata.description,
            metadata.image,
            metadata.animationUrl
        );

        // Emit an event for each creator
        for (uint i = 0; i < creatorArray.length; i++) {
            emit PieceCreatorAdded(pieceCount, creatorArray[i].creator, creatorArray[i].bps);
        }
        return newPiece.id;
    }

    /**
     * @notice Cast a vote for a specific ArtPiece.
     * @param pieceId The ID of the ArtPiece to vote for.
     * @dev Requires that the pieceId is valid, the voter has not already voted on this piece, and the weight is greater than zero.
     * Emits a VoteCast event upon successful execution.
     */
    function vote(uint256 pieceId) public {
        require(pieceId > 0 && pieceId <= pieceCount, "Invalid piece ID");
        require(!hasVoted[pieceId][msg.sender], "Already voted");

        // Fetch the weight from the ERC20 token balance
        uint256 weight = votingToken.balanceOf(msg.sender);
        require(weight > 0, "Weight must be greater than zero");

        Voter[] storage pieceVotes = votes[pieceId];

        // Record the vote
        Voter memory newVoter = Voter(msg.sender, weight);
        //Set has voted
        hasVoted[pieceId][msg.sender] = true;
        // Add the vote to the list of votes
        pieceVotes.push(newVoter);
        totalVoteWeights[pieceId] += weight;

        emit VoteCast(pieceId, msg.sender, weight);
    }

    function getPieceById(uint256 id) public view returns (ArtPiece memory) {
    return pieces[id];
    }
}
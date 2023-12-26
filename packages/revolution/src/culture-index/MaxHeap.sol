// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.22;

import { Ownable2StepUpgradeable } from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import { IRevolutionBuilder } from "../interfaces/IRevolutionBuilder.sol";

import { UUPS } from "../libs/proxy/UUPS.sol";
import { VersionedContract } from "../version/VersionedContract.sol";

/// @title MaxHeap implementation in Solidity
/// @dev This contract implements a Max Heap data structure with basic operations
/// @author Written by rocketman and gpt4
contract MaxHeap is VersionedContract, UUPS, Ownable2StepUpgradeable, ReentrancyGuardUpgradeable {
    /// @notice The parent contract that is allowed to update the data store
    address public admin;

    ///                                                          ///
    ///                         IMMUTABLES                       ///
    ///                                                          ///

    /// @notice The contract upgrade manager
    IRevolutionBuilder private immutable manager;

    ///                                                          ///
    ///                         CONSTRUCTOR                      ///
    ///                                                          ///

    /// @param _manager The contract upgrade manager address
    constructor(address _manager) payable initializer {
        manager = IRevolutionBuilder(_manager);
    }

    ///                                                          ///
    ///                          MODIFIERS                       ///
    ///                                                          ///

    /**
     * @notice Require that the minter has not been locked.
     */
    modifier onlyAdmin() {
        if (msg.sender != admin) revert SENDER_NOT_ADMIN();
        _;
    }

    ///                                                          ///
    ///                           ERRORS                         ///
    ///                                                          ///

    /// @notice Reverts for empty heap
    error EMPTY_HEAP();

    /// @notice Reverts for invalid manager initialization
    error SENDER_NOT_MANAGER();

    /// @notice Reverts for sender not admin
    error SENDER_NOT_ADMIN();

    /// @notice Reverts for address zero
    error INVALID_ADDRESS_ZERO();

    /// @notice Reverts for position zero
    error INVALID_POSITION_ZERO();

    ///                                                          ///
    ///                         INITIALIZER                      ///
    ///                                                          ///

    /**
     * @notice Initializes the maxheap contract
     * @param _initialOwner The initial owner of the contract
     * @param _admin The contract that is allowed to update the data store
     */
    function initialize(address _initialOwner, address _admin) public initializer {
        if (msg.sender != address(manager)) revert SENDER_NOT_MANAGER();
        if (_initialOwner == address(0)) revert INVALID_ADDRESS_ZERO();
        if (_admin == address(0)) revert INVALID_ADDRESS_ZERO();

        admin = _admin;

        __Ownable_init(_initialOwner);
        __ReentrancyGuard_init();
    }

    /// @notice Struct to represent an item in the heap by it's itemId: key = index in heap (the *size* incremented) | value = itemId
    mapping(uint256 => uint256) public heap;

    /// @notice the number of items in the heap
    uint256 public size = 0;

    /// @notice composite mapping of the heap position (index in the heap) and value of a specific item in the heap
    /// To enable value updates and indexing on external itemIds
    /// key = itemId
    struct Item {
        uint256 value;
        uint256 heapIndex;
    }
    mapping(uint256 => Item) public items;

    /// @notice Get the parent index of a given position
    /// @param pos The position for which to find the parent
    /// @return The index of the parent node
    function parent(uint256 pos) private pure returns (uint256) {
        if (pos == 0) revert INVALID_POSITION_ZERO();
        return (pos - 1) / 2;
    }

    /// @notice Swap two nodes in the heap
    /// @param fpos The position of the first node
    /// @param spos The position of the second node
    function swap(uint256 fpos, uint256 spos) private {
        (heap[fpos], heap[spos]) = (heap[spos], heap[fpos]);
        (items[heap[fpos]].heapIndex, items[heap[spos]].heapIndex) = (fpos, spos);
    }

    /// @notice Reheapify the heap starting at a given position
    /// @dev This ensures that the heap property is maintained
    /// @param pos The starting position for the heapify operation
    function maxHeapify(uint256 pos) internal {
        uint256 left = 2 * pos + 1;
        uint256 right = 2 * pos + 2;

        uint256 posValue = items[heap[pos]].value;
        uint256 leftValue = items[heap[left]].value;
        uint256 rightValue = items[heap[right]].value;

        if (pos >= (size / 2) && pos <= size) return;

        if (posValue < leftValue || posValue < rightValue) {
            if (leftValue > rightValue) {
                swap(pos, left);
                maxHeapify(left);
            } else {
                swap(pos, right);
                maxHeapify(right);
            }
        }
    }

    /// @notice Insert an element into the heap
    /// @param itemId The item ID to insert
    /// @param value The value to insert
    function insert(uint256 itemId, uint256 value) public onlyAdmin {
        heap[size] = itemId;
        items[itemId].value = value; // Update the value
        items[itemId].heapIndex = size; // Update the heap index

        uint256 current = size;
        while (current != 0 && items[heap[current]].value > items[heap[parent(current)]].value) {
            swap(current, parent(current));
            current = parent(current);
        }
        size++;
    }

    /// @notice Update the value of an existing item in the heap
    /// @param itemId The item ID whose vote count needs to be updated
    /// @param newValue The new value for the item
    /// @dev This function adjusts the heap to maintain the max-heap property after updating the vote count
    function updateValue(uint256 itemId, uint256 newValue) public onlyAdmin {
        uint256 position = items[itemId].heapIndex;
        uint256 oldValue = items[itemId].value;

        // Update the value
        items[itemId].value = newValue;

        // Decide whether to perform upwards or downwards heapify
        if (newValue > oldValue) {
            // Upwards heapify
            while (position != 0 && items[heap[position]].value > items[heap[parent(position)]].value) {
                swap(position, parent(position));
                position = parent(position);
            }
        } else if (newValue < oldValue) maxHeapify(position); // Downwards heapify
    }

    /// @notice Extract the maximum element from the heap
    /// @dev The function will revert if the heap is empty
    /// The value and position mapping will also be cleared
    /// @return The maximum element from the heap
    function extractMax() external onlyAdmin returns (uint256, uint256) {
        if (size == 0) revert EMPTY_HEAP();

        //itemId of the node with the max value
        uint256 popped = heap[0];

        //set the root node to the farthest leaf
        heap[0] = heap[--size];

        //maintain heap property
        maxHeapify(0);

        return (popped, items[popped].value);
    }

    /// @notice Get the maximum element from the heap
    /// @dev The function will revert if the heap is empty
    /// @return The maximum element from the heap
    function getMax() public view returns (uint256, uint256) {
        if (size == 0) revert EMPTY_HEAP();

        return (heap[0], items[heap[0]].value);
    }

    ///                                                          ///
    ///                     MAX HEAP UPGRADE                     ///
    ///                                                          ///

    /// @notice Ensures the caller is authorized to upgrade the contract and that the new implementation is valid
    /// @dev This function is called in `upgradeTo` & `upgradeToAndCall`
    /// @param _newImpl The new implementation address
    function _authorizeUpgrade(address _newImpl) internal view override onlyOwner {
        // Ensure the new implementation is a registered upgrade
        if (!manager.isRegisteredUpgrade(_getImplementation(), _newImpl)) revert INVALID_UPGRADE(_newImpl);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.22;

/// @title The Revolution builder contract

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

// LICENSE
// RevolutionBuilder.sol is a modified version of Nouns Builder's Manager.sol:
// https://github.com/ourzora/nouns-protocol/blob/82e00ed34dd9b7c9e1ac5eea29f7f713d1084e68/src/manager/Manager.sol
//
// Manager.sol source code under the MIT license.

import { Ownable2StepUpgradeable } from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";

import { RevolutionBuilderStorageV1 } from "./storage/RevolutionBuilderStorageV1.sol";
import { IRevolutionBuilder } from "../interfaces/IRevolutionBuilder.sol";
import { IRevolutionToken } from "../interfaces/IRevolutionToken.sol";
import { IRevolutionVotingPower } from "../interfaces/IRevolutionVotingPower.sol";
import { IDescriptor } from "../interfaces/IDescriptor.sol";
import { IAuctionHouse } from "../interfaces/IAuctionHouse.sol";
import { IDAOExecutor } from "../interfaces/IDAOExecutor.sol";
import { IRevolutionDAO } from "../interfaces/IRevolutionDAO.sol";
import { ICultureIndex } from "../interfaces/ICultureIndex.sol";
import { IMaxHeap } from "../interfaces/IMaxHeap.sol";
import { IRevolutionPointsEmitter } from "../interfaces/IRevolutionPointsEmitter.sol";
import { IRevolutionPoints } from "../interfaces/IRevolutionPoints.sol";
import { IVRGDAC } from "../interfaces/IVRGDAC.sol";

import { ERC1967Proxy } from "@cobuild/utility-contracts/src/proxy/ERC1967Proxy.sol";
import { UUPS } from "@cobuild/utility-contracts/src/proxy/UUPS.sol";
import { IVersionedContract } from "@cobuild/utility-contracts/src/interfaces/IVersionedContract.sol";
import { ISplitMain } from "@cobuild/splits/src/interfaces/ISplitMain.sol";
import { RevolutionVersion } from "../version/RevolutionVersion.sol";

/// @title RevolutionBuilder
/// @notice The Revolution DAO deployer and upgrade manager
contract RevolutionBuilder is
    IRevolutionBuilder,
    RevolutionVersion,
    UUPS,
    Ownable2StepUpgradeable,
    RevolutionBuilderStorageV1
{
    ///                                                          ///
    ///                          IMMUTABLES                      ///
    ///                                                          ///

    /// @notice The token implementation address
    address public immutable revolutionTokenImpl;

    /// @notice The descriptor implementation address
    address public immutable descriptorImpl;

    /// @notice The auction house implementation address
    address public immutable auctionImpl;

    /// @notice The executor implementation address
    address public immutable executorImpl;

    /// @notice The dao implementation address
    address public immutable daoImpl;

    /// @notice The revolutionPointsEmitter implementation address
    address public immutable revolutionPointsEmitterImpl;

    /// @notice The cultureIndex implementation address
    address public immutable cultureIndexImpl;

    /// @notice The revolutionPoints implementation address
    address public immutable revolutionPointsImpl;

    /// @notice The maxHeap implementation address
    address public immutable maxHeapImpl;

    /// @notice the revolutionVotingPower implementation address
    address public immutable revolutionVotingPowerImpl;

    /// @notice The VRGDAC implementation address
    address public immutable vrgdaImpl;

    /// @notice The SplitsCreator implementation address
    address public immutable splitsCreatorImpl;

    ///                                                          ///
    ///                          CONSTRUCTOR                     ///
    ///                                                          ///

    constructor(
        PointsImplementations memory _pointsImplementations,
        TokenImplementations memory _tokenImplementations,
        DAOImplementations memory _daoImplementations,
        CultureIndexImplementations memory _cultureIndexImplementations
    ) payable initializer {
        revolutionTokenImpl = _tokenImplementations.revolutionToken;
        descriptorImpl = _tokenImplementations.descriptor;
        auctionImpl = _tokenImplementations.auction;

        revolutionVotingPowerImpl = _daoImplementations.revolutionVotingPower;
        executorImpl = _daoImplementations.executor;
        daoImpl = _daoImplementations.dao;

        cultureIndexImpl = _cultureIndexImplementations.cultureIndex;
        maxHeapImpl = _cultureIndexImplementations.maxHeap;

        revolutionPointsEmitterImpl = _pointsImplementations.revolutionPointsEmitter;
        revolutionPointsImpl = _pointsImplementations.revolutionPoints;
        splitsCreatorImpl = _pointsImplementations.splitsCreator;
        vrgdaImpl = _pointsImplementations.vrgda;
    }

    ///                                                          ///
    ///                          INITIALIZER                     ///
    ///                                                          ///

    /// @notice Initializes ownership of the manager contract
    /// @param _newOwner The owner address to set (will be transferred to the Revolution DAO once its deployed)
    function initialize(address _newOwner) external initializer {
        // Ensure an owner is specified
        if (_newOwner == address(0)) revert INVALID_ZERO_ADDRESS();

        // Set the contract owner
        __Ownable_init(_newOwner);
    }

    ///                                                          ///
    ///                           DAO DEPLOY                     ///
    ///                                                          ///

    /// @notice Helper function to deploys initial DAO proxy contracts
    function _setupInitialProxies() internal returns (InitialProxySetup memory) {
        // Deploy the DAO's ERC-721 governance token
        address revolutionToken = address(new ERC1967Proxy(revolutionTokenImpl, ""));
        // Use the token address to precompute the DAO's remaining addresses
        bytes32 salt = bytes32(uint256(uint160(revolutionToken)) << 96);

        address executor = address(new ERC1967Proxy{ salt: salt }(executorImpl, ""));
        address revolutionVotingPower = address(new ERC1967Proxy{ salt: salt }(revolutionVotingPowerImpl, ""));

        address dao = address(new ERC1967Proxy{ salt: salt }(daoImpl, ""));

        address revolutionPointsEmitter = address(new ERC1967Proxy{ salt: salt }(revolutionPointsEmitterImpl, ""));

        return
            InitialProxySetup({
                revolutionToken: revolutionToken,
                executor: executor,
                revolutionVotingPower: revolutionVotingPower,
                dao: dao,
                salt: salt,
                revolutionPointsEmitter: revolutionPointsEmitter
            });
    }

    /// @notice Deploys a DAO with custom token, auction, emitter, revolution points, and governance settings
    /// @param _initialOwner The initial owner address
    /// @param _weth The WETH address
    /// @param _revolutionTokenParams The ERC-721 token settings
    /// @param _auctionParams The auction settings
    /// @param _govParams The governance settings
    /// @param _cultureIndexParams The culture index settings
    /// @param _revolutionPointsParams The ERC-20 token settings
    /// @param _revolutionVotingPowerParams The voting power settings
    function deploy(
        address _initialOwner,
        address _weth,
        RevolutionTokenParams calldata _revolutionTokenParams,
        AuctionParams calldata _auctionParams,
        GovParams calldata _govParams,
        CultureIndexParams calldata _cultureIndexParams,
        RevolutionPointsParams calldata _revolutionPointsParams,
        RevolutionVotingPowerParams calldata _revolutionVotingPowerParams
    ) external returns (DAOAddresses memory) {
        if (_initialOwner == address(0)) revert INVALID_ZERO_ADDRESS();

        InitialProxySetup memory initialSetup = _setupInitialProxies();

        address revolutionToken = initialSetup.revolutionToken;

        // Deploy the remaining DAO contracts
        daoAddressesByToken[initialSetup.revolutionToken] = DAOAddresses({
            revolutionPoints: address(new ERC1967Proxy{ salt: initialSetup.salt }(revolutionPointsImpl, "")),
            cultureIndex: address(new ERC1967Proxy{ salt: initialSetup.salt }(cultureIndexImpl, "")),
            splitsCreator: address(new ERC1967Proxy{ salt: initialSetup.salt }(splitsCreatorImpl, "")),
            descriptor: address(new ERC1967Proxy{ salt: initialSetup.salt }(descriptorImpl, "")),
            auction: address(new ERC1967Proxy{ salt: initialSetup.salt }(auctionImpl, "")),
            maxHeap: address(new ERC1967Proxy{ salt: initialSetup.salt }(maxHeapImpl, "")),
            vrgda: address(new ERC1967Proxy{ salt: initialSetup.salt }(vrgdaImpl, "")),
            revolutionPointsEmitter: initialSetup.revolutionPointsEmitter,
            revolutionVotingPower: initialSetup.revolutionVotingPower,
            revolutionToken: revolutionToken,
            executor: initialSetup.executor,
            dao: initialSetup.dao
        });

        ISplitMain(daoAddressesByToken[revolutionToken].splitsCreator).initialize({
            pointsEmitter: initialSetup.revolutionPointsEmitter,
            initialOwner: initialSetup.executor
        });

        IRevolutionDAO(daoAddressesByToken[revolutionToken].dao).initialize({
            executor: initialSetup.executor,
            votingPower: daoAddressesByToken[revolutionToken].revolutionVotingPower,
            govParams: _govParams
        });

        // Initialize each instance with the provided settings
        IMaxHeap(daoAddressesByToken[revolutionToken].maxHeap).initialize({
            initialOwner: initialSetup.executor,
            admin: daoAddressesByToken[revolutionToken].cultureIndex
        });

        IVRGDAC(daoAddressesByToken[revolutionToken].vrgda).initialize({
            initialOwner: initialSetup.executor,
            targetPrice: _revolutionPointsParams.emitterParams.vrgdaParams.targetPrice,
            priceDecayPercent: _revolutionPointsParams.emitterParams.vrgdaParams.priceDecayPercent,
            perTimeUnit: _revolutionPointsParams.emitterParams.vrgdaParams.tokensPerTimeUnit
        });

        IRevolutionVotingPower(daoAddressesByToken[revolutionToken].revolutionVotingPower).initialize({
            initialOwner: initialSetup.executor,
            revolutionPoints: daoAddressesByToken[revolutionToken].revolutionPoints,
            pointsVoteWeight: _revolutionVotingPowerParams.pointsVoteWeight,
            revolutionToken: daoAddressesByToken[revolutionToken].revolutionToken,
            tokenVoteWeight: _revolutionVotingPowerParams.tokenVoteWeight
        });

        IRevolutionToken(revolutionToken).initialize({
            minter: daoAddressesByToken[revolutionToken].auction,
            descriptor: daoAddressesByToken[revolutionToken].descriptor,
            initialOwner: initialSetup.executor,
            cultureIndex: daoAddressesByToken[revolutionToken].cultureIndex,
            revolutionTokenParams: _revolutionTokenParams
        });

        IDescriptor(daoAddressesByToken[revolutionToken].descriptor).initialize({
            initialOwner: initialSetup.executor,
            tokenNamePrefix: _revolutionTokenParams.tokenNamePrefix
        });

        ICultureIndex(daoAddressesByToken[revolutionToken].cultureIndex).initialize({
            votingPower: daoAddressesByToken[revolutionToken].revolutionVotingPower,
            initialOwner: _initialOwner,
            dropperAdmin: daoAddressesByToken[revolutionToken].revolutionToken,
            cultureIndexParams: _cultureIndexParams,
            maxHeap: daoAddressesByToken[revolutionToken].maxHeap
        });

        IAuctionHouse(daoAddressesByToken[revolutionToken].auction).initialize({
            revolutionToken: daoAddressesByToken[revolutionToken].revolutionToken,
            revolutionPointsEmitter: daoAddressesByToken[revolutionToken].revolutionPointsEmitter,
            /// @notice So the auction can be unpaused easily
            /// @dev the _initialOwner should immediately transfer ownership to the DAO after unpausing the auction
            initialOwner: _initialOwner,
            auctionParams: _auctionParams,
            weth: _weth
        });

        //make owner and minter of the points the _initialOwner for founder allocation
        IRevolutionPoints(daoAddressesByToken[revolutionToken].revolutionPoints).initialize({
            initialOwner: _initialOwner,
            minter: _initialOwner,
            tokenParams: _revolutionPointsParams.tokenParams
        });

        IRevolutionPointsEmitter(daoAddressesByToken[revolutionToken].revolutionPointsEmitter).initialize({
            revolutionPoints: daoAddressesByToken[revolutionToken].revolutionPoints,
            initialOwner: initialSetup.executor,
            weth: _weth,
            vrgda: daoAddressesByToken[revolutionToken].vrgda,
            founderParams: _revolutionPointsParams.emitterParams.founderParams,
            grantsParams: _revolutionPointsParams.emitterParams.grantsParams
        });

        IDAOExecutor(daoAddressesByToken[revolutionToken].executor).initialize({
            admin: initialSetup.dao,
            timelockDelay: _govParams.timelockDelay,
            data: bytes("")
        });

        emit RevolutionDeployed({
            revolutionPointsEmitter: daoAddressesByToken[revolutionToken].revolutionPointsEmitter,
            revolutionPoints: daoAddressesByToken[revolutionToken].revolutionPoints,
            splitsCreator: daoAddressesByToken[revolutionToken].splitsCreator,
            cultureIndex: daoAddressesByToken[revolutionToken].cultureIndex,
            descriptor: daoAddressesByToken[revolutionToken].descriptor,
            revolutionVotingPower: initialSetup.revolutionVotingPower,
            auction: daoAddressesByToken[revolutionToken].auction,
            maxHeap: daoAddressesByToken[revolutionToken].maxHeap,
            vrgda: daoAddressesByToken[revolutionToken].vrgda,
            revolutionToken: revolutionToken,
            executor: initialSetup.executor,
            dao: initialSetup.dao
        });

        return daoAddressesByToken[revolutionToken];
    }

    ///                                                          ///
    ///                         DAO ADDRESSES                    ///
    ///                                                          ///

    /// @notice A DAO's contract addresses from its token
    /// @param _token The ERC-721 token address
    /// @return revolutionToken ERC-721 token deployed address
    /// @return descriptor Descriptor deployed address
    /// @return auction Auction deployed address
    /// @return executor Executor deployed address
    /// @return dao DAO deployed address
    /// @return cultureIndex CultureIndex deployed address
    /// @return revolutionPoints ERC-20 token deployed address
    /// @return revolutionPointsEmitter ERC-20 points emitter deployed address
    /// @return maxHeap MaxHeap deployed address
    /// @return revolutionVotingPower RevolutionVotingPower deployed address
    /// @return vrgda VRGDAC deployed address
    /// @return splitsCreator SplitsCreator deployed address
    function getAddresses(
        address _token
    )
        public
        view
        returns (
            address revolutionToken,
            address descriptor,
            address auction,
            address executor,
            address dao,
            address cultureIndex,
            address revolutionPoints,
            address revolutionPointsEmitter,
            address maxHeap,
            address revolutionVotingPower,
            address vrgda,
            address splitsCreator
        )
    {
        DAOAddresses storage addresses = daoAddressesByToken[_token];

        descriptor = addresses.descriptor;
        auction = addresses.auction;
        revolutionToken = addresses.revolutionToken;
        executor = addresses.executor;
        dao = addresses.dao;

        cultureIndex = addresses.cultureIndex;
        revolutionPoints = addresses.revolutionPoints;
        revolutionPointsEmitter = addresses.revolutionPointsEmitter;
        maxHeap = addresses.maxHeap;
        revolutionVotingPower = addresses.revolutionVotingPower;
        vrgda = addresses.vrgda;
        splitsCreator = addresses.splitsCreator;
    }

    ///                                                          ///
    ///                         CULTURE INDEX                    ///
    ///                                                          ///

    /// @notice Deploys a culture index for a given token
    /// @param votingPower The voting power address
    /// @param initialOwner The initial owner address
    /// @param dropperAdmin The dropper admin address
    /// @param cultureIndexParams The CultureIndex settings
    /// @return cultureIndex The deployed culture index address
    /// @return maxHeap The deployed max heap address
    function deployCultureIndex(
        address votingPower,
        address initialOwner,
        address dropperAdmin,
        CultureIndexParams calldata cultureIndexParams
    ) external override returns (address cultureIndex, address maxHeap) {
        cultureIndex = address(new ERC1967Proxy(cultureIndexImpl, ""));
        maxHeap = address(new ERC1967Proxy(maxHeapImpl, ""));

        ICultureIndex(cultureIndex).initialize({
            votingPower: votingPower,
            initialOwner: initialOwner,
            dropperAdmin: dropperAdmin,
            cultureIndexParams: cultureIndexParams,
            maxHeap: maxHeap
        });

        IMaxHeap(maxHeap).initialize({ initialOwner: initialOwner, admin: cultureIndex });

        emit CultureIndexDeployed(cultureIndex, maxHeap, votingPower);

        return (cultureIndex, maxHeap);
    }

    ///                                                          ///
    ///                          DAO UPGRADES                    ///
    ///                                                          ///

    /// @notice If an implementation is registered by the Revolution DAO as an optional upgrade
    /// @param _baseImpl The base implementation address
    /// @param _upgradeImpl The upgrade implementation address
    function isRegisteredUpgrade(address _baseImpl, address _upgradeImpl) external view returns (bool) {
        return isUpgrade[_baseImpl][_upgradeImpl];
    }

    /// @notice Called by the Revolution DAO to offer implementation upgrades for created DAOs
    /// @param _baseImpl The base implementation address
    /// @param _upgradeImpl The upgrade implementation address
    function registerUpgrade(address _baseImpl, address _upgradeImpl) external onlyOwner {
        isUpgrade[_baseImpl][_upgradeImpl] = true;

        emit UpgradeRegistered(_baseImpl, _upgradeImpl);
    }

    /// @notice Called by the Revolution DAO to remove an upgrade
    /// @param _baseImpl The base implementation address
    /// @param _upgradeImpl The upgrade implementation address
    function removeUpgrade(address _baseImpl, address _upgradeImpl) external onlyOwner {
        delete isUpgrade[_baseImpl][_upgradeImpl];

        emit UpgradeRemoved(_baseImpl, _upgradeImpl);
    }

    /// @notice Safely get the contract version of a target contract.
    /// @dev Assume `target` is a contract
    /// @return Contract version if found, empty string if not.
    function _safeGetVersion(address target) internal view returns (string memory) {
        try IVersionedContract(target).contractVersion() returns (string memory version) {
            return version;
        } catch {
            return "";
        }
    }

    function getDAOVersions(address token) external view returns (DAOVersionInfo memory) {
        (
            address revolutionToken,
            address descriptor,
            address auction,
            address executor,
            address dao,
            address cultureIndex,
            address revolutionPoints,
            address revolutionPointsEmitter,
            address maxHeap,
            address revolutionVotingPower,
            address vrgda,

        ) = getAddresses(token);
        return
            DAOVersionInfo({
                revolutionToken: _safeGetVersion(revolutionToken),
                descriptor: _safeGetVersion(descriptor),
                auction: _safeGetVersion(auction),
                executor: _safeGetVersion(executor),
                dao: _safeGetVersion(dao),
                revolutionPoints: _safeGetVersion(revolutionPoints),
                cultureIndex: _safeGetVersion(cultureIndex),
                revolutionPointsEmitter: _safeGetVersion(revolutionPointsEmitter),
                maxHeap: _safeGetVersion(maxHeap),
                revolutionVotingPower: _safeGetVersion(revolutionVotingPower),
                vrgda: _safeGetVersion(vrgda)
            });
    }

    function getLatestVersions() external view returns (DAOVersionInfo memory) {
        return
            DAOVersionInfo({
                revolutionToken: _safeGetVersion(revolutionTokenImpl),
                descriptor: _safeGetVersion(descriptorImpl),
                auction: _safeGetVersion(auctionImpl),
                executor: _safeGetVersion(executorImpl),
                dao: _safeGetVersion(daoImpl),
                cultureIndex: _safeGetVersion(cultureIndexImpl),
                revolutionPoints: _safeGetVersion(revolutionPointsImpl),
                revolutionPointsEmitter: _safeGetVersion(revolutionPointsEmitterImpl),
                maxHeap: _safeGetVersion(maxHeapImpl),
                revolutionVotingPower: _safeGetVersion(revolutionVotingPowerImpl),
                vrgda: _safeGetVersion(vrgdaImpl)
            });
    }

    ///                                                          ///
    ///                           EXTENSIONS                     ///
    ///                                                          ///

    /// @notice Called by the Revolution DAO to add an extension
    /// @param _extensionName The user readable name of the extension domain, i.e. the name of the DApp or the protocol.
    /// @param _builder The address of the extension builder to pay rewards to
    /// @param _extensionImpls The extension implementation addresses
    function registerExtension(
        string calldata _extensionName,
        address _builder,
        DAOAddresses calldata _extensionImpls
    ) external onlyOwner {
        if (isExtension[_extensionName]) revert EXTENSION_EXISTS();

        // emit the extension added event
        emit ExtensionRegistered(_extensionName, _builder, _extensionImpls);

        // set the extension as valid
        isExtension[_extensionName] = true;

        // set the extension implementations for each contract
        extensionImpls[_extensionName][ImplementationType.DAO] = _extensionImpls.dao;
        extensionImpls[_extensionName][ImplementationType.Executor] = _extensionImpls.executor;
        extensionImpls[_extensionName][ImplementationType.VRGDAC] = _extensionImpls.vrgda;
        extensionImpls[_extensionName][ImplementationType.Descriptor] = _extensionImpls.descriptor;
        extensionImpls[_extensionName][ImplementationType.Auction] = _extensionImpls.auction;
        extensionImpls[_extensionName][ImplementationType.CultureIndex] = _extensionImpls.cultureIndex;
        extensionImpls[_extensionName][ImplementationType.MaxHeap] = _extensionImpls.maxHeap;
        extensionImpls[_extensionName][ImplementationType.RevolutionPoints] = _extensionImpls.revolutionPoints;
        extensionImpls[_extensionName][ImplementationType.RevolutionPointsEmitter] = _extensionImpls
            .revolutionPointsEmitter;
        extensionImpls[_extensionName][ImplementationType.RevolutionToken] = _extensionImpls.revolutionToken;
        extensionImpls[_extensionName][ImplementationType.RevolutionVotingPower] = _extensionImpls
            .revolutionVotingPower;
        extensionImpls[_extensionName][ImplementationType.SplitsCreator] = _extensionImpls.splitsCreator;

        // Set builder reward address for the extension
        builderRewards[_extensionName] = _builder;
    }

    /// @notice Called by the Revolution DAO to remove an extension
    /// @param _extensionName The name of the extension
    function removeExtension(string calldata _extensionName) external onlyOwner {
        delete isExtension[_extensionName];

        delete extensionImpls[_extensionName][ImplementationType.DAO];
        delete extensionImpls[_extensionName][ImplementationType.Executor];
        delete extensionImpls[_extensionName][ImplementationType.VRGDAC];
        delete extensionImpls[_extensionName][ImplementationType.Descriptor];
        delete extensionImpls[_extensionName][ImplementationType.Auction];
        delete extensionImpls[_extensionName][ImplementationType.CultureIndex];
        delete extensionImpls[_extensionName][ImplementationType.MaxHeap];
        delete extensionImpls[_extensionName][ImplementationType.RevolutionPoints];
        delete extensionImpls[_extensionName][ImplementationType.RevolutionPointsEmitter];
        delete extensionImpls[_extensionName][ImplementationType.RevolutionToken];
        delete extensionImpls[_extensionName][ImplementationType.RevolutionVotingPower];
        delete extensionImpls[_extensionName][ImplementationType.SplitsCreator];

        delete builderRewards[_extensionName];

        emit ExtensionRemoved(_extensionName);
    }

    /// @notice If an implementation is registered by the Revolution DAO as an optional upgrade
    /// @param _extensionName The name of the extension
    function isRegisteredExtension(string calldata _extensionName) external view returns (bool) {
        return isExtension[_extensionName];
    }

    /// @notice Get extension's implementation
    /// @param _extensionName The name of the extension
    /// @param _implementationType The type of the implementation
    function getExtensionImplementation(
        string calldata _extensionName,
        ImplementationType _implementationType
    ) external view returns (address) {
        return extensionImpls[_extensionName][_implementationType];
    }

    /// @notice Get extension's builder reward address
    /// @param _extensionName The name of the extension
    function getExtensionBuilder(string calldata _extensionName) external view returns (address) {
        return builderRewards[_extensionName];
    }

    /// @notice Get extension's name by token
    /// @param _token The token address
    function getExtensionByToken(address _token) external view returns (string memory) {
        return extensionByToken[_token];
    }

    ///                                                          ///
    ///                    DEPLOY EXTENSIONS                     ///
    ///                                                          ///

    /// @notice Helper function to deploys initial DAO proxy contracts
    function _setupInitialExtensionProxies(string calldata extensionName) internal returns (InitialProxySetup memory) {
        // Deploy the DAO's ERC-721 governance token
        address revolutionToken = address(
            new ERC1967Proxy(extensionImpls[extensionName][ImplementationType.RevolutionToken], "")
        );
        // Use the token address to precompute the DAO's remaining addresses
        bytes32 salt = bytes32(uint256(uint160(revolutionToken)) << 96);

        address executor = address(
            new ERC1967Proxy{ salt: salt }(extensionImpls[extensionName][ImplementationType.Executor], "")
        );
        address revolutionVotingPower = address(
            new ERC1967Proxy{ salt: salt }(extensionImpls[extensionName][ImplementationType.RevolutionVotingPower], "")
        );

        address dao = address(
            new ERC1967Proxy{ salt: salt }(extensionImpls[extensionName][ImplementationType.DAO], "")
        );

        address revolutionPointsEmitter = address(
            new ERC1967Proxy{ salt: salt }(
                extensionImpls[extensionName][ImplementationType.RevolutionPointsEmitter],
                ""
            )
        );

        return
            InitialProxySetup({
                revolutionToken: revolutionToken,
                executor: executor,
                revolutionVotingPower: revolutionVotingPower,
                dao: dao,
                salt: salt,
                revolutionPointsEmitter: revolutionPointsEmitter
            });
    }

    /// @notice Deploys an extended DAO with custom token, auction, emitter, revolution points, and governance settings
    /// @param _initialOwner The initial owner address
    /// @param _weth The WETH address
    /// @param _revolutionTokenParams The ERC-721 token settings
    /// @param _auctionParams The auction settings
    /// @param _govParams The governance settings
    /// @param _cultureIndexParams The culture index settings
    /// @param _revolutionPointsParams The ERC-20 token settings
    /// @param _revolutionVotingPowerParams The voting power settings
    /// @param _extensionData The data for the extension
    function deployExtension(
        address _initialOwner,
        address _weth,
        RevolutionTokenParams calldata _revolutionTokenParams,
        AuctionParams calldata _auctionParams,
        GovParams calldata _govParams,
        CultureIndexParams calldata _cultureIndexParams,
        RevolutionPointsParams calldata _revolutionPointsParams,
        RevolutionVotingPowerParams calldata _revolutionVotingPowerParams,
        // extension
        ExtensionData calldata _extensionData
    ) external returns (DAOAddresses memory) {
        if (_initialOwner == address(0)) revert INVALID_ZERO_ADDRESS();
        if (!isExtension[_extensionData.name]) revert INVALID_EXTENSION();

        InitialProxySetup memory initialSetup = _setupInitialExtensionProxies(_extensionData.name);

        address revolutionToken = initialSetup.revolutionToken;

        // register the extension by token
        extensionByToken[revolutionToken] = _extensionData.name;

        // Deploy the remaining DAO contracts
        daoAddressesByToken[initialSetup.revolutionToken] = DAOAddresses({
            revolutionPoints: address(
                new ERC1967Proxy{ salt: initialSetup.salt }(
                    extensionImpls[_extensionData.name][ImplementationType.RevolutionPoints],
                    ""
                )
            ),
            cultureIndex: address(
                new ERC1967Proxy{ salt: initialSetup.salt }(
                    extensionImpls[_extensionData.name][ImplementationType.CultureIndex],
                    ""
                )
            ),
            splitsCreator: address(
                new ERC1967Proxy{ salt: initialSetup.salt }(
                    extensionImpls[_extensionData.name][ImplementationType.SplitsCreator],
                    ""
                )
            ),
            descriptor: address(
                new ERC1967Proxy{ salt: initialSetup.salt }(
                    extensionImpls[_extensionData.name][ImplementationType.Descriptor],
                    ""
                )
            ),
            auction: address(
                new ERC1967Proxy{ salt: initialSetup.salt }(
                    extensionImpls[_extensionData.name][ImplementationType.Auction],
                    ""
                )
            ),
            maxHeap: address(
                new ERC1967Proxy{ salt: initialSetup.salt }(
                    extensionImpls[_extensionData.name][ImplementationType.MaxHeap],
                    ""
                )
            ),
            vrgda: address(
                new ERC1967Proxy{ salt: initialSetup.salt }(
                    extensionImpls[_extensionData.name][ImplementationType.VRGDAC],
                    ""
                )
            ),
            revolutionPointsEmitter: initialSetup.revolutionPointsEmitter,
            revolutionVotingPower: initialSetup.revolutionVotingPower,
            revolutionToken: revolutionToken,
            executor: initialSetup.executor,
            dao: initialSetup.dao
        });

        ISplitMain(daoAddressesByToken[revolutionToken].splitsCreator).initialize({
            pointsEmitter: initialSetup.revolutionPointsEmitter,
            initialOwner: _initialOwner
        });

        IRevolutionDAO(daoAddressesByToken[revolutionToken].dao).initialize({
            executor: initialSetup.executor,
            votingPower: daoAddressesByToken[revolutionToken].revolutionVotingPower,
            govParams: _govParams
        });

        // Initialize each instance with the provided settings
        IMaxHeap(daoAddressesByToken[revolutionToken].maxHeap).initialize({
            initialOwner: _initialOwner,
            admin: daoAddressesByToken[revolutionToken].cultureIndex
        });

        IVRGDAC(daoAddressesByToken[revolutionToken].vrgda).initialize({
            initialOwner: _initialOwner,
            targetPrice: _revolutionPointsParams.emitterParams.vrgdaParams.targetPrice,
            priceDecayPercent: _revolutionPointsParams.emitterParams.vrgdaParams.priceDecayPercent,
            perTimeUnit: _revolutionPointsParams.emitterParams.vrgdaParams.tokensPerTimeUnit
        });

        IRevolutionVotingPower(daoAddressesByToken[revolutionToken].revolutionVotingPower).initialize({
            initialOwner: _initialOwner,
            revolutionPoints: daoAddressesByToken[revolutionToken].revolutionPoints,
            pointsVoteWeight: _revolutionVotingPowerParams.pointsVoteWeight,
            revolutionToken: daoAddressesByToken[revolutionToken].revolutionToken,
            tokenVoteWeight: _revolutionVotingPowerParams.tokenVoteWeight
        });

        IRevolutionToken(revolutionToken).initialize({
            minter: daoAddressesByToken[revolutionToken].auction,
            descriptor: daoAddressesByToken[revolutionToken].descriptor,
            initialOwner: _initialOwner,
            cultureIndex: daoAddressesByToken[revolutionToken].cultureIndex,
            revolutionTokenParams: _revolutionTokenParams
        });

        IDescriptor(daoAddressesByToken[revolutionToken].descriptor).initialize({
            initialOwner: _initialOwner,
            tokenNamePrefix: _revolutionTokenParams.tokenNamePrefix
        });

        ICultureIndex(daoAddressesByToken[revolutionToken].cultureIndex).initialize({
            votingPower: daoAddressesByToken[revolutionToken].revolutionVotingPower,
            initialOwner: _initialOwner,
            dropperAdmin: daoAddressesByToken[revolutionToken].revolutionToken,
            cultureIndexParams: _cultureIndexParams,
            maxHeap: daoAddressesByToken[revolutionToken].maxHeap
        });

        IAuctionHouse(daoAddressesByToken[revolutionToken].auction).initialize({
            revolutionToken: daoAddressesByToken[revolutionToken].revolutionToken,
            revolutionPointsEmitter: daoAddressesByToken[revolutionToken].revolutionPointsEmitter,
            /// @notice So the auction can be unpaused easily
            /// @dev the _initialOwner should immediately transfer ownership to the DAO after unpausing the auction
            initialOwner: _initialOwner,
            auctionParams: _auctionParams,
            weth: _weth
        });

        //make owner and minter of the points the _initialOwner for founder allocation
        IRevolutionPoints(daoAddressesByToken[revolutionToken].revolutionPoints).initialize({
            initialOwner: _initialOwner,
            minter: _initialOwner,
            tokenParams: _revolutionPointsParams.tokenParams
        });

        IRevolutionPointsEmitter(daoAddressesByToken[revolutionToken].revolutionPointsEmitter).initialize({
            revolutionPoints: daoAddressesByToken[revolutionToken].revolutionPoints,
            initialOwner: _initialOwner,
            weth: _weth,
            vrgda: daoAddressesByToken[revolutionToken].vrgda,
            founderParams: _revolutionPointsParams.emitterParams.founderParams,
            grantsParams: _revolutionPointsParams.emitterParams.grantsParams
        });

        IDAOExecutor(daoAddressesByToken[revolutionToken].executor).initialize({
            admin: initialSetup.dao,
            timelockDelay: _govParams.timelockDelay,
            data: _extensionData.executorInitializationData
        });

        emit RevolutionDeployed({
            revolutionPointsEmitter: daoAddressesByToken[revolutionToken].revolutionPointsEmitter,
            revolutionPoints: daoAddressesByToken[revolutionToken].revolutionPoints,
            splitsCreator: daoAddressesByToken[revolutionToken].splitsCreator,
            cultureIndex: daoAddressesByToken[revolutionToken].cultureIndex,
            descriptor: daoAddressesByToken[revolutionToken].descriptor,
            revolutionVotingPower: initialSetup.revolutionVotingPower,
            auction: daoAddressesByToken[revolutionToken].auction,
            maxHeap: daoAddressesByToken[revolutionToken].maxHeap,
            vrgda: daoAddressesByToken[revolutionToken].vrgda,
            revolutionToken: revolutionToken,
            executor: initialSetup.executor,
            dao: initialSetup.dao
        });

        return daoAddressesByToken[revolutionToken];
    }

    ///                                                          ///
    ///                         MANAGER UPGRADE                  ///
    ///                                                          ///

    /// @notice Ensures the caller is authorized to upgrade the contract
    /// @dev This function is called in `upgradeTo` & `upgradeToAndCall`
    /// @param _newImpl The new implementation address
    function _authorizeUpgrade(address _newImpl) internal override onlyOwner {}
}

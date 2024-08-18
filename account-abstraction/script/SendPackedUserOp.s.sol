// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import {MinimalAccount} from "../src/ethereum/MinimalAccount.sol";
import {IAccount, PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/IAccount.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// forge script script/SendPackedUserOp.s.sol --rpc-url $RPC_URL --account customFoundryAccountName --broadcast -vvv
contract SendPackedUserOp is Script {
    using MessageHashUtils for bytes32;

    /// @dev this is a place holder for our deployed MinimalAccount
    address constant MINIMAL_ACCOUNT = address(1);
    /// @dev this is a place holder for USDC
    address constant USDC = address(2);

    function run() public {
        HelperConfig helperConfig = new HelperConfig();
        address dest = USDC;
        uint256 value = 0;
        address receiver = makeAddr("receiver");
        uint256 amountToApprove = 1e6; // 1 USDC
        bytes memory functionData = abi.encodeWithSelector(IERC20.approve.selector, receiver, amountToApprove);
        bytes memory executeCallData =
            abi.encodeWithSelector(MinimalAccount.execute.selector, dest, value, functionData);
        PackedUserOperation memory userOp =
            generateSignedUserOperation(executeCallData, helperConfig.getConfig(), MINIMAL_ACCOUNT);
        PackedUserOperation[] memory ops = new PackedUserOperation[](1);
        ops[0] = userOp;

        vm.startBroadcast();
        IEntryPoint(helperConfig.getConfig().entryPoint).handleOps(ops, payable(helperConfig.getConfig().account));
    }

    function generateSignedUserOperation(
        bytes memory _callData,
        HelperConfig.NetworkConfig memory _config,
        address _minimalAccount
    ) public view returns (PackedUserOperation memory) {
        // 1. Generate unsigned data
        uint256 nonce = vm.getNonce(_minimalAccount) - 1;
        PackedUserOperation memory userOperation = _generateUnsignedUserOperation(_callData, _minimalAccount, nonce);

        // 2. Get the userOp hash
        bytes32 userOpHash = IEntryPoint(_config.entryPoint).getUserOpHash(userOperation);
        bytes32 digest = userOpHash.toEthSignedMessageHash();

        // 3. Sign it and return it
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 ANVIL_DEFAULT_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

        if (block.chainid == 31337) (v, r, s) = vm.sign(ANVIL_DEFAULT_KEY, digest);
        else (v, r, s) = vm.sign(_config.account, digest);

        userOperation.signature = abi.encodePacked(r, s, v); // Note the order
        return userOperation;
    }

    function _generateUnsignedUserOperation(bytes memory _callData, address _sender, uint256 _nonce)
        internal
        pure
        returns (PackedUserOperation memory)
    {
        uint128 verificationGasLimit = 16777216;
        uint128 callGasLimit = verificationGasLimit;
        uint128 maxPriorityFeePerGas = 256;
        uint128 maxFeePerGas = maxPriorityFeePerGas;

        return PackedUserOperation({
            sender: _sender,
            nonce: _nonce,
            initCode: hex"",
            callData: _callData,
            accountGasLimits: bytes32(uint256(verificationGasLimit) << 128 | callGasLimit),
            preVerificationGas: verificationGasLimit,
            gasFees: bytes32(uint256(maxPriorityFeePerGas) << 128 | maxFeePerGas),
            paymasterAndData: hex"",
            signature: hex""
        });
    }
}

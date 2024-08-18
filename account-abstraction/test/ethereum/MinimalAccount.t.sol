// SDPX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {MinimalAccount} from "../../src/ethereum/MinimalAccount.sol";
import {DeployMinimal} from "../../script/DeployMinimal.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract MinimalAccountTest is Test {
    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    HelperConfig helperConfig;
    MinimalAccount minimalAccount;
    ERC20Mock usdc;

    uint256 constant AMOUNT = 1e18;

    /*//////////////////////////////////////////////////////////////
                                 SETUP
    //////////////////////////////////////////////////////////////*/
    function setUp() public {
        DeployMinimal deployMinimal = new DeployMinimal();
        (helperConfig, minimalAccount) = deployMinimal.deployMinimalAccount();
        usdc = new ERC20Mock();
    }

    /*//////////////////////////////////////////////////////////////
                                EXECUTE
    //////////////////////////////////////////////////////////////*/
    function test_ownerCanExecuteCommands() public {
        // Arrange
        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address dest = address(usdc);
        uint256 value;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);

        // Act
        vm.prank(minimalAccount.owner());
        minimalAccount.execute(dest, value, functionData);

        // Assert
        assertEq(usdc.balanceOf(address(minimalAccount)), AMOUNT);
    }

    function test_nonOwnerCannotExecuteCommands(address _randomUser) public {
        // Arrange
        vm.assume(_randomUser != minimalAccount.owner());

        assertEq(usdc.balanceOf(address(minimalAccount)), 0);
        address dest = address(usdc);
        uint256 value;
        bytes memory functionData = abi.encodeWithSelector(ERC20Mock.mint.selector, address(minimalAccount), AMOUNT);

        // Act
        vm.prank(_randomUser);
        vm.expectRevert(MinimalAccount.MinimalAccount__OnlyEntryPointOrOwner.selector); // Assert
        minimalAccount.execute(dest, value, functionData);
    }
}

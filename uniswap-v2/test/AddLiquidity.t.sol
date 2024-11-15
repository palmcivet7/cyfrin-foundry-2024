// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {IUniswapV2Factory} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {ERC20} from "../src/ERC20.sol";
import {IWETH} from "../src/interfaces/IWETH.sol";
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {
    DAI, WETH, MKR, UNISWAP_V2_ROUTER_02, UNISWAP_V2_FACTORY, UNISWAP_V2_PAIR_DAI_WETH
} from "../../src/Constants.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract UniswapV2LiquidityTest is Test {
    IWETH private constant weth = IWETH(WETH);
    IERC20 private constant dai = IERC20(DAI);

    IUniswapV2Router02 private constant router = IUniswapV2Router02(UNISWAP_V2_ROUTER_02);
    IUniswapV2Pair private constant pair = IUniswapV2Pair(UNISWAP_V2_PAIR_DAI_WETH);

    address private constant user = address(100);

    function setUp() public {
        // Fund WETH to user
        deal(user, 100 * 1e18);
        vm.startPrank(user);
        weth.deposit{value: 100 * 1e18}();
        weth.approve(address(router), type(uint256).max);
        vm.stopPrank();

        // Fund DAI to user
        deal(DAI, user, 1000000 * 1e18);
        vm.startPrank(user);
        dai.approve(address(router), type(uint256).max);
        vm.stopPrank();
    }

    function test_addLiquidity() public {
        // Exercise - Add liquidity to DAI / WETH pool
        // Write your code here
        // Don’t change any other code
        uint256 amountADesired = 100 * 1e18;
        uint256 amountBDesired = 1000000 * 1e18;
        uint256 amountAMin = 1;
        uint256 amountBMin = 1;
        vm.prank(user);
        (uint256 amountA, uint256 amountB, uint256 liquidity) = router.addLiquidity(
            DAI, WETH, amountADesired, amountBDesired, amountAMin, amountBMin, user, block.timestamp
        );

        assertGt(pair.balanceOf(user), 0, "LP = 0");
    }

    function test_removeLiquidity() public {
        vm.startPrank(user);
        (,, uint256 liquidity) = router.addLiquidity({
            tokenA: DAI,
            tokenB: WETH,
            amountADesired: 1000000 * 1e18,
            amountBDesired: 100 * 1e18,
            amountAMin: 1,
            amountBMin: 1,
            to: user,
            deadline: block.timestamp
        });
        pair.approve(address(router), liquidity);

        // Exercise - Remove liquidity from DAI / WETH pool
        // Write your code here
        // Don’t change any other code

        vm.stopPrank();

        assertEq(pair.balanceOf(user), 0, "LP = 0");
    }
}

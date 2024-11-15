// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {IUniswapV2Factory} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import {ERC20} from "../src/ERC20.sol";
import {IWETH} from "../src/interfaces/IWETH.sol";
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {DAI, WETH, MKR, UNISWAP_V2_ROUTER_02, UNISWAP_V2_FACTORY} from "../../src/Constants.sol";

contract UniswapV2FactoryTest is Test {
    IWETH private constant weth = IWETH(WETH);
    IUniswapV2Factory private constant factory = IUniswapV2Factory(UNISWAP_V2_FACTORY);

    function test_createPair() public {
        ERC20 token = new ERC20("test", "TEST", 18);

        // Exercise - deploy token + WETH pair contract
        // Write your code here
        // Don’t change any other code
        address pair = factory.createPair(address(weth), address(token));

        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();

        if (address(token) < WETH) {
            assertEq(token0, address(token), "token 0");
            assertEq(token1, WETH, "token 1");
        } else {
            assertEq(token0, WETH, "token 0");
            assertEq(token1, address(token), "token 1");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DeployDSC} from "script/DeployDSC.s.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";
import {DSCEngine} from "src/DSCEngine.sol";
import {DecentralizedStableCoin} from "src/DecentralizedStableCoin.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Handler} from "test/fuzz/Handler.t.sol";

contract InvariantsTest is StdInvariant, Test {
    DeployDSC public deployer;
    DSCEngine public dsce;
    DecentralizedStableCoin public dsc;
    HelperConfig public helperConfig;
    Handler public handler;

    address public weth;
    address public wbtc;

    function setUp() public {
        deployer = new DeployDSC();
        (dsc, dsce, helperConfig) = deployer.run();
        (,, weth, wbtc,) = helperConfig.activeNetworkConfig();
        handler = new Handler(dsce, dsc);
        targetContract(address(handler));
    }

    function invariant_protocalMustHaveMoreValueThanTotalSupply() public view {
        uint256 totalSupply = dsc.totalSupply();
        uint256 totalWethDeposited = IERC20(weth).balanceOf(address(dsce));
        uint256 totalWbtcDeposited = IERC20(wbtc).balanceOf(address(dsce));

        uint256 wethValue = dsce.getUsdValue(weth, totalWethDeposited);
        uint256 wbtcValue = dsce.getUsdValue(wbtc, totalWbtcDeposited);

        console.log("WETH Value in USD:", wethValue);
        console.log("WBTC Value in USD:", wbtcValue);
        console.log("Total Supply of DSC:", totalSupply);

        assert(wethValue + wbtcValue >= totalSupply);
    }
}

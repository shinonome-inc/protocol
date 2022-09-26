pragma solidity ^0.6;

pragma experimental ABIEncoderV2;

import "./utils/ForkUtils.sol";
import "./utils/TestUtils.sol";
import "src/IZeroEx.sol";
import "@0x/contracts-erc20/contracts/src/v06/IEtherTokenV06.sol";
import "samplers/ERC20BridgeSampler.sol";
import "samplers/TwoHopSampler.sol";
import "forge-std/StdJson.sol";

contract erc20BridgeSamplerTests is Test, ForkUtils, TestUtils, ERC20BridgeSampler {
    function setUp() public {

    }   

    function testERC20BridgeSampler() public {
        log_string("testERC20BridgeSampler");
    }
}
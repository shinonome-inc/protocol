// SPDX-License-Identifier: Apache-2.0
/*

  Copyright 2022 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.6.5;

pragma experimental ABIEncoderV2;

import "./AbstractBridgeAdapter.sol";
import "./BridgeProtocols.sol";
import "./mixins/MixinBalancerV2.sol";
import "./mixins/MixinBalancerV2Batch.sol";
import "./mixins/MixinCurve.sol";
import "./mixins/MixinCurveV2.sol";
import "./mixins/MixinDodoV2.sol";
import "./mixins/MixinDodo.sol";
import "./mixins/MixinKyberDmm.sol";
import "./mixins/MixinNerve.sol";
import "./mixins/MixinGMX.sol";
import "./mixins/MixinUniswapV3.sol";
import "./mixins/MixinUniswapV2.sol";
import "./mixins/MixinZeroExBridge.sol";

contract ArbitrumBridgeAdapter is
    AbstractBridgeAdapter(42161, "Arbitrum"),
    MixinBalancerV2,
    MixinBalancerV2Batch,
    MixinCurve,
    MixinCurveV2,
    MixinDodoV2,
    MixinNerve,
    MixinKyberDmm,
    MixinGMX,
    MixinUniswapV3,
    MixinUniswapV2,
    MixinZeroExBridge
{
    constructor(IEtherTokenV06 weth) public MixinCurve(weth) {}

    function _trade(
        BridgeOrder memory order,
        IERC20TokenV06 sellToken,
        IERC20TokenV06 buyToken,
        uint256 sellAmount,
        bool dryRun
    ) internal override returns (uint256 boughtAmount, bool supportedSource) {
        uint128 protocolId = uint128(uint256(order.source) >> 128);
        if (protocolId == BridgeProtocols.BALANCERV2) {
            if (dryRun) return (0, true);
            boughtAmount = _tradeBalancerV2(sellToken, buyToken, sellAmount, order.bridgeData);
        } else if (protocolId == BridgeProtocols.BALANCERV2BATCH) {
            if (dryRun) return (0, true);
            boughtAmount = _tradeBalancerV2Batch(sellAmount, order.bridgeData);
        } else if (protocolId == BridgeProtocols.CURVE) {
            if (dryRun) return (0, true);
            boughtAmount = _tradeCurve(sellToken, buyToken, sellAmount, order.bridgeData);
        } else if (protocolId == BridgeProtocols.CURVEV2) {
            if (dryRun) return (0, true);
            boughtAmount = _tradeCurveV2(sellToken, buyToken, sellAmount, order.bridgeData);
        } else if (protocolId == BridgeProtocols.DODOV2) {
            if (dryRun) return (0, true);
            boughtAmount = _tradeDodoV2(sellToken, sellAmount, order.bridgeData);
        } else if (protocolId == BridgeProtocols.GMX) {
            if (dryRun) return (0, true);
            boughtAmount = _tradeGMX(buyToken, sellAmount, order.bridgeData);
        } else if (protocolId == BridgeProtocols.KYBERDMM) {
            if (dryRun) return (0, true);
            boughtAmount = _tradeKyberDmm(buyToken, sellAmount, order.bridgeData);
        } else if (protocolId == BridgeProtocols.NERVE) {
            if (dryRun) return (0, true);
            boughtAmount = _tradeNerve(sellToken, sellAmount, order.bridgeData);
        } else if (protocolId == BridgeProtocols.UNISWAPV3) {
            if (dryRun) return (0, true);
            boughtAmount = _tradeUniswapV3(sellToken, sellAmount, order.bridgeData);
        } else if (protocolId == BridgeProtocols.UNISWAPV2) {
            if (dryRun) return (0, true);
            boughtAmount = _tradeUniswapV2(buyToken, sellAmount, order.bridgeData);
        } else if (protocolId == BridgeProtocols.UNKNOWN) {
            if (dryRun) return (0, true);
            boughtAmount = _tradeZeroExBridge(sellToken, buyToken, sellAmount, order.bridgeData);
        }

        emit BridgeFill(order.source, sellToken, buyToken, sellAmount, boughtAmount);
    }
}

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

pragma solidity ^0.6;
pragma experimental ABIEncoderV2;


import "./utils/TestUtils.sol";
import "./OtcBridgeSettlement.sol";

contract OtcBridgeOrderTests is
    ForkUtils,
    TestUtils
{

    using stdJson for string;

    uint256[] forks;

    //utility mapping to get chainId by name
    mapping(string => string) public chainsByChainId;
    //utility mapping to get indexingChainId by Chain
    mapping(string => string) public indexChainsByChain;

    
    

    function setUp() public {
        createForks();

        for (uint256 i = 0; i < chains.length; i++) {
            chainsByChainId[chains[i]] = chainIds[i];
            indexChainsByChain[chains[i]] = indexChainIds[i];
        }
    }

    function testOtcBridgeOrder() public{
        log_string("OtcBridgeOrderTests");
        for (uint256 i = 0; i < chains.length; i++) {
            if(i == 4) {
                continue;
            }
            vm.selectFork(this.forkIds(chains[i]));
            log_named_string("  Selecting Fork On", chains[i]);
            //pass execution to another contract to avoid stack too deep
            OtcBridgeSettlement otcOrders = new OtcBridgeSettlement();

            otcOrders._fillOtcOrder(chains[i], indexChainsByChain[chains[i]], getTokens(i), getContractAddresses(i), getLiquiditySourceAddresses(i));
        }
    }

    // function _fillOtcOrder(string memory chainName, string memory chainId, TokenAddresses memory tokens, Addresses memory contracts) public onlyForked() {
    //     log_named_address("WETH/NATIVE_ASSET", address(tokens.WrappedNativeToken));
    //     log_named_address("EP", address(contracts.exchangeProxy));
    //     address temp = address(
    //         new FillQuoteTransformer(
    //                 FillQuoteTransformer(contracts.transformers.fillQuoteTransformer).bridgeAdapter(),
    //                 IZeroEx(payable(contracts.exchangeProxy)
    //             )
    //         )
    //     );
        
    // }
}
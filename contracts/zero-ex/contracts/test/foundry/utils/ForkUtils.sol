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

import "forge-std/Test.sol";
import "src/features/TransformERC20Feature.sol";
import "src/external/TransformerDeployer.sol";
import "src/transformers/WethTransformer.sol";
import "src/transformers/FillQuoteTransformer.sol";
import "@0x/contracts-erc20/contracts/src/v06/IEtherTokenV06.sol";
import "@0x/contracts-erc20/contracts/src/v06/IERC20TokenV06.sol";
import "src/IZeroEx.sol";

//contract-addresses/addresses.json interfaces
//need to be alphebetized in solidity but not in addresses.json
struct Addresses {
    address erc20BridgeProxy;
    address erc20BridgeSampler;
    address etherToken;
    address payable exchangeProxy;
    address exchangeProxyFlashWallet;
    address exchangeProxyGovernor;
    address exchangeProxyLiquidityProviderSandbox;
    address exchangeProxyTransformerDeployer;
    address staking;
    address stakingProxy;
    TransformerAddresses transformers;
    address zeroExGovernor;
    address zrxToken;
    address zrxTreasury;
    address zrxVault;
}

struct TransformerAddresses {
    address affiliateFeeTransformer;
    address fillQuoteTransformer;
    address payTakerTransformer;
    address positiveSlippageFeeTransformer;
    address wethTransformer;
}

struct TokenAddresses {
  IERC20TokenV06 DAI;
  IERC20TokenV06 USDC;
  IERC20TokenV06 USDT;
  IEtherTokenV06 WrappedNativeToken;
}

struct LiquiditySources {
  address UniswapV2Router;
}
interface IFQT{
  function bridgeAdapter() external returns (address);
}

contract ForkUtils is Test {
  
    using stdJson for string;
    //forked providers for each chain
    mapping(string => uint256) public forkIds;

    TokenAddresses tokens;
    Addresses addresses;
    LiquiditySources sources;

    uint256 forkBlock = 15_000_000;

    string[] chains = ["mainnet", "bsc", "polygon", "avalanche", "fantom", "optimism", "arbitrum"];
    string[] indexChainIds = [".1", ".56", ".137", ".43114", ".250", ".10", ".42161"];
    string[] chainIds = ["1", "56", "137", "43114", "250", "10", "42161"];
    uint256[] chainId = [1, 56, 137, 43114, 250, 10, 42161];

    //special fork block number for fantom since it produces blocks faster and more frequently
    uint256[] blockNumber = [forkBlock, forkBlock, 33447149, forkBlock, 32000000, forkBlock, forkBlock];
    /// Only run this function if the block number
    // is greater than some constant for Ethereum Mainnet

    string addressesJson;
    string tokensJson;
    string sourcesJson;

    function createForks() public returns (uint256[] memory) {
      for (uint256 i = 0; i < chains.length; i++) {
          forkIds[chains[i]] = vm.createFork(vm.rpcUrl(chains[i]), blockNumber[i]);
      }
    }

    function readLiquiditySourceAddresses() public returns (string memory) {
      string memory root = vm.projectRoot();
      string memory path = string(abi.encodePacked(root, "/", "contracts/test/foundry/addresses/sourceAddresses.json"));
      sourcesJson = vm.readFile(path);
      return vm.readFile(path);
    }

    function getLiquiditySourceAddresses(uint index) public returns (LiquiditySources memory sources ) {
      readLiquiditySourceAddresses();
      bytes memory liquiditySources = sourcesJson.parseRaw(indexChainIds[index]);
      return abi.decode(liquiditySources, (LiquiditySources));
    }

    function readAddresses() public returns (string memory){
        string memory root = vm.projectRoot();
        string memory path = string(abi.encodePacked(root, "/", "contracts/test/foundry/addresses/addresses.json"));
        addressesJson = vm.readFile(path);
        return vm.readFile(path);
    }
    function getContractAddresses(uint index) public returns (Addresses memory addresses){
      readAddresses();
      bytes memory contractAddresses = addressesJson.parseRaw(indexChainIds[index]);
      return abi.decode(contractAddresses, (Addresses));
      //log_named_address("WETH/NATIVE_ASSET", address(tokens.WrappedNativeToken));
  }

    function readTokens() public returns (string memory){
      string memory root = vm.projectRoot();
      string memory path = string(abi.encodePacked(root, "/", "contracts/test/foundry/addresses/tokenAddresses.json"));
      tokensJson = vm.readFile(path);
      return vm.readFile(path);
  }

  function getTokens(uint index) public returns (TokenAddresses memory addresses){
      readTokens();
      bytes memory chainTokens = tokensJson.parseRaw(indexChainIds[index]);
      return abi.decode(chainTokens, (TokenAddresses));
      //log_named_address("WETH/NATIVE_ASSET", address(tokens.WrappedNativeToken));
  }

    
    // function label(Addresses memory addresses) public {

    //     vm.label(address(addresses.exchangeProxy), "ZeroEx: ExchangeProxy");
    //     vm.label(address(addresses.transformers.wethTransformer), "WethTransformer");
    //     vm.label(address(IFQT(addresses.transformers.fillQuoteTransformer).bridgeAdapter()), "Bridge Adapter");
    //     //vm.label(address(addresses.transformers.fillQuoteTransformer), "FillQuoteTransformer");
    //     // /log_named_address("Bridge Adapter", address(FillQuoteTransformer(addresses.transformers.fillQuoteTransformer).bridgeAdapter()));
    //     //vm.label(address(), "BridgeAdapter");
    //     //vm.label(address(IZeroEx(addresses.exchangeProxy).getTransformWallet()), "FlashWallet");
    //   }
    

    modifier onlyForked() {
        if (block.number >= 15000000) {
            _;
        } else {
            emit log_string("Requires fork mode, skipping");
        }
    }
}

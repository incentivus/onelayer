pragma solidity ^0.8.0;
// import 'https://github.com/Uniswap/uniswap-lib/blob/master/contracts/libraries/TransferHelper.sol';

// import "https://github.com/pancakeswap/pancake-swap-periphery/blob/master/contracts/interfaces/IPancakeRouter02.sol";
import "https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/interfaces/IUniswapV2Router02.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
// import "./github/pancakeswap/pancake-swap-periphery/contract/PancakeRouter.sol";

contract PancakeWrapper {
    address internal constant PANCAKESWAP_ROUTER_ADDRESS = 0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F;//0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F ;
    address internal constant BAKERYSWAP_ROUTER_ADDRESS = 0xCDe540d7eAFE93aC5fE6233Bee57E1270D3E330F;//0xCDe540d7eAFE93aC5fE6233Bee57E1270D3E330F ;

    address public owner;
    
    IUniswapV2Router02 public pancakeswapRouter;
    IUniswapV2Router02 public bakeryswapRouter;
    //   address private multiDaiKovan = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;
    
    constructor(){
        pancakeswapRouter = IUniswapV2Router02(PANCAKESWAP_ROUTER_ADDRESS);
        bakeryswapRouter = IUniswapV2Router02(BAKERYSWAP_ROUTER_ADDRESS);

        owner = msg.sender;
    }
    
    modifier onlyOwner(){
      require(msg.sender == owner);
      _;
    }
    
    event log1(string, uint);
    event log2(string, address[]);
    event log3(string, address);
    // function approve(address _token, uint index) public onlyOwner{
    //     IERC20 token = IERC20(_token);
    //     IUniswapV2Router02 router = getProto(index);
    //     require(token.approve(address(router), 1000000000000000000000000000000), 'approve failed.');
    // }
    //   function convertEthToDai(uint amountOut, uint maxAmountIn, address[] calldata paths, address to, uint deadline) public onlyOwner {
    //     // uint deadline = 16652384361665238436; // using 'now' for convenience, for mainnet pass deadline from frontend!
    //     // pancakeswapRouter.swapETHForExactTokens{ value: msg.value }(daiAmount, getPathForETHtoDAI(), address(this), deadline);
    //     IERC20 first = IERC20(paths[0]);
    //     require(first.transferFrom(msg.sender, address(this), maxAmountIn), 'transferFrom failed.');
    //     require(first.approve(address(pancakeswapRouter), maxAmountIn*2), 'approve failed.');
    //     emit log1("amount out: ", amountOut);
    //     emit log1("amount in: ", maxAmountIn);
    //     emit log2("path: ", paths);
    //     emit log3("address: ", to);
    //     // address[] path = new address[](2);
    //     // pancakeswapRouter.swapTokensForExactTokens(amountOut, maxAmountIn, paths, to, deadline);
    //     pancakeswapRouter.swapTokensForExactTokens(amountOut, maxAmountIn, paths, to, deadline);
    //     // require(first.transfer(msg.sender, first.balanceOf(address(this))));
    //     // refund leftover ETH to user
    //     // (bool success,) = msg.sender.call{ value: address(this).balance }("");
    //     // require(success, "refund failed");
    //   }
    // function swap(uint[] memory protocol, bool[] memory indicator, uint[] memory amounts, 
    // uint[] memory threshold, address[][] calldata paths, address to) public onlyOwner {
    //     uint deadline = block.timestamp + 15; // using 'now' for convenience, for mainnet pass deadline from frontend!
    //     IUniswapV2Router02 router;
    //     // pancakeswapRouter.swapETHForExactTokens{ value: msg.value }(daiAmount, getPathForETHtoDAI(), address(this), deadline);
    //     for (uint i = 0; i < paths.length; i++) {
    //         router = getProto(protocol[i]);
    //         if (indicator[i]) // TokensForExactTokens (Buy)
    //         {
    //             router.swapTokensForExactTokens(amounts[i], threshold[i], paths[i], to, deadline);
    //         }
    //         else //ExactTokensForTokens (Sell)
    //         {
    //             router.swapExactTokensForTokens(amounts[i], threshold[i], paths[i], to, deadline);
    //         }
    //         emit log1("amount: ", amounts[i]);
    //         emit log1("threshold: ", threshold[i]);
    //         emit log2("path: ", paths[i]);
    //         emit log3("address: ", to);
    //     }
    //     // IERC20 first = IERC20(paths[0]);
    //     // require(first.transferFrom(msg.sender, address(this), maxAmountIn), 'transferFrom failed.');
    //     // emit log1("amount out: ", amountOut);
    //     // emit log1("amount in: ", maxAmountIn);
    //     // emit log2("path: ", paths);
    //     // emit log3("address: ", to);
    //     // address[] path = new address[](2);
    //     // pancakeswapRouter.swapTokensForExactTokens(amountOut, maxAmountIn, paths, to, deadline);
    //     // pancakeswapRouter.swapTokensForExactTokens(amountOut, maxAmountIn, paths, to, deadline);
    //     // require(first.transfer(msg.sender, first.balanceOf(address(this))));
    //     // refund leftover ETH to user
    //     // (bool success,) = msg.sender.call{ value: address(this).balance }("");
    //     // require(success, "refund failed");
    // }
    
    // function refund(address _token, address to) onlyOwner public{
    //   IERC20 token = IERC20(_token);
    //   require(token.transfer(to, token.balanceOf(address(this))));
    // }
    
    function getProto(uint index) internal view returns(IUniswapV2Router02){
        
        if (index == 0) // pancakeswap
        {
            return pancakeswapRouter;
        }
        else if (index == 1) //bakerySwap
        {
            return bakeryswapRouter;
        }
        else{
            revert("Protocol not valid.");
        }
    }
    
    // function convertTest(uint[2][] memory amounts, address[][] calldata paths, address to) public {
    //     uint deadline = block.timestamp + 150; // using 'now' for convenience, for mainnet pass deadline from frontend!
    //     // pancakeswapRouter.swapETHForExactTokens{ value: msg.value }(daiAmount, getPathForETHtoDAI(), address(this), deadline);
    //     emit log1("amount out: ", amounts[0][0]);
    //     emit log1("amount in: ", amounts[0][1]);
    //     emit log2("path: ", paths[0]);
    //     emit log3("address: ", to);
    //     emit log1("deadline: ", deadline);
    //     // pancakeswapRouter.swapTokensForExactTokens(amounts[0][0], amounts[0][1], paths[0], address(msg.sender), deadline);
    //     // refund leftover ETH to user
    //     // (bool success,) = msg.sender.call{ value: address(this).balance }("");
    //     // require(success, "refund failed");
    // }
    
    function getRatio(uint[] memory proto, bool[] memory ind, uint[] memory amount, address[][] memory paths) public view returns (uint[] memory) {
        //   address[] memory path = new address[](2);
        //   path
        uint[] memory res = new uint[](paths.length);
        for (uint i = 0; i < paths.length; i++) {
            IUniswapV2Router02 router = getProto(proto[i]);
            if (ind[i]){
                res[i] = router.getAmountsIn(amount[i]*10000000000000, paths[i])[0]/10000000000000;
            }
            else{
                res[i] = router.getAmountsOut(amount[i]*10000000000000, paths[i])[1]/10000000000000;
            }
        }
        
        return res;
    }

    
    // function getRatio(bool ind, uint amount, address[] memory path) public view returns (uint) {
    //     //   address[] memory path = new address[](2);
    //     //   path
    //     if (ind){
    //         return pancakeswapRouter.getAmountsIn(amount*10000000000000, path)[0]/10000000000000;
    //     }
    //     else{
    //         return pancakeswapRouter.getAmountsOut(amount*10000000000000, path)[1]/10000000000000;
    //     }
    // }
    
    //   function getPathForETHtoDAI(address ad1, address ad2) private view returns (address[] memory) {
    //     address[] memory path = new address[](2);
    //     path[0] = uniswapRouter.WETH();
    //     path[1] = multiDaiKovan;
    
    //     return path;
    //   }
    
    // important to receive ETH
    receive() payable external {}
}




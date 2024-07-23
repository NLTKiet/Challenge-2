pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable{
  // event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
event SellTokens(address seller, uint256 amountOfETH, uint256 amountOfTokens);

  YourToken public yourToken;
   
    uint256 public constant tokensPerEth = 100;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
    }

 // ToDo: create a payable buyTokens() function:
   function buyTokens() public payable {
      require(msg.value > 0, "Necesitas enviar algo de ether");
      uint256 amount = msg.value;
      
      uint256 tokens = amount * tokensPerEth;
      
      uint256 tokenBalance = yourToken.balanceOf(address(this));
      require (tokenBalance >= tokens, "No hay suficientes tokens en reserva");
    
      (bool sent) =yourToken.transfer(msg.sender, tokens);
      require(sent, "Transferencia fallida"); 

      emit BuyTokens(msg.sender, amount, tokens);
        
       // yourToken.transfer(msg.sender, msg.value * tokensPerEth);
       // emit BuyTokens(msg.sender, msg.value, msg.value * tokensPerEth);
    }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
    function withdraw() public onlyOwner{
        uint256 balance = address(this).balance;
        require(balance > 0, "Sin balance para retiro");
        payable(owner()).transfer(balance);
    }
  // ToDo: create a sellTokens(uint256 _amount) function:
    function sellTokens(uint256 _amount) public {
        uint256 tokenBalance = yourToken.balanceOf(address(this));
        require(tokenBalance >= _amount, "Sin tokens sufiecientes en la reserva");

        uint256 amount = _amount / tokensPerEth;
        require(address(this).balance >= amount, "Sin suficiente Ether en la reserva");

        (bool sent) = yourToken.transferFrom(msg.sender, address(this), _amount);
        require(sent, "Transferencia fallida");

        (bool sent2) = payable(msg.sender).send(amount);
        require(sent2, "Fallo a enviar ETH");
        emit SellTokens(msg.sender, _amount, amount);

   }
}

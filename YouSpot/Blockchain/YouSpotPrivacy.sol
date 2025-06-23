// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IVerifier {
    function verifyProof(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[1] memory input
    ) external view returns (bool);
}

contract YouSpotPrivacy is Ownable {
    IERC20 public youSpotToken;
    IVerifier public verifier;

    event PrivatePaymentProcessed(address indexed sender, uint256 amount);

    constructor(address _youSpotToken, address _verifier) {
        youSpotToken = IERC20(_youSpotToken);
        verifier = IVerifier(_verifier);
    }

    function privatePayment(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[1] memory input,
        address recipient,
        uint256 amount
    ) public {
        require(verifier.verifyProof(a, b, c, input), "Invalid proof");

        require(youSpotToken.transferFrom(msg.sender, recipient, amount), "Transfer failed");

        emit PrivatePaymentProcessed(msg.sender, amount);
    }
}

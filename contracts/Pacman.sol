// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

import './interfaces/IGameToken.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

/** @title Pacman
 *  @notice It is a contract for a pacman using GAME token
 */
contract Pacman is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    address public coinboxAddress;

    uint256 public pricePerRoundInGame = 1 ether;

    uint256 public coinboxFee = 20;
    uint256 public rewardFee = 50;

    uint256 public maxScore = 0;

    IGameToken public gameToken;

    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    event NewHighScore(address indexed claimer, uint256 amount, uint256 score);
    event NewCoinBoxAddress(address _coinboxAddress);
    event NewCoinBoxFeeAndRewardFee(uint256 _coinboxFee, uint256 _rewardFee);
    event EnterGame(address indexed user);

    /**
     * @notice Constructor
     * @dev GameToken must be deployed prior to this contract
     * @param _gameTokenAddress: address of the GAME token
     * @param _coinboxAddress: address of a coinbox
     * @param _coinboxFee: fee that goes into a coinbox
     * @param _rewardFee: fee of the rewards when make a new high score
     */
    constructor(address _gameTokenAddress, address _coinboxAddress, uint256 _coinboxFee, uint256 _rewardFee) {
        gameToken = IGameToken(_gameTokenAddress);
        coinboxAddress = _coinboxAddress;
        coinboxFee = _coinboxFee;
        rewardFee = _rewardFee;
    }

    /**
     * @notice Set GAME price per round
     * @dev Only callable by owner
     * @param _pricePerRoundInGame: price per round in GAME
     */
    function setPricePerRoundInGame(uint256 _pricePerRoundInGame) 
        external
        onlyOwner
    {
        pricePerRoundInGame = _pricePerRoundInGame;
    }

    /**
     * @notice Set coinbox address
     * @dev Only callable by owner
     * @param _coinboxAddress: address of a coinbox
     */
    function setCoinBoxAddress(address _coinboxAddress)
        external
        onlyOwner
    {
        require(_coinboxAddress != address(0), "Cannot be zero address");

        coinboxAddress = _coinboxAddress;

        emit NewCoinBoxAddress(_coinboxAddress);
    }

    /**
     * @notice Set coinbox fee and reward fee
     * @dev Only callable by owner
     * @param _coinboxFee: fee that goes into a coinbox
     * @param _rewardFee: fee of the rewards when make a new high score
     */
    function setCoinBoxFeeAndRewardFee(uint256 _coinboxFee, uint256 _rewardFee)
        external
        onlyOwner
    {
        require(_coinboxFee > 0, "CoinBox Fee must be > 0");
        require(_coinboxFee < 100, "CoinBox Fee must be < 100");
        require(_rewardFee > 0, "Reward Fee must be > 0");
        require(_rewardFee < 100, "Reward Fee must be < 100");

        coinboxFee = _coinboxFee;
        rewardFee = _rewardFee;

        emit NewCoinBoxFeeAndRewardFee(_coinboxFee, _rewardFee);
    }

    /**
     * @notice Enter Game
     * @dev Callable by users only, not Contract
     */
    function enterGame()
        external
        notContract
    {
        uint256 amountToBurn;
        uint256 amountToCoinBox;

        amountToCoinBox = pricePerRoundInGame * coinboxFee / 100;
        amountToBurn = pricePerRoundInGame - amountToCoinBox;

        // Transfer some GAME tokens to coinbox address
        gameToken.transferFrom(address(msg.sender), coinboxAddress, amountToCoinBox);
        // Burn some GAME tokens 
        gameToken.burn(amountToBurn);

        emit EnterGame(msg.sender);
    }

    /**
     * @notice Check if an address is a contract
     */
    function _isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
}
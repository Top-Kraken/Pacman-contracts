// SPDX-License-Identifier: MIT

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

    uint256 public pricePerRoundInGame = 1 ether;

    uint256 public coinboxFee = 20;
    uint256 public rewardFee = 50;
    uint256 public bonusFee = 75;

    uint256 public maxScore = 0;

    bool public bonusDay = false;

    IGameToken public gameToken;

    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    event NewHighScore(address indexed claimer, uint256 amount, uint256 score);
    event NewCoinBoxFeeAndRewardFeeAndBonusFee(uint256 _coinboxFee, uint256 _rewardFee, uint256 _bonusFee);
    event EnterGame(address indexed user);

    /**
     * @notice Constructor
     * @dev GameToken must be deployed prior to this contract
     * @param _gameTokenAddress: address of the GAME token
     * @param _coinboxFee: fee that goes into a coinbox
     * @param _rewardFee: fee of the rewards when make a new high score
     * @param _bonusFee: fee of the bonus rewards when make a new high score in bonus day
     */
    constructor(address _gameTokenAddress, uint256 _coinboxFee, uint256 _rewardFee, uint256 _bonusFee) {
        gameToken = IGameToken(_gameTokenAddress);
        coinboxFee = _coinboxFee;
        rewardFee = _rewardFee;
        bonusFee = _bonusFee;
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
     * @notice Set coinbox fee and reward fee
     * @dev Only callable by owner
     * @param _coinboxFee: fee that goes into a coinbox
     * @param _rewardFee: fee of the rewards when make a new high score
     * @param _bonusFee: fee of the bonus rewards when make a new high score in bonus day
     */
    function setCoinBoxFeeAndRewardFeeAndBonusFee(uint256 _coinboxFee, uint256 _rewardFee, uint256 _bonusFee)
        external
        onlyOwner
    {
        require(_coinboxFee > 0, "CoinBox Fee must be > 0");
        require(_coinboxFee < 100, "CoinBox Fee must be < 100");
        require(_rewardFee > 0, "Reward Fee must be > 0");
        require(_rewardFee < 100, "Reward Fee must be < 100");
        require(_bonusFee > 0, "Reward Fee must be > 0");
        require(_bonusFee < 100, "Reward Fee must be < 100");

        coinboxFee = _coinboxFee;
        rewardFee = _rewardFee;
        bonusFee = _bonusFee;

        emit NewCoinBoxFeeAndRewardFeeAndBonusFee(_coinboxFee, _rewardFee, _bonusFee);
    }

    /**
     * @notice Enter Game
     * @dev Callable by users only, not Contract
     */
    function enterGame()
        external
        notContract
    {
        require(gameToken.balanceOf(msg.sender) >= pricePerRoundInGame, "Insufficient balance");
        uint256 amountToBurn;
        uint256 amountToCoinBox;

        amountToCoinBox = pricePerRoundInGame * coinboxFee / 100;
        amountToBurn = pricePerRoundInGame - amountToCoinBox;

        // Burn some GAME tokens 
        gameToken.burn(address(msg.sender), amountToBurn);
        // Transfer some GAME tokens to coinbox address
        gameToken.transferFrom(address(msg.sender), address(this), amountToCoinBox);

        emit EnterGame(msg.sender);
    }

    /**
     * @notice Claim High Score
     * @dev Callable by users only, not Contract
     * @param _maxScore: Max score of the user
     */
    function claimHighScore(uint256 _maxScore)
        external
        notContract
    {
        require(_maxScore > maxScore, "Not max score");

        // Update max score
        maxScore = _maxScore;

        // Calculate reward amount from coinbox
        uint256 amountToReward;
        
        if ( bonusDay ) {
            amountToReward = gameToken.balanceOf(address(this)) * bonusFee / 100;
        } else {
            amountToReward = gameToken.balanceOf(address(this)) * rewardFee / 100;
        }

        // Transfer reward amount to the user
        gameToken.transfer(address(msg.sender), amountToReward);

        emit NewHighScore(msg.sender, amountToReward, _maxScore);
    }

    /**
     * @notice Set bonus day
     */
    function setBonusDay(bool _bonusDay) 
        external
        onlyOwner
    {
        bonusDay = _bonusDay;
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
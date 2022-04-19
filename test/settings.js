const { ethers } = require("ethers");

const pacman = {
    totalSupply: ethers.utils.parseUnits("10000000", 18),
    coinboxFee: 20,
    rewardFee: 50,
    pricePerRoundInGame: ethers.utils.parseUnits("1", "18"),
    invalidPricePerRoundInGame: ethers.utils.parseUnits("5", "17"),
    rewardInGame: ethers.utils.parseUnits("1", "17"),
    highScore: 100,

    invalid_balance: 'Insufficient balance',
}

module.exports = pacman;
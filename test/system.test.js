const { expect, assert } = require("chai");
const { network, ethers } = require("hardhat");
const pacman = require("../test/settings.js");

describe("Pacman contract", function() {
    // Creating the instance and contract info for the pacman contract
    let pacmanInstance, pacmanContract;
    // Creating the instance and contract info for the game token
    let gameInstance, gameContract;

    // Creating the users
    let owner, coinbox, user;

    beforeEach(async() => {
        // Getting the signers provided by ethers
        const signers = await ethers.getSigners();
        // Creating the active wallets for use
        owner = signers[0];
        coinbox = signers[1];
        user = signers[2];

        // Getting the pacman code (abi, bytecode, name)
        pacmanContract = await ethers.getContractFactory("Pacman");
        // Getting the game token code (abi, bytecode, name)
        gameContract = await ethers.getContractFactory("Mock_erc20");

        // Deploying the instances
        gameInstance = await gameContract.deploy(
            pacman.totalSupply,
        );
        pacmanInstance = await pacmanContract.deploy(
            gameInstance.address, 
            coinbox.address, 
            pacman.coinboxFee, 
            pacman.rewardFee
        );
        await pacmanInstance.setPricePerRoundInGame(
            pacman.pricePerRoundInGame
        );
    });

    describe("Enter game tests", function() {
        /**
         * Users enter game for the test.
         */
        beforeEach( async() => {

        })

        /**
         * Tests enter game
         */
        it("User enter games", async function() {
            // Sending the user the needed amount of game
            await gameInstance.transfer(
                user.address,
                pacman.pricePerRoundInGame
            );
            // Approve pacman to spend cost
            await gameInstance.connect(user).approve(
                pacmanInstance.address,
                pacman.pricePerRoundInGame
            );
            let userGameBalanceBefore = await gameInstance.balanceOf(user.address);
            // Enter game
            await pacmanInstance.connect(user).enterGame();
            let userGameBalanceAfter = await gameInstance.balanceOf(user.address);

            // Tests
            assert.equal(
                userGameBalanceBefore.toString(),
                pacman.pricePerRoundInGame,
                "User hasn't valid balance"
            );
            assert.equal(
                userGameBalanceAfter.toString(),
                0,
                "Enter game fails."
            );
        })

        /**
         * Invalid balance for enter games
         */
        it("Invalid balance for enter games", async function() {
            // Sending the user the needed amount of game
            await gameInstance.transfer(
                user.address,
                pacman.invalidPricePerRoundInGame
            );
            // Approve pacman to spend cost
            await gameInstance.connect(user).approve(
                pacmanInstance.address,
                pacman.invalidPricePerRoundInGame
            );
            // Enter game
            await expect(pacmanInstance.connect(user).enterGame(
                )
            ).to.be.revertedWith(pacman.invalid_balance);
        })
    })

    describe("Claim High Score tests", function() {
        /**
         * Users enter game for the test.
         */
        beforeEach( async() => {
            // Sending the user the needed amount of game
            await gameInstance.transfer(
                user.address,
                pacman.pricePerRoundInGame
            );
            // Approve pacman to spend cost
            await gameInstance.connect(user).approve(
                pacmanInstance.address,
                pacman.pricePerRoundInGame
            );
            // Enter game
            await pacmanInstance.connect(user).enterGame();
        })

        /**
         * Claim High Score
         */
        it("Claim High Score", async function() {
            let userGameBalanceBefore = await gameInstance.balanceOf(user.address);
            // Approve pacman to spend cost
            await gameInstance.connect(coinbox).approve(
                pacmanInstance.address,
                pacman.rewardInGame
            );
            // Claim High Score
            await pacmanInstance.connect(user).claimHighScore(
                pacman.highScore
            );
            let userGameBalanceAfter = await gameInstance.balanceOf(user.address);

            // Tests
            assert.equal(
                userGameBalanceBefore.toString(),
                0,
                "Buyer has game balance before claiming"
            );
            assert.equal(
                userGameBalanceAfter.toString(),
                pacman.rewardInGame,
                "User claim incorrect amount"
            );
        })

        /**
         * Invalid balance for enter games
         */
        it("Invalid balance for enter games", async function() {
            // Sending the user the needed amount of game
            await gameInstance.transfer(
                user.address,
                pacman.invalidPricePerRoundInGame
            );
            // Approve pacman to spend cost
            await gameInstance.connect(user).approve(
                pacmanInstance.address,
                pacman.invalidPricePerRoundInGame
            );
            // Enter game
            await expect(pacmanInstance.connect(user).enterGame(
                )
            ).to.be.revertedWith(pacman.invalid_balance);
        })
    })
})
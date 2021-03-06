// The deployment script
const pacman = require("../test/settings.js");

const main = async() => {
    // Getting the first signer as the deployer
    const signers = await ethers.getSigners();
    const deployer = signers[0];

    // Saving the info to be logged in the table (deployer address)
    var deployerLog = { Label: "Deploying Address", Info: deployer.address };

    // Saving the info to be logged in the table (deployer address)
    var deployerBalanceLog = {
        Label: "Deployer ETH Balance",
        Info: (await deployer.getBalance()).toString()
    };

    // Getting the pacman code (abi, bytecode, name)
    let pacmanContract = await ethers.getContractFactory("Pacman");
    let gameContract = await ethers.getContractFactory("Mock_erc20");

    // Deploys the contracts
    let gameInstance = await gameContract.deploy(pacman.totalSupply);
    let pacmanInstance = await pacmanContract.deploy(gameInstance.address, pacman.coinboxFee, pacman.rewardFee, pacman.bonusFee);

    // Saving the info to be logged in the table (game token, pacman address)
    var gameLog = { Label: "Deployed Game Token Address", Info: gameInstance.address };
    var pacmanLog = { Label: "Deployed Pacman Address", Info: pacmanInstance.address };

    console.table([
        deployerLog,
        deployerBalanceLog,
        gameLog,
        pacmanLog
    ]);
}

// Runs the deployment script, catching any errors
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
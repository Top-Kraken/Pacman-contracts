// The deployment script

const { ethers } = require("hardhat");

const main = async() => {
    // Getting the first signer as the deployer
    const [deployer] = await ethers.getSigners();
    // Saving the info to be logged in the table (deployer address)
    var deployerLog = { Label: "Deploying Address", Info: deployer.address };
    // Saving the info to be logged in the table (deployer address)
    var deployerBalanceLog = {
        Label: "Deployer ETH Balance",
        Info: (await deployer.getBalance()).toString()
    };

    // Getting the pacman code (abi, bytecode, name)
    let pacmanContract = await ethers.getContractFactory("Pacman");

    // Deploys the contracts
    let pacmanInstance = await pacmanContract.deploy();

    // Saving the info to be logged in the table (deployer address)
    var pacmanLog = { Label: "Deployed Pacman Address", Info: pacmanInstance.address };

    console.table([
        deployerLog,
        deployerBalanceLog,
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
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @dev THIS CONTRACT IS FOR TESTING PURPOSES ONLY.
 */
contract Mock_erc20 is ERC20 {
    constructor(uint256 _supply) ERC20("GAME", "Game Theory (gametheory.tech): GAME Token") {
        _mint(msg.sender, _supply);
    }

    function mint(address _to, uint256 _amount) public {
        _mint(_to, _amount);
    }

    function burn(address _account, uint256 _value) public {
        _burn(_account, _value);
    }
}
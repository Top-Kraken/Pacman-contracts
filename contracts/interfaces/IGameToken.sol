// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract IGameToken is ERC20 {

    constructor() ERC20("GAME", "Game Theory (gametheory.tech): GAME Token") {}

    /**
    * @dev Burns a specific amount of tokens.
    * @param _account: The address for burn
    * @param _value: The amount of token to be burned.
    */
    function burn(address _account, uint256 _value) public {
        super._burn(_account, _value);
    }
}
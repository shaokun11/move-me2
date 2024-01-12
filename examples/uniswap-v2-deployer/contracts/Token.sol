// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {ERC20, ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract Token is ERC20, ERC20Permit {
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_)  ERC20Permit(name_)  {
    }

    function mint(address account, uint256 value) external {
        _mint(account, value);
    }
}

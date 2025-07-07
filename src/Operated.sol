// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Context } from "@openzeppelin/contracts/utils/Context.sol";
import { IOperator } from "./interfaces/IOperator.sol";

/// @title Operated contract
/// @dev Supports calls throught the Operator
abstract contract Operated is Context {
    IOperator public immutable operator;

    constructor(address operator_) {
        operator = IOperator(operator_);
    }

    /// @inheritdoc Context
    function _msgSender() internal view virtual override returns (address) {
        if (msg.sender == address(operator)) {
            return operator.onBehalfOf();
        }

        return msg.sender;
    }
}

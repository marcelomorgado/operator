// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Operated } from "src/Operated.sol";

contract OperatedMock is Operated {
    mapping(address sender => uint256 count) public balance;

    constructor(address operator_) Operated(operator_) { }

    function deposit() public payable {
        balance[_msgSender()] += msg.value;
    }
}

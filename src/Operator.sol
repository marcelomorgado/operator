// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { TransientSlot } from "@openzeppelin/contracts/utils/TransientSlot.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { ReentrancyGuardTransient } from "@openzeppelin/contracts/utils/ReentrancyGuardTransient.sol";
import { IOperator } from "./interfaces/IOperator.sol";

/// @title Operator contract
/// @dev Allows standard EOAs to perform batch calls
contract Operator is IOperator, ReentrancyGuardTransient {
    using TransientSlot for *;
    using Address for address;

    // keccak256(abi.encode(uint256(keccak256("operator.actual.sender")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant MSG_SENDER_STORAGE = 0x0de195ebe01a7763c35bcc87968c4e65e5a5ea50f2d7c33bed46c98755a66000;

    modifier setMsgSender() {
        MSG_SENDER_STORAGE.asAddress().tstore(msg.sender);
        _;
        MSG_SENDER_STORAGE.asAddress().tstore(address(0));
    }

    /// @inheritdoc IOperator
    function onBehalfOf() external view returns (address _actualMsgSender) {
        _actualMsgSender = MSG_SENDER_STORAGE.asAddress().tload();
        require(_actualMsgSender != address(0), "outside-call-context");
    }

    /// @inheritdoc IOperator
    function execute(Call[] calldata calls_)
        external
        payable
        override
        nonReentrant
        setMsgSender
        returns (bytes[] memory _returnData)
    {
        uint256 _length = calls_.length;
        _returnData = new bytes[](_length);

        uint256 _sumOfValues;
        Call calldata _call;
        for (uint256 i; i < _length;) {
            _call = calls_[i];
            uint256 _value = _call.value;
            unchecked {
                _sumOfValues += _value;
            }
            _returnData[i] = _call.target.functionCallWithValue(_call.callData, _value);
            unchecked {
                ++i;
            }
        }

        require(msg.value == _sumOfValues, "value-mismatch");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IOperator {
    struct Call {
        address target;
        uint256 value;
        bytes callData;
    }

    /// @notice Execute calls
    /// @param calls An array of Call structs
    /// @return returnData An array of bytes containing the responses
    function execute(Call[] calldata calls) external payable returns (bytes[] memory returnData);

    /// @notice The address which initiated the executions
    /// @return sender The actual sender of the calls
    function onBehalfOf() external view returns (address sender);
}

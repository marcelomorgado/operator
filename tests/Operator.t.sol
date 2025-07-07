// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.24 <0.9.0;

import "forge-std/src/Test.sol";
import { Operator, IOperator } from "src/Operator.sol";
import { OperatedMock } from "./mocks/OperatedMock.sol";

contract OperatorTest is Test {
    Operator internal operator;
    OperatedMock internal target;
    address alice = makeAddr("alice");

    function setUp() public virtual {
        operator = new Operator();
        target = new OperatedMock(address(operator));
    }

    function test_execute() external {
        // given
        vm.deal(alice, 2 ether);

        // when
        IOperator.Call memory call = IOperator.Call({
            target: address(target),
            value: 1 ether,
            callData: abi.encodeWithSelector(OperatedMock.deposit.selector)
        });

        IOperator.Call[] memory calls = new IOperator.Call[](2);
        calls[0] = call;
        calls[1] = call;

        vm.prank(alice);
        operator.execute{ value: 2 ether }(calls);

        // then
        assertEq(target.balance(alice), 2 ether, "Alice should have 2 ether");
    }

    function test_execute_revertOnValueMismatch() external {
        // given
        vm.deal(alice, 2 ether);

        // when
        IOperator.Call memory call = IOperator.Call({
            target: address(target),
            value: 1 ether,
            callData: abi.encodeWithSelector(OperatedMock.deposit.selector)
        });

        IOperator.Call[] memory calls = new IOperator.Call[](1);
        calls[0] = call;

        // when-then
        vm.prank(alice);
        vm.expectRevert("value-mismatch");
        operator.execute{ value: 2 ether }(calls);
    }

    function test_execute_revertOnCallback() external {
        // when
        IOperator.Call memory call = IOperator.Call({
            target: address(operator),
            value: 0,
            callData: abi.encodeWithSelector(IOperator.execute.selector, new IOperator.Call[](0))
        });

        IOperator.Call[] memory calls = new IOperator.Call[](1);
        calls[0] = call;

        // when-then
        vm.prank(alice);
        vm.expectRevert("ReentrancyGuardReentrantCall()");
        operator.execute(calls);
    }

    function test_execute_revertIfCallFails() external {
        // given
        vm.deal(alice, 1 ether);

        // when
        IOperator.Call memory call = IOperator.Call({
            target: address(target),
            value: 2 ether,
            callData: abi.encodeWithSelector(OperatedMock.deposit.selector)
        });

        IOperator.Call[] memory calls = new IOperator.Call[](1);
        calls[0] = call;

        // when-then
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSignature("InsufficientBalance(uint256,uint256)", 1 ether, 2 ether));
        operator.execute{ value: 1 ether }(calls);
    }
}

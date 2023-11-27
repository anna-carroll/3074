// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {BatchInvoker} from "../src/BatchInvoker.sol";

contract Callee {
    error UnexpectedSender(address expected, address actual);

    function expectSender(address expected) public payable {
        if (msg.sender != expected) revert UnexpectedSender(expected, msg.sender);
    }
}

contract BatchInvokerTest is Test {
    Callee public callee;
    BatchInvoker public invoker;
    BatchInvoker.Batch public batch;
    address public authority;
    uint256 public authorityKey = 1234;

    function setUp() public {
        invoker = new BatchInvoker();
        callee = new Callee();
        authority = vm.addr(authorityKey);
        vm.label(address(invoker), "invoker");
        vm.label(address(callee), "callee");
        vm.label(authority, "authority");
    }

    function constructAndSignBatch(uint256 nonce, uint256 value) internal returns (uint8 v, bytes32 r, bytes32 s) {
        batch.nonce = nonce;
        batch.calls.push(
            BatchInvoker.Call({
                to: address(callee),
                data: abi.encodeWithSelector(Callee.expectSender.selector, authority),
                value: value,
                gasLimit: 10_000
            })
        );
        // construct batch digest & sign
        bytes32 digest = invoker.getDigest(batch);
        (v, r, s) = vm.sign(authorityKey, digest);
    }

    // NOTE: right now, this test will fail; Callee will emit UnexpectedSender(authority, address(invoker))
    // because right now, the Invoker is calling the Callee with CALL (so msg.sender = Invoker)
    // the test will pass once Invoker successfully calls the Callee with AUTHCALL (so msg.sender = authority)
    function test_authCall() public {
        (uint8 v, bytes32 r, bytes32 s) = constructAndSignBatch(0, 0);
        // this will call Callee.expectSender(authority)
        invoker.execute(batch, v, r, s);
    }

    // invalid nonce fails
    function test_invalidNonce() public {
        // 1 is invalid starting nonce
        (uint8 v, bytes32 r, bytes32 s) = constructAndSignBatch(1, 0);
        vm.expectRevert(abi.encodeWithSelector(BatchInvoker.InvalidNonce.selector, authority, 0, 1));
        invoker.execute(batch, v, r, s);
    }

    function test_authCallWithValue() public {
        (uint8 v, bytes32 r, bytes32 s) = constructAndSignBatch(0, 1 ether);
        // this will call Callee.expectSender(authority)
        invoker.execute{value: 1 ether}(batch, v, r, s);
    }

    // fails if too little value to pass to sub-call
    function test_tooLittleValue() public {
        (uint8 v, bytes32 r, bytes32 s) = constructAndSignBatch(0, 1 ether);
        vm.expectRevert();
        invoker.execute{value: 0.5 ether}(batch, v, r, s);
    }

    // fails if too much value to pass to sub-call
    function test_tooMuchValue() public {
        (uint8 v, bytes32 r, bytes32 s) = constructAndSignBatch(0, 1 ether);
        vm.expectRevert(abi.encodeWithSelector(BatchInvoker.ExtraValue.selector));
        invoker.execute{value: 2 ether}(batch, v, r, s);
    }

    // TODO: test that auth returns authority address
}

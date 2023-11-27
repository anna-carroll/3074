# EIP-3074 - AUTH and AUTHCALL
[EIP-3074](https://eips.ethereum.org/EIPS/eip-3074) introduces two EVM instructions, `AUTH` and `AUTHCALL`

This repo contains
- contract`Auth`, which exposes basic usage of `AUTH` and `AUTHCALL` via inline assembly
- contract `BatchInvoker`, which illustrates an implementation of a safe Invoker contract which executes simple batched calls


## Todo
- [x] implement 3074 in geth - [WIP](https://github.com/ethereum/go-ethereum/pull/28615)
- [x] expose `AUTH` and `AUTHCALL` via inline assembly within solc - [WIP](https://github.com/ethereum/solidity/compare/develop...GregTheGreek:solidity:3074)
- [x] implement `Auth` and `BatchInvoker` example in Solidity - [WIP](https://github.com/anna-carroll/3074)
- [ ] implement 3074 in revm
- [ ] add a flag to Foundry that allows it to run against 3074 revm fork

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

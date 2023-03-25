# Curta

## Sourcecode

### Solution

- [Inspex - Paradigm CTF 2022 Writeup](https://inspexco.medium.com/paradigm-ctf-2022-writeup-2ce290cd9287#b1c5)
- [Amber Group's Writeup](https://medium.com/amber-group/web3-hacking-paradigm-ctf-2022-writeup-3102944fd6f5)
- [minaminao's Writeup](https://github.com/minaminao/ctf-blockchain/blob/main/src/ParadigmCTF2022/README.md)

This challenge is related to quine, which is a program that prints its own source code. The challenge is to write a smart contract that outputs its own bytecode. But some opcodes are not allowed. to bypass the restriction, we need to hardcode the bytecode of the contract.

In this case a quine contract contains two parts. The second part moves stack contents into memory and returns that memory. The first part contains a push instruction whose operand is the second part’s bytecode. The bytecode would be `PUSH_OP+code+code`.

I find 2 ways to solve this challenge.

1. bytecode padding approach
   This approach pads the bytecode with unused opcodes like `STOP` or `JUMPDEST`. The bytecode is padded to 32 bytes. This makes easier to manipulate the memory offset.
   The bytecode would be something like this: `0x7f80607f60005360015260215260416000f300000000000000000000000000000080607f60005360015260215260416000f3000000000000000000000000000000`
2. `karma.eth` approach / memory offset approach
   The bytecode would be something like this: `60238060093d393df37080602352601252607060205360236020f380602352601252607060205360236020f3s`

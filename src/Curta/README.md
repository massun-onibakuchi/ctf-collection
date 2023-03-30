# Curta

## F1A9

### Solution

compute a contract address that starts with a specific prefix.

## TinySig

```bash
python secp256k1.py
```

```bash
forge test --match-contract=TestTinySig --match-test=testExploit -vvv
```

### Solution

- [Hint](https://twitter.com/0xkarmacoma/status/1637516925617192960?s=20)
- [Great solution](https://twitter.com/rileyholterhus/status/1637905710095933441?s=20) by author

In summary $k = 1/2 (mod n)$ will make the `r` value equal the x-coordinate of `G/2`, which has an impossibly large number of zeros. And then we can compute the `z` and `r`. `z` and `r` are computed:

- Secp256k1 and ECDSA

  - [ECDSA](https://onyb.gitbook.io/secp256k1-python/ecdsa)
  - [Bitcoin wiki - ECDSA](https://en.bitcoin.it/wiki/Elliptic_Curve_Digital_Signature_Algorithm)
  - [ECC - Gentle Introduction](https://github.com/andreacorbellini/ecc/tree/master)

```python secp256k1.py
s = 0x4e12e14f842803868e861e7c44865edf2aa30674c8e7be2a94d32f5dc4ef247b # In this case, TinySig.generate(solver) is `s`
e = 0x0000000000000000000000000000000000000000000000000000000000000001 # private key
k = (curve.n - 1) // 2 # k = 1/2 (mod n)

r = scalar_mult(k, curve.g)[0] # r = x-coordinate of G/2
v = (r * inverse_mod(s, curve.n)) % curve.n
z = (k * s % curve.n - r * e % curve.n) % curve.n
if r < (2 << 184):
    print("k found:r ", hex(r), "k", hex(k))
    print("v found:v ", hex(v), "z", hex(z))
else:
    print("k not found", hex(r), "k", hex(k))
```

This generates:

```python
HASH = 0x58f68f583debfe3cb8bcf08664ee7a503e64fda4de3ac6dfe87200c10c43f200 // z
SIG_V = 0x000000000000000000000000000000000000000000000000000000000000001c // 28 in decimal
SIG_R = 0x00000000000000000000003b78ce563f89a0ed9414f5aa28ad0d96d6795f9c63
```

But the solution must be given as contract bytecode that satisfies the 32 byte limit. This restriction can be bypassed by:

1.  Separate the contract into two parts, the first contract satisfies the 32 byte limit, and the second one is a simple contract that returns `(h, v, r)` staticcalled by the first one.
2.  The second one's address would be hard-coded into the first one. The leading zeros of the address can reduce the size of the contract bytecode.

```solidity
function verify(uint256 _start, uint256 _solution) external returns (bool) {
    address target = address(new Deployer(abi.encodePacked(_solution)));
    (, bytes memory ret) = target.staticcall("");
    ...
}
```

I used Huff to minimize the bytecode of the first one.

## WhatAreBuckets

```bash
python3 what_are_buckets.py
```

```bash
forge test --match-contract=TestWhatAreBuckets --match-test=testExploit -vvv
```

### Solution

- [Writeup by author](https://hackmd.io/@xNSnimr_Rk68TArjAjMQvw/HkypUNJW2)
- [Writeup by karmacoma.eth](https://karmacoma.notion.site/Curta-CTF-4-WhatAreBuckets-d936460e0bf143bf8bc3eeb0b6136757)

The thing to notice is that:

- We can think of `commands` as a list of 3-bit values instead of `uint256`
- `work` function mutates `state` based on 3-bit values in `commands`
- If 3-bit value is 5 or 7, the function doesn't change `state`

```solidity
function workAll(uint256 state, uint256 commands)
  public
  pure
  returns (uint256)
{
  for (uint256 i = 0; i < 85; i++) {
    // @note extracts the i^th group of 3-bits in commands
    state = work(state, uint8(commands >> (i * 3)) & 7);
  }
  retursn state;
}

```

### Lesson

The goal is to have this return `true`:

```solidity
function verify(uint256 _start, uint256 _solution)
  external
  view
  returns (bool)
{
  uint256 v = workAll(
    _start,
    _solution ^ uint256(keccak256(abi.encodePacked(_start)))
  );
  // the lowest 16 bits must be the bit pattern 0000000000000001
  return v & 0xffff == 1;
}

```

- Breaking down the problem: Find out `k` that satisfies `workAll(_start, k) & 0xffff == 1`. if `k` is found out, `_solution` is computed easily.

- The `work` function looks complex. We can try the following approaches:

  1. Treat it as a black box.
     - Brute force
     - Symbolic execution (I tried symbolic execution with Halmos. Indeed it didn't work.)
     - Other tools
  2. Play around with it. We'd find some patterns in the `work` function. For example, if `op` is 5 or 7, the function doesn't do anything. We can guess these value would be useful to stay the `state` unchanged.
  3. In Curta, all submissions are public. We might get some hints from other submissions.

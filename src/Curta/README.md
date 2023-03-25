# Curta

## F1A9

### Solution

compute a contract address that starts with a specific prefix.

## TinySig

### Solution

[Great solution](https://twitter.com/rileyholterhus/status/1637905710095933441?s=20) by author

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

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

interface ICurta {
    /// @notice Mints an NFT if the provided solution solves the puzzle.
    /// @param _puzzleId The ID of the puzzle.
    /// @param _solution The solution.
    function solve(uint32 _puzzleId, uint256 _solution) external;
}

interface IPuzzle {
    /// @notice Returns the puzzle's name.
    /// @return The puzzle's name.
    function name() external pure returns (string memory);

    /// @notice Generates the puzzle's starting position based on a seed.
    /// @dev The seed is intended to be `msg.sender` of some wrapper function or
    /// call.
    /// @param _seed The seed to use to generate the puzzle.
    /// @return The puzzle's starting position.
    function generate(address _seed) external returns (uint256);

    /// @notice Verifies that a solution is valid for the puzzle.
    /// @dev `_start` is intended to be an output from {IPuzzle-generate}.
    /// @param _start The puzzle's starting position.
    /// @param _solution The solution to the puzzle.
    /// @return Whether the solution is valid.
    function verify(uint256 _start, uint256 _solution) external returns (bool);
}

/// @title 0xF1A9
/// @author fiveoutofnine
contract F1A9 is IPuzzle {
    /// @inheritdoc IPuzzle
    function name() external pure returns (string memory) {
        return "0xF1A9";
    }

    /// @inheritdoc IPuzzle
    function generate(address _seed) external view returns (uint256) {
        return (uint256(uint160(_seed)) >> (((block.number >> 8) & 0x1F) << 2)) & 0xFFFF;
    }

    /// @inheritdoc IPuzzle
    function verify(uint256 _start, uint256 _solution) external returns (bool) {
        uint256 prefix = block.timestamp < 1678446000 ? (0xF1A9 << 16) | _start : 0;
        console.log("0xF1A9 <<16 :>>", 0xF1A9 << 16);
        // console.logBytes32(bytes32(uint256(0xF1A9 << 16)));
        // 0xf1a90000 | 0x4bbb (19387) BLOCK 16788237??
        // 0xf1a90000 | 0x4dd4 = 0xf1a94dd4 BLOCK 0x1002e01
        // 0xf1a90000 | 0x6c4d = 0xf1a96c4d BLOCK 0x10030b0
        // 0xf1a90000 | 0x.... = 0xf1a9c596 BLOCK 0x1003300~0x10033ff
        // 0xf1a90000 | 0x.... = 0xf1a951c5 BLOCK 0x1003500(16790784)~
        // 0xf1a90000 | 0x.... = 0xf1a9c851 BLOCK 0x1003700()~
        // 0xf1a90000 | 0x.... =  BLOCK 0x1004200()~
        // console.log("_solution >> 128 :>>", _solution >> 128);
        console.log("address(uint160(_solution)) :>>", address(uint160(_solution)));
        // console.logBytes32(bytes32(prefix));
        console.log(prefix == (_solution >> 128));
        console.log(ISolve(address(uint160(_solution))).curtaPlayer());
        return prefix == (_solution >> 128) && ISolve(address(uint160(_solution))).curtaPlayer() == msg.sender;
    }
}

interface ISolve {
    function curtaPlayer() external pure returns (address);
}

contract TestF1A9 is Test {
    // timestamp 1678335683
    uint256 constant blockNumber = uint256(0x1004320);
    F1A9 f1a9;
    address sender = 0x004870D27dFd8C851c596c4dD4BbB0DabccaAc0a;
    uint256 start;

    function setUp() public {
        vm.createSelectFork("mainnet", blockNumber);
        vm.roll(blockNumber);
        f1a9 = new F1A9();
        start = f1a9.generate(sender);
        console.log("block.number :>>", block.number);
        console.log("f1a9.generate() :>>", start);
    }

    function testPrefix() public returns (uint256) {
        console.logBytes32(bytes32(getPrefix(sender, uint256(0x1004700)))); //16795392  0xf1a90dab
    }

    function getPrefix(address _seed, uint256 _blockNumber) public returns (uint256) {
        uint256 _start = (uint256(uint160(_seed)) >> (((_blockNumber >> 8) & 0x1F) << 2)) & 0xFFFF;
        uint256 prefix = block.timestamp < 1678446000 ? (0xF1A9 << 16) | _start : 0;
        return prefix;
    }

    function testExploit() public {
        // uint256 solution = 0x00f1a94bbb00000000000000000000000000000000 = prefix << 128 // bn 16788237
        // uint256 solution = 0x00<f1a9[4bbb]>00000000000000000000000000000000 = prefix << 128 // bn 16788237
        // uint256 solution = 0x00f1a94bbb12345600000000000000000000000000;
        // f1a90dab
        address curta = 0x0000000006bC8D9e5e9d436217B88De704a9F307;
        address factory = 0xD655A7ce4C39c7a02998B8374f5d8E81c93D3E4e;
        bytes32 salt = 0x8b11ac1274360b77814d1dee4755cbaa6222f0d64e4549328f42caaf86c39e4a; // input
        address eip_address = 0xF1A90dabEd2c8734B6Ab9c33abd77f715662e466; //input
        uint256 solution = 0x00F1A90dabEd2c8734B6Ab9c33abd77f715662e466; // 0x00<eip_address>

        vm.roll(uint256(0x1004700));
        address _solve = Creater2(factory).deploy(salt);
        require(_solve == eip_address, "not eip address");
        require(Solve(eip_address).curtaPlayer() == curta, "not sender");

        // vm.prank(sender);
        // assertTrue(f1a9.verify(start, solution));

        vm.prank(sender);
        // vm.mockCall(eip_address, abi.encodeWithSelector(ISolve.curtaPlayer.selector), abi.encode(curta));
        ICurta(curta).solve(2, solution);
    }

    function testDeploy() public {
        // arrange
        address factory = 0xD655A7ce4C39c7a02998B8374f5d8E81c93D3E4e;

        bytes32 salt = 0xb265e0c5f360f824b2077d2aa85dbe7f6690a31adadba0788f8880e78c4231f5;
        bytes32 INIT_CODE_HASH = 0xfbb86d00481c290629555f9a64893e17171bd91b83ad1b4eea7216b654083c78;
        address eip_address = 0x0005F1697ea06B9641ad38DCcf33e7C93C3257AE;

        // act
        address _solve = Creater2(factory).deploy(salt);
        console.logAddress(_solve);

        // assert
        assertEq(_solve, _getCreate2Address(factory, salt, INIT_CODE_HASH), "derived address doesn't match");
        assertEq(_solve, eip_address, "derived address doesn't match 2");
    }

    function _getCreate2Address(
        address factory,
        bytes32 salt,
        bytes32 init_code_hash
    ) public view returns (address) {
        // cast compute-address 0x004870D27dFd8C851c596c4dD4BbB0DabccaAc0a --rpc-url=$MAINNET_RPC_URL
        address predictedAddress = address(
            uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), factory, salt, init_code_hash))))
        );
        return predictedAddress;
    }
}

contract Solve is ISolve {
    function curtaPlayer() external pure override returns (address) {
        return 0x0000000006bC8D9e5e9d436217B88De704a9F307;
    }
}

contract Creater2 {
    bytes32 public constant INIT_CODE_HASH = keccak256(abi.encodePacked(type(Solve).creationCode));

    function deploy(bytes32 salt) external returns (address) {
        return address(new Solve{salt: salt}());
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface ICurta {
    /// @notice Mints an NFT if the provided solution solves the puzzle.
    /// @param _puzzleId The ID of the puzzle.
    /// @param _solution The solution.
    function solve(uint32 _puzzleId, uint256 _solution) external payable;
}

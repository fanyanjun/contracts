// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../Model.sol";

interface IFarmReward {
    function getCheckpointAddrs() external view returns(address[] memory);
    function getCheckpoints(address userAddr, uint256 stakingIndex) external view returns(Model.Checkpoint[] memory);
    function getCheckpointStakingIndexs(address userAddr) external view returns(uint256[] memory);
    function calcRewardAmount(address userAddr, uint256 stakingIndex) external view returns(uint256);
    function calcRewardAmount(address userAddr) external view returns(uint256);
    function proxyClaim(address userAddr, uint256 index) external;
}
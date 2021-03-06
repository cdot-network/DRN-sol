// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.4.22 <0.9.0;

interface IEthLocker {
    function initDispatcher(address targetAddr) external;

    function lockEth(uint256 amount, string memory accountId) external;

    function unlockEth(bytes memory proofData, uint64 proofBlockHeight) external;

    function burnResult(bytes memory proofData, uint64 proofBlockHeight) external view returns (address);

    // In case of loss
    function deposit() external payable;

    // For investments
    function setReserveRatio(uint16 ratio) external;

    function setMinHarvest(uint16 ratio) external;

    function depositToStrategy(address strategyAddr, uint256 amount) external;

    function depositAllToStrategy(address strategyAddr) external;

    function withdrawFromStrategy(address strategyAddr, uint256 amount) external;

    function withdrawAllFromStrategy(address strategyAddr) external;

    // Rewards
    function setRewardsRatio(uint16 ratio) external;

    function transferRewards(address relayRegistryAddr) external;

    function harvest(address strategyAddr) external;

    function harvestAll() external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/NoWasteToken.sol";

contract NoWasteTokenTest is Test {
    NoWasteToken public token;
    address public treasury;
    address public user1;
    address public user2;
    address public user3;
    
    uint256 constant MAX_SUPPLY = 1_000_000_000 * 10**18;
    uint256 constant BURN_RATE = 100; // 1%
    
    function setUp() public {
        treasury = makeAddr("treasury");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        user3 = makeAddr("user3");
        
        token = new NoWasteToken(treasury);
    }
    
    // ============ Deployment Tests ============
    
    function testInitialSupply() public {
        assertEq(token.totalSupply(), MAX_SUPPLY);
        assertEq(token.balanceOf(address(this)), MAX_SUPPLY);
    }
    
    function testTokenMetadata() public {
        assertEq(token.name(), "NoWaste Token");
        assertEq(token.symbol(), "NOWASTE");
        assertEq(token.decimals(), 18);
    }
    
    function testTreasuryAddress() public {
        assertEq(token.treasuryAddress(), treasury);
    }
    
    // ============ Transfer Tests ============
    
    function testTransferWithBurn() public {
        uint256 amount = 1000 * 10**18;
        uint256 expectedBurn = (amount * BURN_RATE) / 10000;
        uint256 expectedTransfer = amount - expectedBurn;
        
        token.transfer(user1, amount);
        
        assertEq(token.balanceOf(user1), expectedTransfer);
        assertEq(token.totalBurned(), expectedBurn);
        assertEq(token.totalSupply(), MAX_SUPPLY - expectedBurn);
    }
    
    function testMultipleTransfersBurnAccumulation() public {
        uint256 amount = 1000 * 10**18;
        
        token.transfer(user1, amount);
        token.transfer(user2, amount);
        
        uint256 expectedBurnPerTransfer = (amount * BURN_RATE) / 10000;
        uint256 totalExpectedBurn = expectedBurnPerTransfer * 2;
        
        assertEq(token.totalBurned(), totalExpectedBurn);
    }
    
    function testTransferFromWithBurn() public {
        uint256 amount = 1000 * 10**18;
        
        token.approve(user1, amount);
        
        vm.prank(user1);
        token.transferFrom(address(this), user2, amount);
        
        uint256 expectedBurn = (amount * BURN_RATE) / 10000;
        uint256 expectedTransfer = amount - expectedBurn;
        
        assertEq(token.balanceOf(user2), expectedTransfer);
        assertEq(token.totalBurned(), expectedBurn);
    }
    
    // ============ Staking Tests ============
    
    function testStake() public {
        uint256 transferAmount = 10000 * 10**18;
        uint256 stakeAmount = 1000 * 10**18;
        
        token.transfer(user1, transferAmount);
        
        vm.startPrank(user1);
        token.stake(stakeAmount);
        vm.stopPrank();
        
        assertEq(token.stakedBalance(user1), stakeAmount);
        assertGt(token.stakingTimestamp(user1), 0);
    }
    
    function testStakeFailsWithInsufficientBalance() public {
        vm.prank(user1);
        vm.expectRevert("Insufficient balance");
        token.stake(1000 * 10**18);
    }
    
    function testUnstake() public {
        uint256 transferAmount = 10000 * 10**18;
        uint256 stakeAmount = 1000 * 10**18;
        
        token.transfer(user1, transferAmount);
        
        vm.startPrank(user1);
        token.stake(stakeAmount);
        
        uint256 balanceBefore = token.balanceOf(user1);
        token.unstake(stakeAmount);
        vm.stopPrank();
        
        assertEq(token.stakedBalance(user1), 0);
        assertEq(token.stakingTimestamp(user1), 0);
        assertEq(token.balanceOf(user1), balanceBefore + stakeAmount);
    }
    
    function testPartialUnstake() public {
        uint256 transferAmount = 10000 * 10**18;
        uint256 stakeAmount = 1000 * 10**18;
        uint256 unstakeAmount = 300 * 10**18;
        
        token.transfer(user1, transferAmount);
        
        vm.startPrank(user1);
        token.stake(stakeAmount);
        token.unstake(unstakeAmount);
        vm.stopPrank();
        
        assertEq(token.stakedBalance(user1), stakeAmount - unstakeAmount);
        assertGt(token.stakingTimestamp(user1), 0); // Should not reset
    }
    
    function testGetTotalBalance() public {
        uint256 transferAmount = 10000 * 10**18;
        uint256 stakeAmount = 1000 * 10**18;
        
        token.transfer(user1, transferAmount);
        
        vm.prank(user1);
        token.stake(stakeAmount);
        
        uint256 expectedBurn = (transferAmount * BURN_RATE) / 10000;
        uint256 expectedTotal = transferAmount - expectedBurn;
        
        assertEq(token.getTotalBalance(user1), expectedTotal);
    }
    
    function testHasMinimumStake() public {
        uint256 transferAmount = 10000 * 10**18;
        uint256 stakeAmount = 1000 * 10**18;
        
        token.transfer(user1, transferAmount);
        
        vm.prank(user1);
        token.stake(stakeAmount);
        
        assertTrue(token.hasMinimumStake(user1, 500 * 10**18));
        assertTrue(token.hasMinimumStake(user1, 1000 * 10**18));
        assertFalse(token.hasMinimumStake(user1, 2000 * 10**18));
    }
    
    // ============ Reputation Tests ============
    
    function testUpdateReputation() public {
        token.updateReputation(user1, 750);
        assertEq(token.reputationScore(user1), 750);
    }
    
    function testUpdateReputationFailsAboveMax() public {
        vm.expectRevert("Score must be <= 1000");
        token.updateReputation(user1, 1001);
    }
    
    function testGetVotingPower() public {
        uint256 transferAmount = 10000 * 10**18;
        
        token.transfer(user1, transferAmount);
        token.updateReputation(user1, 500); // 1.25x multiplier
        
        uint256 expectedBurn = (transferAmount * BURN_RATE) / 10000;
        uint256 balance = transferAmount - expectedBurn;
        uint256 multiplier = 1000 + (500 / 2); // 1250
        uint256 expectedVotingPower = (balance * multiplier) / 1000;
        
        assertEq(token.getVotingPower(user1), expectedVotingPower);
    }
    
    function testGetVotingPowerWithStake() public {
        uint256 transferAmount = 10000 * 10**18;
        uint256 stakeAmount = 1000 * 10**18;
        
        token.transfer(user1, transferAmount);
        token.updateReputation(user1, 1000); // 1.5x multiplier
        
        vm.prank(user1);
        token.stake(stakeAmount);
        
        uint256 expectedBurn = (transferAmount * BURN_RATE) / 10000;
        uint256 totalBalance = transferAmount - expectedBurn;
        uint256 multiplier = 1000 + (1000 / 2); // 1500
        uint256 expectedVotingPower = (totalBalance * multiplier) / 1000;
        
        assertEq(token.getVotingPower(user1), expectedVotingPower);
    }
    
    // ============ Revenue Distribution Tests ============
    
    function testDistributeRevenue() public {
        uint256 distributionAmount = 100000 * 10**18;
        
        // Transfer some tokens to users first
        token.transfer(user1, 1000000 * 10**18);
        token.transfer(user2, 500000 * 10**18);
        
        token.distributeRevenue(distributionAmount);
        
        assertEq(token.totalRevenueDistributed(), distributionAmount);
        assertGt(token.revenuePerToken(), 0);
    }
    
    function testClaimRevenue() public {
        uint256 userTransfer = 1000000 * 10**18;
        uint256 distributionAmount = 100000 * 10**18;
        
        token.transfer(user1, userTransfer);
        token.distributeRevenue(distributionAmount);
        
        vm.prank(user1);
        token.claimRevenue();
        
        // User should have received some revenue
        uint256 expectedBurn = (userTransfer * BURN_RATE) / 10000;
        uint256 userBalance = userTransfer - expectedBurn;
        
        assertGt(token.balanceOf(user1), userBalance);
    }
    
    function testCalculatePendingRevenue() public {
        uint256 userTransfer = 1000000 * 10**18;
        uint256 distributionAmount = 100000 * 10**18;
        
        token.transfer(user1, userTransfer);
        token.distributeRevenue(distributionAmount);
        
        uint256 pending = token.calculatePendingRevenue(user1);
        assertGt(pending, 0);
    }
    
    // ============ Admin Functions Tests ============
    
    function testSetAuthorizedContracts() public {
        address mockReputation = makeAddr("reputation");
        address mockDonation = makeAddr("donation");
        address mockDAO = makeAddr("dao");
        
        token.setReputationSystem(mockReputation);
        token.setDonationManager(mockDonation);
        token.setDAOGovernance(mockDAO);
        
        assertEq(token.reputationSystemAddress(), mockReputation);
        assertEq(token.donationManagerAddress(), mockDonation);
        assertEq(token.daoGovernanceAddress(), mockDAO);
    }
    
    function testBurn() public {
        uint256 burnAmount = 1000 * 10**18;
        uint256 initialSupply = token.totalSupply();
        
        token.burn(burnAmount);
        
        assertEq(token.totalSupply(), initialSupply - burnAmount);
        assertEq(token.totalBurned(), burnAmount);
    }
    
    function testGetTokenStats() public {
        uint256 transferAmount = 10000 * 10**18;
        token.transfer(user1, transferAmount);
        token.transfer(treasury, 5000 * 10**18);
        
        (
            uint256 circulatingSupply,
            uint256 totalStaked,
            uint256 burnedTokens,
            uint256 treasuryBalance
        ) = token.getTokenStats();
        
        assertGt(burnedTokens, 0);
        assertGt(treasuryBalance, 0);
        assertEq(circulatingSupply, token.totalSupply());
    }
    
    function testGetUserStats() public {
        uint256 transferAmount = 10000 * 10**18;
        uint256 stakeAmount = 1000 * 10**18;
        
        token.transfer(user1, transferAmount);
        token.updateReputation(user1, 750);
        
        vm.prank(user1);
        token.stake(stakeAmount);
        
        (
            uint256 balance,
            uint256 staked,
            uint256 reputation,
            uint256 votingPower,
            uint256 pendingRevenue,
            uint256 stakingDuration
        ) = token.getUserStats(user1);
        
        assertGt(balance, 0);
        assertEq(staked, stakeAmount);
        assertEq(reputation, 750);
        assertGt(votingPower, 0);
        assertGt(stakingDuration, 0);
    }
    
    // ============ Access Control Tests ============
    
    function testOnlyOwnerCanSetContracts() public {
        address mockContract = makeAddr("mock");
        
        vm.prank(user1);
        vm.expectRevert();
        token.setReputationSystem(mockContract);
    }
    
    function testOnlyAuthorizedCanUpdateReputation() public {
        vm.prank(user1);
        vm.expectRevert("Not authorized");
        token.updateReputation(user2, 500);
    }
}

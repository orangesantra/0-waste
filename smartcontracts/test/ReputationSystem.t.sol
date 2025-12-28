// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/ReputationSystem.sol";

contract ReputationSystemTest is Test {
    ReputationSystem public reputation;
    address public owner;
    address public donationManager;
    address public user1;
    address public user2;
    address public user3;
    
    function setUp() public {
        owner = address(this);
        donationManager = makeAddr("donationManager");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        user3 = makeAddr("user3");
        
        reputation = new ReputationSystem();
        reputation.setDonationManager(donationManager);
    }
    
    // ============ Initialization Tests ============
    
    function testInitialScore() public {
        assertEq(reputation.getReputationScore(user1), 0);
    }
    
    function testSetDonationManager() public {
        address newManager = makeAddr("newManager");
        reputation.setDonationManager(newManager);
        assertEq(reputation.donationManagerAddress(), newManager);
    }
    
    // ============ Successful Donation Tests ============
    
    function testRecordSuccessfulDonation() public {
        vm.prank(donationManager);
        reputation.recordSuccessfulDonation(user1);
        
        assertEq(reputation.getReputationScore(user1), 10);
        assertEq(reputation.totalDonations(user1), 1);
        assertEq(reputation.currentStreak(user1), 1);
    }
    
    function testMultipleSuccessfulDonations() public {
        vm.startPrank(donationManager);
        
        for(uint i = 0; i < 5; i++) {
            reputation.recordSuccessfulDonation(user1);
        }
        
        vm.stopPrank();
        
        assertEq(reputation.getReputationScore(user1), 50);
        assertEq(reputation.totalDonations(user1), 5);
        assertEq(reputation.currentStreak(user1), 5);
    }
    
    function testScoreCappedAt1000() public {
        vm.startPrank(donationManager);
        
        // Record 150 successful donations (would be 1500 points)
        for(uint i = 0; i < 150; i++) {
            reputation.recordSuccessfulDonation(user1);
        }
        
        vm.stopPrank();
        
        assertEq(reputation.getReputationScore(user1), 1000);
    }
    
    // ============ Cancelled Donation Tests ============
    
    function testRecordCancelledDonation() public {
        // Build up score first
        vm.startPrank(donationManager);
        for(uint i = 0; i < 10; i++) {
            reputation.recordSuccessfulDonation(user1);
        }
        
        reputation.recordCancelledDonation(user1);
        vm.stopPrank();
        
        assertEq(reputation.getReputationScore(user1), 95); // 100 - 5 penalty
        assertEq(reputation.totalCancellations(user1), 1);
        assertEq(reputation.currentStreak(user1), 0); // Streak broken
    }
    
    function testScoreCannotGoBelowZero() public {
        vm.prank(donationManager);
        reputation.recordCancelledDonation(user1);
        
        assertEq(reputation.getReputationScore(user1), 0);
    }
    
    function testStreakBrokenOnCancellation() public {
        vm.startPrank(donationManager);
        
        reputation.recordSuccessfulDonation(user1);
        reputation.recordSuccessfulDonation(user1);
        reputation.recordSuccessfulDonation(user1);
        
        assertEq(reputation.currentStreak(user1), 3);
        
        reputation.recordCancelledDonation(user1);
        
        assertEq(reputation.currentStreak(user1), 0);
        vm.stopPrank();
    }
    
    // ============ Dispute Tests ============
    
    function testRecordDispute() public {
        vm.startPrank(donationManager);
        
        // Build reputation
        for(uint i = 0; i < 20; i++) {
            reputation.recordSuccessfulDonation(user1);
        }
        
        reputation.recordDispute(user1, true);
        vm.stopPrank();
        
        assertEq(reputation.getReputationScore(user1), 185); // 200 - 15 penalty
        assertEq(reputation.totalDisputes(user1), 1);
        assertEq(reputation.currentStreak(user1), 0);
    }
    
    function testRecordDisputeFavorable() public {
        vm.startPrank(donationManager);
        
        // Build reputation
        for(uint i = 0; i < 20; i++) {
            reputation.recordSuccessfulDonation(user1);
        }
        
        reputation.recordDispute(user1, false);
        vm.stopPrank();
        
        assertEq(reputation.getReputationScore(user1), 200); // No penalty if favorable
        assertEq(reputation.totalDisputes(user1), 1);
    }
    
    // ============ Tier Tests ============
    
    function testGetTier_Bronze() public {
        vm.prank(donationManager);
        reputation.recordSuccessfulDonation(user1);
        
        assertEq(uint(reputation.getTier(user1)), uint(ReputationSystem.Tier.BRONZE));
    }
    
    function testGetTier_Silver() public {
        vm.startPrank(donationManager);
        for(uint i = 0; i < 30; i++) {
            reputation.recordSuccessfulDonation(user1);
        }
        vm.stopPrank();
        
        assertEq(uint(reputation.getTier(user1)), uint(ReputationSystem.Tier.SILVER));
    }
    
    function testGetTier_Gold() public {
        vm.startPrank(donationManager);
        for(uint i = 0; i < 60; i++) {
            reputation.recordSuccessfulDonation(user1);
        }
        vm.stopPrank();
        
        assertEq(uint(reputation.getTier(user1)), uint(ReputationSystem.Tier.GOLD));
    }
    
    function testGetTier_Platinum() public {
        vm.startPrank(donationManager);
        for(uint i = 0; i < 90; i++) {
            reputation.recordSuccessfulDonation(user1);
        }
        vm.stopPrank();
        
        assertEq(uint(reputation.getTier(user1)), uint(ReputationSystem.Tier.PLATINUM));
    }
    
    // ============ Multiplier Tests ============
    
    function testGetRewardMultiplier_Bronze() public {
        vm.prank(donationManager);
        reputation.recordSuccessfulDonation(user1);
        
        assertEq(reputation.getRewardMultiplier(user1), 1000); // 1.0x
    }
    
    function testGetRewardMultiplier_Silver() public {
        vm.startPrank(donationManager);
        for(uint i = 0; i < 30; i++) {
            reputation.recordSuccessfulDonation(user1);
        }
        vm.stopPrank();
        
        assertEq(reputation.getRewardMultiplier(user1), 1250); // 1.25x
    }
    
    function testGetRewardMultiplier_Gold() public {
        vm.startPrank(donationManager);
        for(uint i = 0; i < 60; i++) {
            reputation.recordSuccessfulDonation(user1);
        }
        vm.stopPrank();
        
        assertEq(reputation.getRewardMultiplier(user1), 1500); // 1.5x
    }
    
    function testGetRewardMultiplier_Platinum() public {
        vm.startPrank(donationManager);
        for(uint i = 0; i < 90; i++) {
            reputation.recordSuccessfulDonation(user1);
        }
        vm.stopPrank();
        
        assertEq(reputation.getRewardMultiplier(user1), 2000); // 2.0x
    }
    
    // ============ Staking Discount Tests ============
    
    function testGetStakingDiscount_NoReputation() public {
        assertEq(reputation.getStakingDiscount(user1), 0);
    }
    
    function testGetStakingDiscount_LowReputation() public {
        vm.startPrank(donationManager);
        for(uint i = 0; i < 10; i++) {
            reputation.recordSuccessfulDonation(user1);
        }
        vm.stopPrank();
        
        assertEq(reputation.getStakingDiscount(user1), 0); // Score 100, no discount
    }
    
    function testGetStakingDiscount_MediumReputation() public {
        vm.startPrank(donationManager);
        for(uint i = 0; i < 40; i++) {
            reputation.recordSuccessfulDonation(user1);
        }
        vm.stopPrank();
        
        assertEq(reputation.getStakingDiscount(user1), 1000); // Score 400, 10% discount
    }
    
    function testGetStakingDiscount_HighReputation() public {
        vm.startPrank(donationManager);
        for(uint i = 0; i < 70; i++) {
            reputation.recordSuccessfulDonation(user1);
        }
        vm.stopPrank();
        
        assertEq(reputation.getStakingDiscount(user1), 2500); // Score 700, 25% discount
    }
    
    function testGetStakingDiscount_MaxReputation() public {
        vm.startPrank(donationManager);
        for(uint i = 0; i < 90; i++) {
            reputation.recordSuccessfulDonation(user1);
        }
        vm.stopPrank();
        
        assertEq(reputation.getStakingDiscount(user1), 5000); // Score 900+, 50% discount
    }
    
    // ============ Streak Tests ============
    
    function testStreakIncrement() public {
        vm.startPrank(donationManager);
        
        for(uint i = 0; i < 5; i++) {
            reputation.recordSuccessfulDonation(user1);
            assertEq(reputation.currentStreak(user1), i + 1);
        }
        
        vm.stopPrank();
    }
    
    function testMaxStreakTracking() public {
        vm.startPrank(donationManager);
        
        // Build a streak of 10
        for(uint i = 0; i < 10; i++) {
            reputation.recordSuccessfulDonation(user1);
        }
        
        assertEq(reputation.maxStreak(user1), 10);
        
        // Break streak
        reputation.recordCancelledDonation(user1);
        
        // Build a smaller streak
        for(uint i = 0; i < 5; i++) {
            reputation.recordSuccessfulDonation(user1);
        }
        
        assertEq(reputation.maxStreak(user1), 10); // Max should still be 10
        assertEq(reputation.currentStreak(user1), 5);
        
        vm.stopPrank();
    }
    
    // ============ User Stats Tests ============
    
    function testGetUserStats() public {
        vm.startPrank(donationManager);
        
        for(uint i = 0; i < 25; i++) {
            reputation.recordSuccessfulDonation(user1);
        }
        
        reputation.recordCancelledDonation(user1);
        reputation.recordDispute(user1, true);
        
        vm.stopPrank();
        
        (
            uint256 score,
            ReputationSystem.Tier tier,
            uint256 donations,
            uint256 cancellations,
            uint256 disputes,
            uint256 streak,
            uint256 maxStreakVal,
            uint256 multiplier,
            uint256 discount
        ) = reputation.getUserStats(user1);
        
        assertGt(score, 0);
        assertEq(uint(tier), uint(ReputationSystem.Tier.SILVER));
        assertEq(donations, 25);
        assertEq(cancellations, 1);
        assertEq(disputes, 1);
        assertEq(streak, 0);
        assertGt(maxStreakVal, 0);
        assertGt(multiplier, 1000);
        assertGt(discount, 0);
    }
    
    // ============ Access Control Tests ============
    
    function testOnlyDonationManagerCanRecordDonation() public {
        vm.prank(user1);
        vm.expectRevert("Not authorized");
        reputation.recordSuccessfulDonation(user2);
    }
    
    function testOnlyDonationManagerCanRecordCancellation() public {
        vm.prank(user1);
        vm.expectRevert("Not authorized");
        reputation.recordCancelledDonation(user2);
    }
    
    function testOnlyDonationManagerCanRecordDispute() public {
        vm.prank(user1);
        vm.expectRevert("Not authorized");
        reputation.recordDispute(user2, true);
    }
    
    function testOnlyOwnerCanSetDonationManager() public {
        vm.prank(user1);
        vm.expectRevert();
        reputation.setDonationManager(user2);
    }
    
    // ============ Edge Cases ============
    
    function testMultipleUsersIndependentScores() public {
        vm.startPrank(donationManager);
        
        for(uint i = 0; i < 10; i++) {
            reputation.recordSuccessfulDonation(user1);
        }
        
        for(uint i = 0; i < 20; i++) {
            reputation.recordSuccessfulDonation(user2);
        }
        
        for(uint i = 0; i < 30; i++) {
            reputation.recordSuccessfulDonation(user3);
        }
        
        vm.stopPrank();
        
        assertEq(reputation.getReputationScore(user1), 100);
        assertEq(reputation.getReputationScore(user2), 200);
        assertEq(reputation.getReputationScore(user3), 300);
    }
    
    function testScoreRecoveryAfterPenalty() public {
        vm.startPrank(donationManager);
        
        // Build score
        for(uint i = 0; i < 50; i++) {
            reputation.recordSuccessfulDonation(user1);
        }
        
        uint256 scoreBefore = reputation.getReputationScore(user1);
        
        // Get penalty
        reputation.recordCancelledDonation(user1);
        
        uint256 scoreAfter = reputation.getReputationScore(user1);
        assertLt(scoreAfter, scoreBefore);
        
        // Recover with more donations
        for(uint i = 0; i < 50; i++) {
            reputation.recordSuccessfulDonation(user1);
        }
        
        uint256 scoreFinal = reputation.getReputationScore(user1);
        assertGt(scoreFinal, scoreBefore);
        
        vm.stopPrank();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./NoWasteToken.sol";

/**
 * @title DAOGovernance
 * @dev Decentralized governance for NoWaste Protocol
 * Token holders can create proposals and vote on protocol changes
 */
contract DAOGovernance is Ownable, ReentrancyGuard {
    
    // ============ Structs ============
    
    struct Proposal {
        uint256 id;
        address proposer;
        string title;
        string description;
        ProposalType proposalType;
        uint256 forVotes;
        uint256 againstVotes;
        uint256 abstainVotes;
        uint256 startTime;
        uint256 endTime;
        uint256 executionTime;
        bool executed;
        bool cancelled;
        bytes callData;                // Encoded function call
        address targetContract;        // Contract to call
    }
    
    enum ProposalType {
        PARAMETER_CHANGE,     // Change protocol parameters
        TREASURY_SPEND,       // Spend from treasury
        CONTRACT_UPGRADE,     // Upgrade smart contracts
        EMERGENCY,            // Emergency actions
        GENERAL               // General governance decisions
    }
    
    enum VoteChoice {
        AGAINST,
        FOR,
        ABSTAIN
    }
    
    struct ProposalConfig {
        uint256 quorumPercentage;      // Required quorum (%)
        uint256 passThreshold;         // Required votes to pass (%)
        uint256 votingPeriod;          // Voting duration
        uint256 timelockPeriod;        // Delay before execution
    }
    
    // ============ State Variables ============
    
    NoWasteToken public token;
    
    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    mapping(uint256 => mapping(address => VoteChoice)) public userVote;
    mapping(uint256 => mapping(address => uint256)) public userVotingPower;
    
    uint256 public proposalCounter;
    uint256 public executedProposals;
    
    // Minimum voting power required to create proposal
    uint256 public PROPOSAL_THRESHOLD = 5000 * 10**18; // 5,000 tokens
    
    // Default proposal configurations
    mapping(ProposalType => ProposalConfig) public proposalConfigs;
    
    // Security council for emergency actions
    mapping(address => bool) public securityCouncil;
    uint256 public securityCouncilSize;
    
    // Global governance settings
    bool public governanceActive = true;
    address public treasuryAddress;
    
    // ============ Events ============
    
    event ProposalCreated(
        uint256 indexed id,
        address indexed proposer,
        string title,
        ProposalType proposalType,
        uint256 startTime,
        uint256 endTime
    );
    event VoteCast(
        uint256 indexed proposalId,
        address indexed voter,
        VoteChoice choice,
        uint256 votingPower
    );
    event ProposalExecuted(uint256 indexed proposalId, bool success);
    event ProposalCancelled(uint256 indexed proposalId, address canceller);
    event SecurityCouncilUpdated(address indexed member, bool status);
    event ProposalConfigUpdated(ProposalType proposalType, ProposalConfig config);
    event GovernanceStatusChanged(bool active);
    
    // ============ Modifiers ============
    
    modifier governanceEnabled() {
        require(governanceActive, "Governance paused");
        _;
    }
    
    modifier onlySecurityCouncil() {
        require(securityCouncil[msg.sender], "Not security council member");
        _;
    }
    
    modifier proposalExists(uint256 proposalId) {
        require(proposalId > 0 && proposalId <= proposalCounter, "Proposal doesn't exist");
        _;
    }
    
    // ============ Constructor ============
    
    constructor(address _tokenAddress, address _treasuryAddress)
    {
        require(_tokenAddress != address(0), "Invalid token address");
        require(_treasuryAddress != address(0), "Invalid treasury address");
        
        token = NoWasteToken(_tokenAddress);
        treasuryAddress = _treasuryAddress;
        
        // Initialize proposal configs
        _initializeProposalConfigs();
        
        // Add deployer to security council initially
        securityCouncil[msg.sender] = true;
        securityCouncilSize = 1;
    }
    
    // ============ Proposal Functions ============
    
    /**
     * @dev Create a new governance proposal
     */
    function createProposal(
        string memory title,
        string memory description,
        ProposalType proposalType,
        address targetContract,
        bytes memory callData
    ) external governanceEnabled nonReentrant returns (uint256) {
        
        require(bytes(title).length > 0, "Title required");
        require(bytes(description).length > 0, "Description required");
        
        // Check proposer has sufficient voting power
        uint256 votingPower = token.getVotingPower(msg.sender);
        require(
            votingPower >= PROPOSAL_THRESHOLD,
            "Insufficient voting power"
        );
        
        proposalCounter++;
        uint256 proposalId = proposalCounter;
        
        ProposalConfig memory config = proposalConfigs[proposalType];
        
        proposals[proposalId] = Proposal({
            id: proposalId,
            proposer: msg.sender,
            title: title,
            description: description,
            proposalType: proposalType,
            forVotes: 0,
            againstVotes: 0,
            abstainVotes: 0,
            startTime: block.timestamp,
            endTime: block.timestamp + config.votingPeriod,
            executionTime: 0,
            executed: false,
            cancelled: false,
            callData: callData,
            targetContract: targetContract
        });
        
        emit ProposalCreated(
            proposalId,
            msg.sender,
            title,
            proposalType,
            block.timestamp,
            block.timestamp + config.votingPeriod
        );
        
        return proposalId;
    }
    
    /**
     * @dev Cast vote on a proposal
     */
    function castVote(uint256 proposalId, VoteChoice choice) 
        external 
        governanceEnabled 
        nonReentrant 
        proposalExists(proposalId) 
    {
        Proposal storage proposal = proposals[proposalId];
        
        require(!proposal.executed, "Proposal already executed");
        require(!proposal.cancelled, "Proposal cancelled");
        require(block.timestamp >= proposal.startTime, "Voting not started");
        require(block.timestamp <= proposal.endTime, "Voting ended");
        require(!hasVoted[proposalId][msg.sender], "Already voted");
        
        // Get user's voting power at time of vote
        uint256 votingPower = token.getVotingPower(msg.sender);
        require(votingPower > 0, "No voting power");
        
        // Record vote
        hasVoted[proposalId][msg.sender] = true;
        userVote[proposalId][msg.sender] = choice;
        userVotingPower[proposalId][msg.sender] = votingPower;
        
        // Update vote counts
        if (choice == VoteChoice.FOR) {
            proposal.forVotes += votingPower;
        } else if (choice == VoteChoice.AGAINST) {
            proposal.againstVotes += votingPower;
        } else {
            proposal.abstainVotes += votingPower;
        }
        
        emit VoteCast(proposalId, msg.sender, choice, votingPower);
    }
    
    /**
     * @dev Execute a passed proposal
     */
    function executeProposal(uint256 proposalId) 
        external 
        nonReentrant 
        proposalExists(proposalId) 
    {
        Proposal storage proposal = proposals[proposalId];
        
        require(!proposal.executed, "Already executed");
        require(!proposal.cancelled, "Proposal cancelled");
        require(block.timestamp > proposal.endTime, "Voting still active");
        
        // Get proposal config
        ProposalConfig memory config = proposalConfigs[proposal.proposalType];
        
        // Check timelock (unless emergency by security council)
        if (proposal.proposalType != ProposalType.EMERGENCY || !securityCouncil[msg.sender]) {
            require(
                block.timestamp >= proposal.endTime + config.timelockPeriod,
                "Timelock active"
            );
        }
        
        // Check quorum
        uint256 totalVotes = proposal.forVotes + proposal.againstVotes + proposal.abstainVotes;
        uint256 totalSupply = token.totalSupply();
        uint256 quorumRequired = (totalSupply * config.quorumPercentage) / 100;
        
        require(totalVotes >= quorumRequired, "Quorum not met");
        
        // Check pass threshold (only counting for/against, not abstain)
        uint256 votesForDecision = proposal.forVotes + proposal.againstVotes;
        require(votesForDecision > 0, "No votes for decision");
        
        uint256 forPercentage = (proposal.forVotes * 100) / votesForDecision;
        require(forPercentage >= config.passThreshold, "Threshold not met");
        
        // Mark as executed
        proposal.executed = true;
        proposal.executionTime = block.timestamp;
        executedProposals++;
        
        // Execute the proposal
        bool success = false;
        
        if (proposal.callData.length > 0 && proposal.targetContract != address(0)) {
            (success, ) = proposal.targetContract.call(proposal.callData);
        } else {
            success = true; // For general proposals without call data
        }
        
        emit ProposalExecuted(proposalId, success);
    }
    
    /**
     * @dev Cancel a proposal (only proposer or security council)
     */
    function cancelProposal(uint256 proposalId) 
        external 
        proposalExists(proposalId) 
    {
        Proposal storage proposal = proposals[proposalId];
        
        require(!proposal.executed, "Already executed");
        require(!proposal.cancelled, "Already cancelled");
        require(
            msg.sender == proposal.proposer || securityCouncil[msg.sender] || msg.sender == owner(),
            "Not authorized"
        );
        
        proposal.cancelled = true;
        
        emit ProposalCancelled(proposalId, msg.sender);
    }
    
    // ============ View Functions ============
    
    /**
     * @dev Get proposal details
     */
    function getProposal(uint256 proposalId) 
        external 
        view 
        proposalExists(proposalId) 
        returns (Proposal memory) 
    {
        return proposals[proposalId];
    }
    
    /**
     * @dev Get proposal state
     */
    function getProposalState(uint256 proposalId) 
        external 
        view 
        proposalExists(proposalId) 
        returns (string memory) 
    {
        Proposal memory proposal = proposals[proposalId];
        
        if (proposal.cancelled) {
            return "Cancelled";
        }
        
        if (proposal.executed) {
            return "Executed";
        }
        
        if (block.timestamp < proposal.startTime) {
            return "Pending";
        }
        
        if (block.timestamp <= proposal.endTime) {
            return "Active";
        }
        
        // Check if can be executed
        ProposalConfig memory config = proposalConfigs[proposal.proposalType];
        uint256 totalVotes = proposal.forVotes + proposal.againstVotes + proposal.abstainVotes;
        uint256 totalSupply = token.totalSupply();
        uint256 quorumRequired = (totalSupply * config.quorumPercentage) / 100;
        
        if (totalVotes < quorumRequired) {
            return "Defeated (No Quorum)";
        }
        
        uint256 votesForDecision = proposal.forVotes + proposal.againstVotes;
        if (votesForDecision == 0) {
            return "Defeated (No Votes)";
        }
        
        uint256 forPercentage = (proposal.forVotes * 100) / votesForDecision;
        if (forPercentage < config.passThreshold) {
            return "Defeated";
        }
        
        if (block.timestamp < proposal.endTime + config.timelockPeriod) {
            return "Succeeded (Timelock)";
        }
        
        return "Succeeded (Ready)";
    }
    
    /**
     * @dev Get user's vote on a proposal
     */
    function getUserVote(uint256 proposalId, address user) 
        external 
        view 
        returns (
            bool voted,
            VoteChoice choice,
            uint256 votingPower
        ) 
    {
        voted = hasVoted[proposalId][user];
        choice = userVote[proposalId][user];
        votingPower = userVotingPower[proposalId][user];
    }
    
    /**
     * @dev Get all active proposals
     */
    function getActiveProposals() external view returns (uint256[] memory) {
        uint256 count = 0;
        
        // Count active proposals
        for (uint256 i = 1; i <= proposalCounter; i++) {
            if (
                !proposals[i].executed &&
                !proposals[i].cancelled &&
                block.timestamp >= proposals[i].startTime &&
                block.timestamp <= proposals[i].endTime
            ) {
                count++;
            }
        }
        
        // Create array
        uint256[] memory active = new uint256[](count);
        uint256 index = 0;
        
        for (uint256 i = 1; i <= proposalCounter; i++) {
            if (
                !proposals[i].executed &&
                !proposals[i].cancelled &&
                block.timestamp >= proposals[i].startTime &&
                block.timestamp <= proposals[i].endTime
            ) {
                active[index] = i;
                index++;
            }
        }
        
        return active;
    }
    
    /**
     * @dev Get governance statistics
     */
    function getGovernanceStats() 
        external 
        view 
        returns (
            uint256 totalProposals,
            uint256 executed,
            uint256 active,
            uint256 councilSize
        ) 
    {
        uint256 activeCount = 0;
        
        for (uint256 i = 1; i <= proposalCounter; i++) {
            if (
                !proposals[i].executed &&
                !proposals[i].cancelled &&
                block.timestamp >= proposals[i].startTime &&
                block.timestamp <= proposals[i].endTime
            ) {
                activeCount++;
            }
        }
        
        return (
            proposalCounter,
            executedProposals,
            activeCount,
            securityCouncilSize
        );
    }
    
    // ============ Admin Functions ============
    
    /**
     * @dev Update proposal threshold
     */
    function setProposalThreshold(uint256 _threshold) external onlyOwner {
        require(_threshold > 0, "Threshold must be > 0");
        PROPOSAL_THRESHOLD = _threshold;
    }
    
    /**
     * @dev Update proposal config
     */
    function updateProposalConfig(
        ProposalType proposalType,
        uint256 quorumPercentage,
        uint256 passThreshold,
        uint256 votingPeriod,
        uint256 timelockPeriod
    ) external onlyOwner {
        require(quorumPercentage <= 100, "Invalid quorum");
        require(passThreshold <= 100, "Invalid threshold");
        require(votingPeriod > 0, "Invalid voting period");
        
        proposalConfigs[proposalType] = ProposalConfig({
            quorumPercentage: quorumPercentage,
            passThreshold: passThreshold,
            votingPeriod: votingPeriod,
            timelockPeriod: timelockPeriod
        });
        
        emit ProposalConfigUpdated(proposalType, proposalConfigs[proposalType]);
    }
    
    /**
     * @dev Add/remove security council member
     */
    function updateSecurityCouncil(address member, bool status) external onlyOwner {
        require(member != address(0), "Invalid address");
        
        bool currentStatus = securityCouncil[member];
        
        if (status && !currentStatus) {
            securityCouncil[member] = true;
            securityCouncilSize++;
        } else if (!status && currentStatus) {
            securityCouncil[member] = false;
            securityCouncilSize--;
        }
        
        emit SecurityCouncilUpdated(member, status);
    }
    
    /**
     * @dev Pause/unpause governance
     */
    function setGovernanceStatus(bool _active) external onlySecurityCouncil {
        governanceActive = _active;
        emit GovernanceStatusChanged(_active);
    }
    
    /**
     * @dev Update treasury address
     */
    function setTreasuryAddress(address _treasury) external onlyOwner {
        require(_treasury != address(0), "Invalid address");
        treasuryAddress = _treasury;
    }
    
    // ============ Internal Functions ============
    
    /**
     * @dev Initialize default proposal configurations
     */
    function _initializeProposalConfigs() internal {
        // Parameter changes: 10% quorum, 51% pass, 7 days voting, 2 days timelock
        proposalConfigs[ProposalType.PARAMETER_CHANGE] = ProposalConfig({
            quorumPercentage: 10,
            passThreshold: 51,
            votingPeriod: 7 days,
            timelockPeriod: 2 days
        });
        
        // Treasury spending: 15% quorum, 66% pass, 7 days voting, 3 days timelock
        proposalConfigs[ProposalType.TREASURY_SPEND] = ProposalConfig({
            quorumPercentage: 15,
            passThreshold: 66,
            votingPeriod: 7 days,
            timelockPeriod: 3 days
        });
        
        // Contract upgrades: 20% quorum, 75% pass, 14 days voting, 7 days timelock
        proposalConfigs[ProposalType.CONTRACT_UPGRADE] = ProposalConfig({
            quorumPercentage: 20,
            passThreshold: 75,
            votingPeriod: 14 days,
            timelockPeriod: 7 days
        });
        
        // Emergency: 25% quorum, 80% pass, 3 days voting, 0 timelock
        proposalConfigs[ProposalType.EMERGENCY] = ProposalConfig({
            quorumPercentage: 25,
            passThreshold: 80,
            votingPeriod: 3 days,
            timelockPeriod: 0
        });
        
        // General: 10% quorum, 51% pass, 7 days voting, 1 day timelock
        proposalConfigs[ProposalType.GENERAL] = ProposalConfig({
            quorumPercentage: 10,
            passThreshold: 51,
            votingPeriod: 7 days,
            timelockPeriod: 1 days
        });
    }
}

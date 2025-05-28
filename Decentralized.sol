// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Project {
    // Structure to represent a candidate
    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
        bool exists;
    }
    
    // Structure to represent a voter
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 votedCandidateId;
    }
    
    // State variables
    address public owner;
    string public electionName;
    bool public votingActive;
    uint256 public totalCandidates;
    uint256 public totalVotes;
    
    // Mappings
    mapping(uint256 => Candidate) public candidates;
    mapping(address => Voter) public voters;
    
    // Events
    event CandidateRegistered(uint256 indexed candidateId, string name);
    event VoterRegistered(address indexed voter);
    event VoteCasted(address indexed voter, uint256 indexed candidateId);
    event VotingStatusChanged(bool status);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    modifier onlyDuringVoting() {
        require(votingActive, "Voting is not active");
        _;
    }
    
    modifier onlyRegisteredVoter() {
        require(voters[msg.sender].isRegistered, "You are not a registered voter");
        _;
    }
    
    // Constructor
    constructor(string memory _electionName) {
        owner = msg.sender;
        electionName = _electionName;
        votingActive = false;
        totalCandidates = 0;
        totalVotes = 0;
    }
    
    // Core Function 1: Register Candidate
    function registerCandidate(string memory _name) public onlyOwner {
        require(!votingActive, "Cannot register candidates during voting");
        require(bytes(_name).length > 0, "Candidate name cannot be empty");
        
        totalCandidates++;
        candidates[totalCandidates] = Candidate({
            id: totalCandidates,
            name: _name,
            voteCount: 0,
            exists: true
        });
        
        emit CandidateRegistered(totalCandidates, _name);
    }
    
    // Core Function 2: Register Voter
    function registerVoter(address _voter) public onlyOwner {
        require(!voters[_voter].isRegistered, "Voter already registered");
        require(_voter != address(0), "Invalid voter address");
        
        voters[_voter] = Voter({
            isRegistered: true,
            hasVoted: false,
            votedCandidateId: 0
        });
        
        emit VoterRegistered(_voter);
    }
    
    // Core Function 3: Cast Vote
    function castVote(uint256 _candidateId) public onlyDuringVoting onlyRegisteredVoter {
        require(!voters[msg.sender].hasVoted, "You have already voted");
        require(_candidateId > 0 && _candidateId <= totalCandidates, "Invalid candidate ID");
        require(candidates[_candidateId].exists, "Candidate does not exist");
        
        // Update voter status
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedCandidateId = _candidateId;
        
        // Update candidate vote count
        candidates[_candidateId].voteCount++;
        totalVotes++;
        
        emit VoteCasted(msg.sender, _candidateId);
    }
    
    // Additional utility functions
    function startVoting() public onlyOwner {
        require(!votingActive, "Voting is already active");
        require(totalCandidates > 0, "No candidates registered");
        
        votingActive = true;
        emit VotingStatusChanged(true);
    }
    
    function endVoting() public onlyOwner {
        require(votingActive, "Voting is not active");
        
        votingActive = false;
        emit VotingStatusChanged(false);
    }
    
    // View function to get candidate details
    function getCandidate(uint256 _candidateId) public view returns (
        uint256 id,
        string memory name,
        uint256 voteCount
    ) {
        require(_candidateId > 0 && _candidateId <= totalCandidates, "Invalid candidate ID");
        Candidate memory candidate = candidates[_candidateId];
        return (candidate.id, candidate.name, candidate.voteCount);
    }
    
    // View function to get voting results
    function getResults() public view returns (uint256[] memory, string[] memory, uint256[] memory) {
        uint256[] memory ids = new uint256[](totalCandidates);
        string[] memory names = new string[](totalCandidates);
        uint256[] memory voteCounts = new uint256[](totalCandidates);
        
        for (uint256 i = 1; i <= totalCandidates; i++) {
            ids[i-1] = candidates[i].id;
            names[i-1] = candidates[i].name;
            voteCounts[i-1] = candidates[i].voteCount;
        }
        
        return (ids, names, voteCounts);
    }
    
    // View function to check if address has voted
    function hasVoted(address _voter) public view returns (bool) {
        return voters[_voter].hasVoted;
    }
}

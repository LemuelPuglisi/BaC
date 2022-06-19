// SPDX-License-Identifier: None

pragma solidity ^0.8.0;

import "./specs.sol"; 

contract CorporateManagement is CorporateManagementSpecs {

    struct Associate {
        address payable useraddr;
        bool effective; 
        uint share;
    }

    struct Proposal {
        uint proposalId;
        ProposalCategory category;
        address proposer; 
        bool accepted; 
        address[] votes;
        string description; 
    }

    address payable owner; 
    uint minimumAssociatingShare; 
    bool public override isDissoluted = false; 

    address[] public associates; 
    mapping(address=>Associate) public associatesMap; 

    uint public proposalsCounter; 
    mapping(uint=>Proposal) public proposalsMap; 


    /**
    * This modifier requires that the value (amount of wei) in the message
    * is greater or equal to the minimum associating share (MAS).
    */
    modifier minshare() {
        require(msg.value >= minimumAssociatingShare, 
                "Share must be higher than the specified minimum.");
        _;
    }


    /**
    * This modifier grants that the caller is an effective associate.
    */
    modifier associated() {
        require(_isAssociated(msg.sender), "Must be an effective associate"); 
        _; 
    }


    /**
    * This modifier grants that the company is not dissoluted.
    */
    modifier activecompany() {
        require(!isDissoluted, "Company is dissoluted"); 
        _; 
    }


    /**
    * The owner must specify the minimum associating share (MAS), and also 
    * must deposit a number of wei greater of equal to the MAS. The creator 
    * of the contract is the owner of the contract and a valid associate. 
    */
    constructor(uint _minimumAssociatingShare) payable minshare {
        minimumAssociatingShare = _minimumAssociatingShare; 
        owner = payable(msg.sender); 
        _newAssociate(msg.sender, msg.value, true);
        emit AcceptedAssociate(owner);
    }


    /**
    * Given an address, a share and a flag "effective", the address is:
    * - candidate as an associate, if effective = false
    * - immediate associate, otherwise
    */
    function _newAssociate(address associateAddress, uint share, bool effective) internal minshare {
        associates.push(associateAddress);
        associatesMap[associateAddress] = Associate(
            payable(associateAddress), 
            effective, 
            share
        ); 
    }


    /**
    * This method can be called by:
    * - externals:  to propose theirself as associate
    * - associates: to increase their share value 
    * In the first case, the associate will be stored as a candidate
    * and a proposal will be created. 
    */
    function depositFunds() external payable activecompany override {
        // effective associates and candidates can deposit more
        // money, we don't use isAssociated here because it will
        // check if the associate is effective.
        if (associatesMap[msg.sender].useraddr != address(0)) {
            associatesMap[msg.sender].share += msg.value; 
            return; 
        }
        _newAssociate(msg.sender, msg.value, false); 
        uint proposalId = _depositProposal(ProposalCategory.NewAssociationAcceptance, ""); 
        emit NewAssociateCandidate(proposalId, msg.sender); 
    }


    /**
    * This method allow an effective associate to vote a proposal once.
    */
    function voteProposal(uint proposalId) external associated activecompany override {
        require(_proposalExists(proposalId), "Proposal doesn't exists"); 
        Proposal storage proposal = proposalsMap[proposalId]; 
        
        // Check if the associate already voted.
        for (uint i = 0; i < proposal.votes.length; i++) 
            require(proposal.votes[i] != msg.sender, "Associate already voted.");

        proposal.votes.push(msg.sender); 
        _checkProposalVotes(proposalId); 
    }


    /**
    * Allow an effective associate to submit a generic proposal.
    */
    function depositGenericProposal(string calldata description) external activecompany associated override{
        require(bytes(description).length > 0, "Description is empty"); 
        uint proposalId = _depositProposal(ProposalCategory.Generic, description); 
        emit NewGenericProposal(proposalId, description); 
    }

    
    /*
    * Allow an effective associate to submit a company dissolution proposal.
    */
    function depositDissolutionProposal() external associated activecompany override{
        uint proposalId = _depositProposal(ProposalCategory.CorporateDissolution, ""); 
        emit NewDissolutionProposal(proposalId); 
    }


    /*
    * In case of company dissolution, the associate can claim his share.
    */
    function requestShareRefunding() external override associated {
        require(isDissoluted, "Company is not dissoluted."); 
        require(associatesMap[msg.sender].share > 0, "No more shares to refund."); 
        Associate storage associate = associatesMap[msg.sender]; 
        associate.useraddr.transfer(associate.share); 
        associate.share = 0; 
    }


    /**
    * External method to check if an address is associated.
    */ 
    function isAssociated(address id) external view override returns (bool) {
        return _isAssociated(id); 
    }


    /**
    * Internal method to check if an address is associated.
    */ 
    function _isAssociated(address id) internal view returns (bool) {
        return associatesMap[id].effective;  
    }


    /**
    * Internal method to check if a proposal exists.
    */ 
    function _proposalExists(uint proposalId) internal view returns (bool) {
        return proposalsMap[proposalId].proposer != address(0); 
    }


    /**
    * This internal function deposit a generic proposal to the proposals array
    * and proposals map. 
    */
    function _depositProposal(ProposalCategory category, string memory description) internal returns(uint) {
        uint proposalId = proposalsCounter++;  
        proposalsMap[proposalId] = Proposal({
            proposalId: proposalId, 
            category: category, 
            proposer: msg.sender, 
            accepted: false, 
            votes: new address[](0),
            description: description
        }); 
        return proposalId; 
    }


    /**
    * Check if a proposal got enough votes to be accepted, and if so, 
    * perform the consequences of acceptance. 
    */
    function _checkProposalVotes(uint proposalId) internal {
        Proposal storage proposal = proposalsMap[proposalId];  
        uint companyCapital = _getCompanyCapital(); 
        
        uint proposalConsensusWeight = 0;
        for (uint i = 0; i < proposal.votes.length; i++) { 
            proposalConsensusWeight += associatesMap[proposal.votes[i]].share; 
        }

        // the corporate dissolution proposal requires unanimity.
        if (proposal.category == ProposalCategory.CorporateDissolution) {
            if (proposalConsensusWeight == companyCapital) {
                proposal.accepted = true;
                isDissoluted = true; 
                emit AcceptedCorporateDissolution(); 
            }
            return;             
        }

        // this will be a generic proposal or a new association proposal.
        // warning: multiply first to avoid truncation. 
        if (proposalConsensusWeight >= (companyCapital / 2) + 1) {
            proposal.accepted = true;
            if (proposal.category == ProposalCategory.NewAssociationAcceptance) {
                associatesMap[proposal.proposer].effective = true; 
                emit AcceptedAssociate(proposal.proposer); 
            }
            else if (proposal.category == ProposalCategory.Generic) {
                emit AcceptedGenericProposal(proposal.description);
            } 
        }
    }


    /*
    * Returns the company capital
    */
    function getCompanyCapital() external view returns(uint) {
        return _getCompanyCapital(); 
    }

    /*
    * Calculate the company capital as the sum of every associate
    * shares.
    */
    function _getCompanyCapital() internal view returns(uint) {
        uint companyCapital = 0; 
        for (uint i = 0; i < associates.length; i++) {
            if (!_isAssociated(associates[i])) continue; 
            companyCapital += associatesMap[associates[i]].share; 
        }
        return companyCapital; 
    }

}
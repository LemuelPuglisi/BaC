// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0; 

/*
Crowd fund
    User creates a campaign.
    Users can pledge, transferring their ether to a campaign.
    After the campaign ends, campaign creator can claim the funds if 
        total amount pledged is more than the campaign goal.
    Otherwise, campaign did not reach it's goal, users can withdraw their pledge.
*/

contract CrowdFund {

    struct Campaign {
        uint id; 
        address owner; 
        address payable receiver;
        string description; 
        uint goal; 
        uint pledged; 
        uint expiringTs; 
        mapping(address => uint) pledgers; 
    }    

    Campaign[] public campaigns;

    event NewCampaign(uint id, string description); 
    event NewPledge(uint campaignId, address pledger); 
    event CampaignSuccess(uint campaignId); 


    modifier campaignActive (uint campaignId) {
        require(campaignId <= campaigns.length, "Campaign doesn't exists.");
        require(block.timestamp < campaigns[campaignId].expiringTs, "Campaign is expired.");
        _; 
    }


    modifier campaignFailed (uint campaignId) {
        require(campaignId <= campaigns.length, "Campaign doesn't exists.");
        require(block.timestamp >= campaigns[campaignId].expiringTs, "Campaign is still active.");
        require(campaigns[campaignId].pledged < campaigns[campaignId].goal, "Goal reached."); 
        _; 
    }

    
    function createCampaign(
        address receiver, 
        uint goal, 
        string calldata description, 
        uint durationInSeconds
    ) external {
        Campaign storage nc = campaigns.push(); 
        nc.id = campaigns.length; 
        nc.owner = msg.sender; 
        nc.receiver = payable(receiver); 
        nc.description = description; 
        nc.goal = goal; 
        nc.pledged = 0; 
        nc.expiringTs = block.timestamp + durationInSeconds;  
        emit NewCampaign(nc.id, nc.description); 
    }


    function pledge(uint campaignId) external payable campaignActive(campaignId) {
        require(msg.value > 0, "A pledge requires a positive amount of wei.");
        Campaign storage campaign = campaigns[campaignId]; 
        campaign.pledged += msg.value;
        campaign.pledgers[msg.sender] += msg.value;
        emit NewPledge(campaign.id, msg.sender);  
        if (campaign.pledged >= campaign.goal) { 
            campaign.expiringTs = block.timestamp; // If called again it will be expired. 
            campaign.receiver.transfer(campaign.pledged); 
            emit CampaignSuccess(campaign.id); 
        } 
    }


    function refund(uint campaignId) external campaignFailed(campaignId) {
        Campaign storage campaign = campaigns[campaignId]; 
        require(campaign.pledgers[msg.sender] > 0, "User pledge to refund is zero.");
        payable(msg.sender).transfer(campaign.pledgers[msg.sender]); 
        campaign.pledgers[msg.sender] = 0; 
    }

}
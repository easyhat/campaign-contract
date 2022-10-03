// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

// errors
error Campaign_NotAMinimumContribution();

// 0xB20f2B24d5040770495b17007715efdDA5448554
contract CampainFactory {
    address[] public deployedCampaigns;

    // create a Campaign
    function createCampaign() public {
        address newCampaign = address(new Campaign(msg.sender));
        deployedCampaigns.push(newCampaign);
    }

    // get all deployed campaigns
    function getDeployedCampaigns() public view returns (address[] memory) {
        return deployedCampaigns;
    }
}

contract Campaign {
    struct Request {
        string description;
        uint256 value;
        address payable recipient;
        bool complete;
        uint256 approvalCount;
        mapping(address => bool) approvals;
    }

    Request[] public requests;
    address public manager;
    uint256 public immutable minimumContribution = 0.01 ether;
    mapping(address => bool) public approvers;
    uint256 public approversCount;
    // Event
    event contributeEvent(address indexed contributer, uint256 amount);
    // modifier for the owner
    modifier restricted() {
        require(msg.sender == manager, "Only Owner can call it!!");
        _;
    }

    constructor(address _manager) {
        manager = _manager;
    }

    function contribute() public payable {
        if (msg.value < minimumContribution) {
            revert Campaign_NotAMinimumContribution();
        }
        approvers[msg.sender] = true;
        approversCount++;
        // Emit event
        emit contributeEvent(msg.sender, msg.value);
    }

    function createRequest(
        string memory _description,
        uint256 _value,
        address payable _recipient
    ) public payable restricted {
        Request storage newRequest = requests.push();
        newRequest.description = _description;
        newRequest.value = _value;
        newRequest.recipient = _recipient;
        newRequest.complete = false;
        newRequest.approvalCount = 0;
    }

    function approveRequest(uint256 index) public payable {
        Request storage request = requests[index];
        require(!request.approvals[msg.sender]);
        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }

    function finalizeRequest(uint256 index) public restricted {
        Request storage request = requests[index];
        require(request.approvalCount > (approversCount / 2));
        require(!request.complete);
        request.recipient.transfer(request.value);
        request.complete = true;
    }

    function getSummary()
        public
        view
        returns (
            uint,
            uint,
            uint,
            uint,
            address
        )
    {
        return (
            minimumContribution,
            address(this).balance,
            requests.length,
            approversCount,
            manager
        );
    }

    function getRequestsCount() public view returns (uint) {
        return requests.length;
    }
}

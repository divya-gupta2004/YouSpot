// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface IENS {
    function resolver(bytes32 node) external view returns (address);
}

contract YouSpotDID is Ownable {
    struct User {
        string ensName;
        string metadataURI;
        bool exists;
    }

    mapping(address => User) private users;
    mapping(address => bool) private admins;

    IENS private ensRegistry;

    event UserRegistered(address indexed user, string ensName, string metadataURI);
    event MetadataUpdated(address indexed user, string newMetadataURI);
    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);

    constructor(address _ensRegistry) {
        ensRegistry = IENS(_ensRegistry);
        admins[msg.sender] = true; // Contract deployer is the first admin
    }

    modifier onlyAdmin() {
        require(admins[msg.sender], "Not an admin");
        _;
    }

    function registerUser(string memory _ensName, string memory _metadataURI) public {
        require(!users[msg.sender].exists, "User already registered");
        users[msg.sender] = User(_ensName, _metadataURI, true);
        emit UserRegistered(msg.sender, _ensName, _metadataURI);
    }

    function updateMetadata(string memory _newMetadataURI) public {
        require(users[msg.sender].exists, "User not registered");
        users[msg.sender].metadataURI = _newMetadataURI;
        emit MetadataUpdated(msg.sender, _newMetadataURI);
    }

    function getUser(address _user) public view returns (string memory, string memory) {
        require(users[_user].exists, "User not found");
        return (users[_user].ensName, users[_user].metadataURI);
    }

    function resolveENS(bytes32 node) public view returns (address) {
        return ensRegistry.resolver(node);
    }

    function addAdmin(address _admin) public onlyOwner {
        admins[_admin] = true;
        emit AdminAdded(_admin);
    }

    function removeAdmin(address _admin) public onlyOwner {
        admins[_admin] = false;
        emit AdminRemoved(_admin);
    }
}

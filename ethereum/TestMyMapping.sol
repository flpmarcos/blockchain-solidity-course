pragma solidity 0.7.0;

contract TestMyMapping {
	mapping(address => uint) public mappingOf;

	event MappingSet(address from, uint myNumber);

	function setMyMapping(uint myNumber) public {
		mappingOf[msg.sender] = myNumber;

		emit MappingSet(msg.sender, myNumber);
	}
}
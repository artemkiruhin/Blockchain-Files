// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "Competition/Tokens/IERC1155.sol";

contract ERC1155 is IERC1155 {
    mapping (address => mapping (uint => uint)) balances;
    
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value) override payable public  {
        require(balances[_from][_id] >= _value, "Error: not enough cash");
        require(_value > 0, "Error: value must be more than 0 to transer");
        require(_from != address(0), "Error: null address");
        require(_to != address(0), "Error: null address");
        _safeTransferFrom(_from, _to, _id, _value);
    }

    //function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) override  external { }

    function balanceOf(address _owner, uint256 _id) override external view returns (uint256) {
        return balances[_owner][_id];
    }

    function _safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value) internal {
        balances[_to][_id] += _value;
        balances[_from][_id] -= _value;
    }

    function _safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values)  internal {

    }
}
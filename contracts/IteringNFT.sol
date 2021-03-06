pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol";
import "@evolutionland/common/contracts/DSAuth.sol";
import "@evolutionland/common/contracts/StringUtil.sol";


contract IteringNFT is ERC721Token("Itering Objects","ITO"), DSAuth {
    using StringUtil for *;

    // https://docs.opensea.io/docs/2-adding-metadata
    string public baseTokenURI;

    function tokenURI(uint256 _tokenId) public view returns (string) {
        if (super.tokenURI(_tokenId).toSlice().empty()) {
            return baseTokenURI.toSlice().concat(StringUtil.uint2str(_tokenId).toSlice());
        }

        return super.tokenURI(_tokenId);
    }

    function setTokenURI(uint256 _tokenId, string _uri) public auth {
        _setTokenURI(_tokenId, _uri);
    }

    function setBaseTokenURI(string _newBaseTokenURI) public auth  {
        baseTokenURI = _newBaseTokenURI;
    }

    function mint(address _to, uint256 _tokenId) public auth {
        super._mint(_to, _tokenId);
    }

    function burn(address _to, uint256 _tokenId) public auth {
        super._burn(_to, _tokenId);
    }

    //@dev user invoke approveAndCall to create auction
    //@param _to - address of auction contractß
    function approveAndCall(
        address _to,
        uint _tokenId,
        bytes _extraData
    ) public {
        // set _to to the auction contract
        approve(_to, _tokenId);

        if(!_to.call(
                bytes4(keccak256("receiveApproval(address,uint256,bytes)")), abi.encode(msg.sender, _tokenId, _extraData)
                )) {
            revert();
        }
    }
}

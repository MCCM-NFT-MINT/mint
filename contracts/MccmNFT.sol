// SPDX-License-Identifier: MIT

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                    //
//                                                           %                                                        //
//                                                         %%%%                                                       //
//                                                        %%%%                                                        //
//                                                      %%%%%%              *                                         //
//                                                    %%%%%%%%          *%%%%%                                        //
//                                                  %%%%   %%%%%    %%%%%%%%%%                                        //
//                                                %%%%       %%%%%%%%%%=   %%%                                        //
//                                              %%%%                       %%%                                        //
//                                  %%%%%%%#  %%%%%                       :%%%                                        //
//                                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%          *%%%                                        //
//                                 =%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*    +%%%                                        //
//                                  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%=%%%%      .+:                               //
//                                #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*                             //
//                              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                             //
//                            %%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                             //
//                          %%%%%%%%%%        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                             //
//                         %%%%%%%%%%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                              //
//                       %%%%%%%%%%%      %  +%%%%%%%%%%%%%%%%%%%%%%%%.  #%%%%%%%%%%%%%%                              //
//                      %%%%%%%%%%%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%.       -%%%%%%%%%%%%                              //
//                     %%%%%%%%%%%%%      -%%%%%%%%%%%%%%%%%%%%%%%          %%%%%%%%%%%%-                             //
//                    %%%%%%%%%%%%%%         %%%%%%%%%%%%%%%%%%%%#     %%% %%%%%%%%%%%%%%                             //
//                   #%%%%%%%%%%%%%%*        %%%%%%%%%%%%%%%%%%%%     %%%%%%%%%%%%%%%%%%%%                            //
//                   %%%%%%%%%%%%%%%%%       %%%%%%%%%%%%%%%%%%%%       %%%%%%%%%%%%%%%%%%%                           //
//                  %%%%%%%%%%%%%%%%%%%%%*+%%%%%%%%%%%%%%%%%%%%%%#         %%%%%%%%%%%%%%%%%                          //
//                  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         -%%%%%%%%%%%%%%%%                          //
//                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#       %%%%%%%%%%%%%%%%%%                         //
//                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%   %%%   +%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                         //
//                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%.                        //
//                 %%%%%%%%%%%%%%%%%%%%%%  %%              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                        //
//                 %%%%%%%%%%%%%%%%%%%%%%                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                        //
//                 %%%%%%%%%%%%%%%%%%%%%%%+    +%%+   =              %%%%%%%%%%%%%%%%%%%%%%%%%                        //
//                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%              %%%%%%%%%%%%%%%%%%%%%%%%%                        //
//                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            #%%%%%%%%%%%%%%%%%%%%%%%%%                        //
//                  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%+        %%%%%%%%%%%%%%%%%%%%%%%%%%                         //
//                  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                         //
//                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%+                         //
//                   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                          //
//                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                           //
//                     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*                           //
//                      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                            //
//                       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                             //
//                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*                              //
//                          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                //
//                           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                 //
//                             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                   //
//                               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                     //
//                                 #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                       //
//                                  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                          //
//                                  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                          //
//                          %      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                          //
//                         %%%    =%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                         //
//                        %%%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%=  %%%%                                         //
//                        %%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        %                                         //
//                        %%%    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         %                                         //
//                         %%%  #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       *%%                                        //
//                         *%%%=%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  %% =      +%%                                        //
//                           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%             %%                                         //
//                             =%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     %%%%%%%%                                          //
//                                      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                              //
//                                                                                                                    //
//                                                                                                                    //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Contract based on https://docs.openzeppelin.com/contracts/3.x/erc721

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MccmNFT is ERC721Enumerable, Ownable, ReentrancyGuard {
    //using SafeMath for uint256;
    using Strings for uint256;

    bool public _isSaleActive = false; //是否開賣?

    // Constants
    uint256 public constant MAX_SUPPLY = 66; //能挖到的總數量
    uint256 public mintPrice = 0.003 ether;
    uint256 public maxMint = 20; //一次能挖的NFT數

    // Starting index for Minted
    //uint256 public mintedMutantsStartingIndex;

    string baseURI;
    //string public notRevealedUri;
    string public baseExtension = ".json";

    mapping(uint256 => string) private _tokenURIs;
    mapping(address => uint256) public addressMintMccmBalance;

    constructor() ERC721("Moom club", "MC") {}

    modifier callerIsUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

    function mintMccmMeta(uint256 tokenQuantity)
        public
        payable
        nonReentrant
        callerIsUser
    {
        require(totalSupply() + (tokenQuantity) <= MAX_SUPPLY, "Sold Out!");
        require(_isSaleActive, "Sale must be active to mint Mccm");
        require(
            tokenQuantity > 0 && tokenQuantity <= maxMint,
            "Exceeded the maximum purchase quantity"
        );
        require(
            mintPrice * (tokenQuantity) <= msg.value,
            "Not enough ether sent"
        );
        _mintMccmMeta(tokenQuantity);
    }

    function _mintMccmMeta(uint256 tokenQuantity) internal {
        for (uint256 i = 0; i < tokenQuantity; i++) {
            uint256 mintIndex = totalSupply();
            if (totalSupply() < MAX_SUPPLY) {
                addressMintMccmBalance[msg.sender]++;
                _safeMint(msg.sender, mintIndex);
            }
        }
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return
            string(abi.encodePacked(base, tokenId.toString(), baseExtension));
        //string(abi.encodePacked(baseTokenUri, String.toStringtokenId.toString(tokenId_), "json"));
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    //only owner
    function flipSaleActive() public onlyOwner {
        _isSaleActive = !_isSaleActive;
    }

    function setMintPrice(uint256 _mintPrice) public onlyOwner {
        mintPrice = _mintPrice;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    function setMaxMint(uint256 _maxMint) public onlyOwner {
        maxMint = _maxMint;
    }

    function withdraw(address to) public onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        payable(to).transfer(balance);
    }
}

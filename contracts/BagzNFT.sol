// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";
import { Base64 } from "./libraries/Base64.sol";

contract BagzNFT is ERC721URIStorage {
  event NewBagzNFTMinted(address sender, uint256 tokenId);
  event UpdatedTokenUri(address sender, uint256 tokenId);

  string[] private ALLOWED_ITEMS = ["Gem", "Gear", "Pickaxe", "Axe"];
  string[] private ALLOWED_ITEMS_ICON = [unicode"💎", unicode"⚙", unicode"⛏", unicode"🪓"];

  string[] private PINS = [unicode"😂", unicode"🍌", unicode"😎", unicode"😏", unicode"💰", unicode"🕹", unicode"🍕", unicode"💩", unicode"🐵", unicode"☣", unicode"💦", unicode"⚡", unicode"📈", unicode"🧀"];

  uint256 private constant NB_DIFFERENT_ITEMS_PER_INVENTORY = 5;
  BagzItemNFT private bagzItem;
  address private owner;

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  struct Bag {
    uint maxSlot;
    uint nbItemTypes;
    mapping(string => Item) items;
  }

  struct Item {
    string name;
    bool exists;
    uint256 quantity;
  }

  modifier onlyowner() {
    require(msg.sender == owner);
    _;
  }

  mapping(uint256 => Bag) public bags;
  mapping(address => uint256[]) public owners;

  constructor() ERC721 ("BagzNFT", "BAGZ") {
    _tokenIds.increment();
    owner = msg.sender;
  }

  function registerBagzItemContract(address bItemContract) public onlyowner {
    bagzItem = BagzItemNFT(bItemContract);
  }

  function mint() public {
    uint256 newTokenId = _tokenIds.current();
    _safeMint(msg.sender, newTokenId);
    bags[newTokenId].maxSlot = NB_DIFFERENT_ITEMS_PER_INVENTORY;
    console.log("An NFT w/ ID %s has been minted to %s", newTokenId, msg.sender);
    _tokenIds.increment();

    owners[msg.sender].push(newTokenId);

    emit NewBagzNFTMinted(msg.sender, newTokenId);
  }

  function addItem(uint256 tokenId, string memory name, uint256 quantity) public {
    Bag storage bag = bags[tokenId];
    if (!bag.items[name].exists) {
      require(bag.nbItemTypes < bag.maxSlot, "There are already 5 different types of items");
      bag.nbItemTypes += 1;
      bag.items[name].exists = true;
      bag.items[name].name = name;
      bag.items[name].quantity = 0;
    }
    bag.items[name].quantity += quantity;
    emit UpdatedTokenUri(msg.sender, tokenId);
  }

  function extractItem(uint256 tokenId, string memory name, uint256 quantity) public {
    uint qty = bags[tokenId].items[name].quantity;
    require(qty >= quantity, "Not enough items in the bag.");
    bags[tokenId].items[name].quantity -= quantity;
    bagzItem.mint(msg.sender, name, quantity);
  }

  function getNbItemTypesInBag(uint256 tokenId) view public returns (uint) {
    return bags[tokenId].nbItemTypes;
  }

  function showBag(uint256 tokenId, string[] memory listNames) public view {
    for (uint i=0; i < listNames.length; i++) {
      string memory name = listNames[i];
      console.log(string(abi.encodePacked(name, ": ", Strings.toString(bags[tokenId].items[name].quantity))));
    }
  }
  
  function getListEmojis(Bag storage bag) private view returns(string memory) {
    string[11] memory p;
    p[0] = "<g class='i' transform='translate(0 281)'><text x='40'>";
    p[1] = "";
    p[2] = "</text><text x='95'>";
    p[3] = "";
    p[4] = "</text><text x='150'>";
    p[5] = "";
    p[6] = "</text><text x='205'>";
    p[7] = "";
    p[8] = "</text><text x='260'>";
    p[9] = "";
    p[10] = "</text></g>";

    uint itemIndex = 1;
    for (uint i = 0; i < ALLOWED_ITEMS.length; ++i) {
      string memory itemName = ALLOWED_ITEMS[i];
      if (bag.items[itemName].quantity > 0) {
        p[itemIndex] = ALLOWED_ITEMS_ICON[i];
        itemIndex += 2;
      }
    }
    return string(abi.encodePacked(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9], p[10]));
  }

  function getListQuantity(Bag storage bag) private view returns (string memory) {
    string[11] memory p;
    p[0] = "<g class='q' transform='translate(0 288)'><text x='62'>";
    p[1] = "";
    p[2] = "</text><text x='117'>";
    p[3] = "";
    p[4] = "</text><text x='172'>";
    p[5] = "";
    p[6] = "</text><text x='227'>";
    p[7] = "";
    p[8] = "</text><text x='282'>";
    p[9] = "";
    p[10] = "</text></g>";

    uint itemIndex = 1;
    for (uint i = 0; i < ALLOWED_ITEMS.length; ++i) {
      string memory itemName = ALLOWED_ITEMS[i];
      if (bag.items[itemName].quantity > 0) {
        p[itemIndex] = Strings.toString(bag.items[itemName].quantity);
        itemIndex += 2;
      }
    }
    return string(abi.encodePacked(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9], p[10]));
  }

  function getSvg(Bag storage bag, uint tokenId) private view returns (string memory) {
    string[12] memory p;
    p[0] = "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 300 300'><style>.q text{font-size:12px;fill:#fff;font-weight:700;text-anchor:end;paint-order:stroke;stroke-width:3;stroke:#000}.i text{font-size:37px;text-anchor:middle}</style><path fill='#fff' d='M0 0h300v300H0z'/><text x='150' y='30' font-size='20' text-anchor='middle' style='font-weight:700'>Bagz #";
    p[1] = Strings.toString(tokenId);
    p[2] = "</text><text x='38' y='190' font-size='160'>";
    p[3] = unicode"🎒";
    p[4] = "</text><text x='147' y='110' rotate='20' font-size='30'>";
    p[5] = PINS[(((tokenId * tokenId * 16807) % 2147483647)) % PINS.length];
    p[6] = "</text><text x='110' y='140' rotate='-15' font-size='30'>";
    p[7] = PINS[((((tokenId * (tokenId + 1)) * 16807) % 2147483647)) % PINS.length];
    p[8] = "</text><path style='fill:beige;stroke-width:6;stroke:#7e3c10' d='M12 240h55v55H12zm55 0h55v55H67zm55 0h55v55h-55zm55 0h55v55h-55zm55 0h55v55h-55z'/>";
    p[9] = getListEmojis(bag);
    p[10] = getListQuantity(bag);
    p[11] = "</svg>";
    return string(abi.encodePacked(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9], p[10], p[11]));
  }

  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    Bag storage bag = bags[tokenId];
    uint i = 0;
    uint length = ALLOWED_ITEMS.length;
    string memory bagzContent = "";
    while (i < length) {
      string memory itemName = ALLOWED_ITEMS[i];
      uint itemQuantity = bag.items[itemName].quantity;
      if (itemQuantity > 0)
        bagzContent = string(abi.encodePacked(bagzContent, bytes(bagzContent).length == 0 ? '' : ', ', '{\\"', itemName, '\\": \\"', Strings.toString(itemQuantity), '\\"}'));
      ++i;
    }
    string memory svgData = getSvg(bag, tokenId);

    string memory json = Base64.encode(
      bytes(string(abi.encodePacked(
        '{"name": "Bagz #', Strings.toString(tokenId), '", ',
        '"description": "A unique Bagz", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(svgData)), '", ',
        '"attributes": [{"trait_type": "MaxSlot", "value": "', Strings.toString(bags[tokenId].maxSlot), '" },',
          '{"trait_type": "Content", "value": "[', bagzContent, ']" }]}'
    ))));
    return string(abi.encodePacked("data:application/json;base64,", json));
  }
}

contract BagzItemNFT is ERC721URIStorage {
  event NewBagzItemNFTMinted(address sender, uint256 tokenId);

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  address private bagzContract;

  mapping(address => uint256) public owners;

  modifier onlybagzcontract() {
    require(msg.sender == bagzContract);
    _;
  }

  constructor(address bContract) ERC721 ("BagzItemNFT", "BAGZITEM") {
    _tokenIds.increment();
    bagzContract = bContract;
    console.log("Registered Bagz Contract");
  }

  function mint(address receiver, string memory name, uint quantity) public onlybagzcontract {
    uint256 newTokenId = _tokenIds.current();
    _safeMint(receiver, newTokenId);
    string memory json = Base64.encode(
      bytes(string(abi.encodePacked(
        '{"name": "', name, ' x', Strings.toString(quantity), ' - BagzItem #', Strings.toString(newTokenId), '", ',
        '"description": "An item extracted from a Bagz", "image": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRKwNoEsBcNL00EMThV6wxccn23x70of0fTGJnpLRyooFSTqNiIWH-pbY-Gu3MwW607x-A&usqp=CAU", ',
        '"attributes": [{"trait_type": "Name", "value": "', name, '" }, {"trait_type": "Quantity", "value": "', Strings.toString(quantity), '" } ] }'
    ))));
    string memory finalTokenUri = string(abi.encodePacked("data:application/json;base64,", json));

    _setTokenURI(newTokenId, finalTokenUri);
    console.log("An NFT w/ ID %s has been minted to %s", newTokenId, receiver);
    _tokenIds.increment();

    emit NewBagzItemNFTMinted(receiver, newTokenId);
  }
}
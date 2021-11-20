// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

//import "hardhat/console.sol";

/**
 * @title NFT staking contract
 * @notice Implemements NFT staking with stake- period based rewards
 * @dev There is a single NFT stake interface that records the stake through ERC1155Holder interface
 *
 * @author blockchain-trainer
 **/

/**
A token interface for lodatoken and lodestar token

 */
interface AToken {
    
    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}
contract SoulLabStake is
    Initializable,
    PausableUpgradeable,
    OwnableUpgradeable,
    ERC1155Holder
{
    bytes4 public constant ERC1155_ERC165 = 0xd9b67a26; // ERC-165 identifier for the main token standard.
    bytes4 public constant ERC1155_ERC165_TOKENRECEIVER = 0x4e2312e0; // ERC-165 identifier for the `ERC1155TokenReceiver` support (i.e. `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)")) ^ bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`).
    bytes4 public constant ERC1155_ACCEPTED = 0xf23a6e61; // Return value from `onERC1155Received` call if a contract accepts receipt (i.e `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`).
    bytes4 public constant ERC1155_BATCH_ACCEPTED = 0xbc197c81; // Return value from `onERC1155BatchReceived` call if a contract accepts receipt (i.e `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`).
    address public  SOUL_LAB_TOKEN = 0x829BD824B016326A401d083B33D092293333A830;
    AToken soulLabFT = AToken(SOUL_LAB_TOKEN);
    struct Stake {
        uint256 amount;
        uint256 stakeStart;
    }

    mapping(address => Stake) stakes;

    function _stakeNft(address from) internal {
        stakes[from].amount++;
        //this is import, every subsequent stake re-starts the time - 
        //to avoid stakers from back loading the investment. 
        //This encourages people to put all their money early in one go
        stakes[from].stakeStart = block.timestamp;
    }

    function onERC1155Received(
        address, /*operator*/
        address from,
        uint256 id, //ignore the token Id, not needed for our case as we only care for number of NFTs staked.
        uint256, /*value*/
        bytes calldata /*data*/
    ) public virtual override returns (bytes4) {
        _stakeNft(from);
        return ERC1155_ACCEPTED;
    }

    function onERC1155BatchReceived(
        address, /*operator*/
        address from,
        uint256[] calldata ids,
        uint256[] calldata, /*values*/
        bytes calldata /*data*/
    ) public virtual override returns (bytes4) {
        for (uint256 i = 0; i < ids.length; ++i) {
            _stakeNft(from);
        }
        return ERC1155_BATCH_ACCEPTED;
    }

    function claim() external {
        require(stakes[msg.sender].amount > 0, "you dont have any staked nft");
        uint daysSpent =  (block.timestamp - stakes[msg.sender].stakeStart) / 60 / 60 / 24;
        uint earningFactor = 0;
        if (daysSpent < 30) {
            //return 5% earning - stake is less than a month old only
            earningFactor = 5;
        } else if (daysSpent < 180) {
           //return 10% earning - stake is less than a month old only
           earningFactor = 10;
        } else  {
             //return 15% earning - stake is less than a month old only
             earningFactor = 15;
        }
        //send back the calculated earnings + token. 
        soulLabFT.transferFrom(owner(), msg.sender, (stakes[msg.sender].amount * 15)/100 + stakes[msg.sender].amount);

    }

    function supportsInterface(bytes4 interfaceID)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceID == 0x01ffc9a7 || // ERC-165 support (i.e. `bytes4(keccak256('supportsInterface(bytes4)'))`).
            interfaceID == 0x4e2312e0; // ERC-1155 `ERC1155TokenReceiver` support (i.e. `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)")) ^ bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`).
    }
}

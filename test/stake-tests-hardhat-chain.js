const { expect } = require("chai");

//const { ethers } = require("hardhat"); - this is global - reduce your code!!
const MINT_AMNT = 1000000000;
const data = '0x12345678';

describe("SoulLab NFT - Staking Tests", function () {

  before(async function () {


  });

  it("Should accept the stakezz of NFT batch", async function () {
    const provider = waffle.provider;

    const [owner, user] = await ethers.getSigners();
    const balance0ETH = await provider.getBalance(owner.address);
    console.log("signer :" + owner.address + " balance : " + balance0ETH);

    const SoulLabFT = await ethers.getContractFactory("SoulLabFT");
    const soulLabFT = await SoulLabFT.deploy();
  
    
    console.log("owner  :" + await soulLabFT.owner())
    console.log("soulLabFT token deployed, owner balance " + await soulLabFT.balanceOf(owner.address));

    const SoulLabNFT = await ethers.getContractFactory("SoulLabNFT");
    const soulLabNFT = await SoulLabNFT.deploy();
    
   

    //minting soulabFTs
    console.log("minting SoulLabFT...");
    const tx1 = await soulLabFT.connect(owner).mint(owner.address, MINT_AMNT);
    await tx1.wait();
    console.log("owner minted SoulLabFT " + await soulLabFT.balanceOf(owner.address));

    const SoulLabStake = await ethers.getContractFactory("SoulLabStake");
    const soulLabStake = await SoulLabStake.deploy();
    console.log("soulLabStake deployed ");

    soulLabNFT.connect(owner).mint(soulLabStake.address, 1, 5, data);


  });


});

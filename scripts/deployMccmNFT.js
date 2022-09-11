//require("@nomiclabs/hardhat-ethers");
//require("@nomiclabs/hardhat-waffle");

const hre = require("hardhat");


async function main() {
  const MccmNFT = await hre.ethers.getContractFactory("MccmNFT");
  const mccmNFT = await MccmNFT.deploy();
  await mccmNFT.deployed();

  console.log("MccmNFT deployed to:", mccmNFT.address);
}
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

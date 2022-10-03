const hre = require('hardhat')
const { network } = require('hardhat')
async function main() {
  const campaignFactory = await hre.ethers.getContractFactory('CampainFactory')
  console.log('Deploying Contract, Please wait')
  const campaignCreator = await campaignFactory.deploy()
  await campaignCreator.deployed()
  console.log(`Contract deployed on ${campaignCreator.address}`)
  if (network.config.chainId === 5 && process.env.ETHERSCAN_API_KEY) {
    console.log('Waiting for block confirmations...')
    await campaignCreator.deployTransaction.wait(6)
    await verify(campaignCreator.address, [])
  }
}

async function verify(contractAddress: string, args: string[]) {
  console.log('Verifying contract...')
  try {
    await run('verify:verify', {
      address: contractAddress,
      constructorArguments: args,
    })
  } catch (err) {
    if (err.message.toLowerCase().includes('already verified')) {
      console.log('Already Verified')
    } else {
      console.error(err)
    }
  }
}

main().catch((error) => {
  console.error(error)
  process.exitCode = 1
})

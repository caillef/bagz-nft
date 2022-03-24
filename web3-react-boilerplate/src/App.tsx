import { useEffect, useState } from 'react'
import { ethers } from 'ethers'
import { Network } from '@ethersproject/networks'
import bagzNFT from './utils/BagzNFT.json'
import { Item } from './components/Item'
import { ConnectButton } from './components/ConnectButton'
import { MintButton } from './components/MintButton'
import { AddItemButton } from './components/AddItemButton'
import './App.css'

const LOCAL_NETWORK: Network = {
  name: 'localhost',
  chainId: 31337,
}
const LOCAL_NETWORK_URL = 'http://localhost:8545'

// eslint-disable-next-line @typescript-eslint/no-explicit-any
declare let window: any

interface Attribute {
  trait_type: string
  value: string
}

interface TokenMetadata {
  name: string
  image: string
  attributes: Attribute[]
}

// Constants
const BAGZ_ADDRESS = '0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512'
const ITEM_BUTTONS = [
  {
    name: 'Stone',
    quantity: 5,
  },
  {
    name: 'Stick',
    quantity: 2,
  },
  {
    name: 'Gear',
    quantity: 1,
  },
  {
    name: 'Diamond',
    quantity: 1,
  },
]

const App = () => {
  const [currentAccount, setCurrentAccount] = useState('')
  const [bagId, setBagId] = useState()
  const [statusText, setStatusText] = useState('No bag available.')
  const [tokenMetadata, setTokenMetadata] = useState({} as TokenMetadata)
  const [bagContent, setBagContent] = useState([])

  function getConnectedContract(): ethers.Contract {
    const { ethereum } = window

    if (!ethereum) {
      throw new Error("Ethereum object doesn't exist!")
    }
    const provider = new ethers.providers.StaticJsonRpcProvider(
      LOCAL_NETWORK_URL,
      LOCAL_NETWORK,
    )
    // const provider = new ethers.providers.Web3Provider(ethereum)
    const signer = provider.getSigner()
    return new ethers.Contract(BAGZ_ADDRESS, bagzNFT.abi, signer)
  }

  const setupEventListener = async () => {
    try {
      const connectedContract = getConnectedContract()
      connectedContract.on('NewBagzNFTMinted', async (from, tokenId) => {
        const tokenUri = await connectedContract.tokenURI(tokenId)
        const encodedContent = tokenUri.split(
          'data:application/json;base64,',
        )[1]
        const content = JSON.parse(
          Buffer.from(encodedContent, 'base64').toString(),
        )
        setTokenMetadata(content)
        setBagId(tokenId.toNumber())
        setStatusText('You are a Bagz owner!')
      })
      connectedContract.on('UpdatedTokenUri', async (from, tokenId) => {
        setStatusText('Gathering new items...')
        const tokenUri = await connectedContract.tokenURI(tokenId)
        const encodedContent = tokenUri.split(
          'data:application/json;base64,',
        )[1]
        const content = JSON.parse(
          Buffer.from(encodedContent, 'base64').toString(),
        )
        console.log(
          content.attributes.filter(
            (elem: Attribute) => elem.trait_type === 'Content',
          )[0].value,
        )
        setBagContent(
          JSON.parse(
            content.attributes.filter(
              (elem: Attribute) => elem.trait_type === 'Content',
            )[0].value,
          ),
        )
        setStatusText('')
      })
    } catch (error) {
      console.log(error)
    }
  }

  const checkIfWalletIsConnected = async () => {
    const { ethereum } = window

    if (!ethereum) {
      console.log('Make sure you have metamask!')
      return
    }
    const accounts = await ethereum.request({ method: 'eth_accounts' })
    if (accounts.length !== 0) {
      const account = accounts[0]
      setCurrentAccount(account)
      setupEventListener()
    } else {
      console.log('No authorized account found')
    }
  }

  const connectWallet = async () => {
    try {
      const { ethereum } = window
      if (!ethereum) {
        alert('Get MetaMask!')
        return
      }
      const accounts = await ethereum.request({ method: 'eth_requestAccounts' })
      setCurrentAccount(accounts[0])
      setupEventListener()
    } catch (error) {
      console.log(error)
    }
  }

  const mint = async () => {
    try {
      const connectedContract = getConnectedContract()
      const nftTxn = await connectedContract.mint()
      setStatusText('Minting...')
      await nftTxn.wait()
    } catch (error) {
      console.log(error)
    }
  }

  const addItem = async (name: string, quantity: number) => {
    try {
      const connectedContract = getConnectedContract()
      const nftTxn = await connectedContract.addItem(bagId, name, quantity)

      console.log(`Adding ${quantity} ${name + (quantity > 1 && 's')}`)
      setStatusText('Adding items...')
      await nftTxn.wait()
    } catch (error) {
      console.log(error)
    }
  }

  const ownerHasBagz = () => bagId

  useEffect(() => {
    checkIfWalletIsConnected()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  return (
    <div className="App">
      <div className="container">
        <div className="header-container">
          <p className="header">Bagz NFT</p>
          <p className="sub-text"> Each unique. Discover your NFT.</p>
          {currentAccount === '' ? (
            <ConnectButton onClick={connectWallet} />
          ) : (
            <div>
              <p>{statusText}</p>
              {!ownerHasBagz() ? (
                <MintButton onClick={mint} />
              ) : (
                <div>
                  <p>{tokenMetadata.name}</p>
                  <img
                    alt={tokenMetadata.name}
                    src={tokenMetadata.image}
                    width="300px"
                  />
                  <div className="additem-btn-grid">
                    {ITEM_BUTTONS.map(({ name, quantity }) => (
                      <AddItemButton
                        key={name}
                        name={name}
                        quantity={quantity}
                        onClick={() => addItem(name, quantity)}
                      />
                    ))}
                  </div>
                  <div className="item-grid">
                    {bagContent &&
                      bagContent.map((elem) => {
                        const name = Object.keys(elem)[0]
                        const quantity = parseInt(elem[name], 10)
                        return (
                          <Item key={name} name={name} quantity={quantity} />
                        )
                      })}
                    {bagContent &&
                      [...Array(12 - bagContent.length)].map((id) => (
                        <Item key={id} name="" quantity={0} />
                      ))}
                  </div>
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

export default App

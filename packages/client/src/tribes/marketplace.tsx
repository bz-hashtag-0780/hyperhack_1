import React, { useState, useEffect } from "react"
import { useNavigate } from "react-router-dom"
//@ts-ignore
import DappLib from "@decentology/dappstarter-dapplib"
import "./styles/Tribes.css"
import Nav from "./components/Nav"
import Footer from "./components/Footer"

import { ACCOUNT } from "./shared"
import { Z_STREAM_ERROR } from "zlib"

const MarketplacePage = (props: any) => {
  const [currentTribe, setCurrentTribe] = useState()
  const [showError, setShowError] = useState(false)
  const [error, setError] = useState(false)
  const navigate = useNavigate()

  //bz change
  const [allListingsID, setAllListingsID] = useState()
  const [balance, setBalance] = useState<any>()
  const [NFTid, setNFTid] = useState()

  const getCurrentListings = async () => {
    const data = {
      tenantOwner: ACCOUNT.Admin,
      account: ACCOUNT.Alice,
    }
    try {
      const allListingsID = await DappLib.MarketplaceGetIDs(data)
      setError(false)
      setAllListingsID(allListingsID.result)
    } catch (error) {
      setError(true)
    }
  }

  const getBalance = async () => {
    const data = {
      tenantOwner: ACCOUNT.Admin,
      account: ACCOUNT.Admin,
    }

    try {
      const balance = await DappLib.SimpleTokenGetBalance(data)
      setError(false)
      setBalance(balance.result)
    } catch (error) {setError(true)}
    
  }

  const purchase = async (NFTid:any) => {
    const data = {
      signer: ACCOUNT.Admin,
      tenantOwner: ACCOUNT.Admin,
      id: NFTid,
      marketplace: ACCOUNT.Alice,
    }

    try {
      const result = await DappLib.MarketplacePurchase(data)
      if (result) {
        getBalance()
        getCurrentListings()
      }
    } catch ( error ) {}
  }

  const onChangeHandler = async (e: any) => {
    const num = e.target.value
    console.log("num", num)
    setNFTid(num);
  }

  useEffect(() => {
    getCurrentListings()
    getBalance()
  }, [])

  return (
    <main>
      <Nav />
      <div className="hero">
        <div className="header">
          <button className="refresh" onClick={() => {    
            getCurrentListings();
            getBalance()
            }}>refresh</button>
          <br/>
          {/* <h1> Marketplace</h1> */}

          {Object.keys(allListingsID ?? {}).length === 0 ? (
          <>
            <h6>Currently no listings by Alice.</h6>
            
           <br/>
            <h6>Admin's Lunch Money: {parseFloat(balance).toFixed(2)}</h6>

           {console.log("No listing: " + allListingsID )}
          </>
        ) : 
        <>
         <h6>
           Listings by Alice
           <p/>
           {allListingsID != undefined ? Object.keys(allListingsID).map((key) => (
                <div key={allListingsID[key]}>
                  NFT ID: {allListingsID[key]}
                </div>
              )): ''}
           
           </h6> 
           <br/>
           <h6>Admin's Lunch Money: {parseFloat(balance).toFixed(2)}</h6>
           {console.log("Listings exist: " + allListingsID )}

           <br/>
           <input value={NFTid} placeholder={"0"} onChange={onChangeHandler}/>
           <button 
           className="join"
           onClick={()=>{purchase(NFTid)}}
           >Buy Listing</button>
        </>
      }

          {/* {!currentTribe ? (
            <button
              className="join"
              onClick={() => {
                error ? setShowError(true) : navigate("all-tribes")
              }}
            >
              {!error ? 'Join A Tribe' : 'Get Started'}

            </button>
          ) : (
            <button className="join" onClick={() => navigate("my-tribe")}>
              View Your Tribe
            </button>
          )} */}
          {showError && (
            <div className="error">
              <p>To Get Tribes running, you need to have an`instance` for the Admin account in the Tribes
                module. <a href="http://localhost:5000/playground/harness/core-tribes" target="_blank" rel="noreferrer">Enter playground to do this.</a>
              </p>
              <p>
                Need Help?
                <a href="https://docs-hyperhack.decentology.com/learn-with-examples" target="_blank" rel="noreferrer"> Watch the tutorial.</a>
              </p>
            </div>
          )}
        </div>
      </div>
      <Footer />
    </main>
  )
}

export default MarketplacePage

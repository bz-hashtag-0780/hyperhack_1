import React from "react"
import "./styles/App.css"
import { Routes, Route, matchRoutes } from "react-router-dom"
import MarketplacePage from "./marketplace"
import AllTribes from "./all-tribes"
import MyTribe from "./my-tribe"

function App() {
  return (
    <Routes>
      <Route path="/" element={<MarketplacePage />} />
      <Route path="/all-tribes" element={<AllTribes />} />
      <Route path="/my-tribe" element={<MyTribe />} />
    </Routes>
  )
}

export default App

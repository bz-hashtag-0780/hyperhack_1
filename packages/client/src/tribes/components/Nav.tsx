import "../styles/Tribes.css"
import { Link } from "react-router-dom"

const Nav = () => {

  return (
    <nav>
      <Link to=".." className="logo">
        Marketplace
      </Link>
      <a href="https://docs-hyperhack.decentology.com/learn-with-examples" target="_blank" rel="noreferrer" >About</a>
    </nav>
  )
}

export default Nav

import React, {useState} from 'react'
import LoginRegister from './LoginRegister'
import { useNavigate } from 'react-router-dom';
import { Link } from 'react-router-dom';

export default function Navbar({login, setLogin}) {

  const navigate = useNavigate();
  const handleLogo = () =>{
    navigate('/');
  }

  const navItemHandler =() =>{
    window.alert("Please Login or Register first!")
  }

  return (
    <>
    <nav className="navbar navbar-expand-lg navbar-light navbar ">
      <div className="container-fluid">
        <Link className="navbar-brand text-white" to="/">No Waste</Link>
        <button className="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation" onClick={handleLogo}>
          <span className="navbar-toggler-icon"></span>
        </button>
        <div className="collapse navbar-collapse" id="navbarSupportedContent">
          <ul className="navbar-nav me-auto mb-2 mb-lg-0">
            <li className="nav-item">
              <Link className="nav-link active text-white" aria-current="page" to="/">Home</Link>
            </li>
            <li className="nav-item">
              <a className="nav-link active text-white" aria-current="page" href="#problem">Problem</a>
            </li>
            <li className="nav-item">
              <a className="nav-link active text-white" aria-current="page" href="#solution">Solution</a>
            </li>
            <li className="nav-item dropdown">
              <a className="nav-link dropdown-toggle text-white" href="#" id="navbarDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                Deals
              </a>

              {
                login ? (
                      <ul className="dropdown-menu" aria-labelledby="navbarDropdown">
                        <li className='nav-item'><Link className="nav-link" to="/mydeals">My Deals</Link></li>
                        <li className='nav-item'><Link className="nav-link" to="/makedeal">Make a Deal</Link></li>
                        <li><hr className="dropdown-divider"/></li>
                        <li><a className="dropdown-item" href="#">Close</a></li>
                      </ul>                
                ):(
                    <ul className="dropdown-menu" aria-labelledby="navbarDropdown">
                      <li className='nav-item' onClick={navItemHandler}><Link className="nav-link" to="/">My Deals </Link></li>
                      <li className='nav-item' onClick={navItemHandler}><Link className="nav-link" to="/">Make a Deal </Link></li>
                      <li><hr className="dropdown-divider"/></li>
                      <li><a className="dropdown-item" href="#">Close</a></li>
                    </ul>
                )
              }
           </li>
          </ul>
            <LoginRegister login={login} setLogin={setLogin}/>
        </div>
      </div>
    </nav>
    </>
  )
}

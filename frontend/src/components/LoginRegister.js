import React from 'react'
import { useState } from 'react'
import { useNavigate } from 'react-router-dom';

export default function LoginRegister({login, setLogin}) {

  const navigate = useNavigate();
  const [selectedOption, setSelectedOption] = useState(''); // Default selected option
  const [modalState, setModalState] = useState("")

  const handleLogin = (e) => {
    e.preventDefault()
    // Backend Logic

    // After successful login, navigate to the home page
    setLogin(true)
    setModalState("modal")
    navigate('/');
  };

  const handleRegister =(e) =>{
    e.preventDefault()
    // Backed Logic

    // After successful login, navigate to the home page
    setLogin(true)
    navigate('/');
  }

  const handleLogout =() =>{
    // Backend Logic
    
    // After succesful logout, navigate to the home page
    setLogin(false)
    navigate('/')
  }


  const handleOptionChange = (event) => {
    setSelectedOption(event.target.value);
  };

  const handleSubmit = (event) => {
    event.preventDefault();

    if (selectedOption === 'Restraunt/ Shop') {
      console.log('Selected option: Restraunt Owner/ Retailer');
    } else if (selectedOption === 'NGO') {
      console.log('Selected option: NGO');
    }
  };

  const isButtonDisabled = !selectedOption; // Button is disabled if no option is selected

  return (

    <>
{/*---------------------------------1st Modal------------------------------------------------------------------------------------------*/}
    <div className="modal fade" id="exampleModalToggle" aria-hidden="true" aria-labelledby="exampleModalToggleLabel" tabindex="-1">
    <div className="modal-dialog modal-dialog-centered">
      <div className="modal-content">
        <div className="modal-header">
          <h5 className="modal-title" id="exampleModalToggleLabel">Login</h5>
          <button type="button" className="btn-close" data-bs-dismiss={"modal"} aria-label="Close"></button>
        </div>
        <div className="modal-body">
{/*---------------------------------login form------------------------------------------------------------------------------------------*/}
        <form>
              <div className="form-group">
                <label htmlFor="loginEmail">Email</label>
                <input type="email" className="form-control" id="loginEmail" placeholder="Email" />
              </div>
              <div className="form-group">
                <label htmlFor="loginPassword">Password</label>
                <input type="password" className="form-control" id="loginPassword" placeholder="Password" />
              </div>
              <div className="text-center"> 
                <button type="submit" className="btn custom-btn-color mt-2 custom-button-width" data-bs-dismiss={modalState} onClick={handleLogin}>Login</button>
              </div>
        </form>
        </div>
        <div className="modal-footer">
            <div className='container text-center'>
                <p>
                    New User?
                </p>
            </div>
            <div className='container text-center'>
                <button className="btn btn-success custom-button-width " data-bs-target="#exampleModalToggle2" data-bs-toggle="modal" data-bs-dismiss="modal">Register here</button>           
            </div>
        </div>
      </div>
    </div>
  </div>
{/*----------------------------------------------- 2nd Modal-------------------------------------------------------------------------- */}
  <div className="modal fade" id="exampleModalToggle2" aria-hidden="true" aria-labelledby="exampleModalToggleLabel2" tabindex="-1">
    <div className="modal-dialog modal-dialog-centered">
      <div className="modal-content">
        <div className="modal-header">
          <h5 className="modal-title" id="exampleModalToggleLabel2">Choose an Option</h5>
          <button type="button" className="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div className="modal-body">
{/*----------------------------------------------radio button---------------------------------------------------------------------------*/}
          <div class="form-check">
            <input class="form-check-input" type="radio" name="flexRadioDefault" id="restrauntOption" value="Restraunt/ Shop" checked={selectedOption === 'Restraunt/ Shop'} onChange={handleOptionChange} />
            <label class="form-check-label" for="flexRadioDefault1">
              Restraunt Owner/ Retailer
            </label>
          </div>
          <div className="form-check">
            <input className="form-check-input" type="radio" name="flexRadioDefault" id="ngoOption" value="NGO" checked={selectedOption === 'NGO'} onChange={handleOptionChange}/>
            <label className="form-check-label" for="flexRadioDefault2">
              NGO
            </label>
          </div>
        </div>
        <div className="modal-footer">
          <button className="btn btn-success ml-0" data-bs-target="#exampleModalToggle" data-bs-toggle="modal" data-bs-dismiss="modal">Back to Login</button>
          <button className="btn btn-success" data-bs-target="#exampleModalToggle3" data-bs-toggle="modal" data-bs-dismiss="modal" disabled={isButtonDisabled}>Next</button>
        </div>
      </div>
    </div>
  </div>
{/*----------------------------------------------- 3rd Modal----------------------------------------------------------------------- */}
  <div className="modal fade" id="exampleModalToggle3" aria-hidden="true" aria-labelledby="exampleModalToggleLabel3" tabindex="-1">
    <div className="modal-dialog modal-dialog-centered">
      <div className="modal-content">
        <div className="modal-header">
          <h5 className="modal-title" id="exampleModalToggleLabel3">Register [{selectedOption}]</h5>
          <button type="button" className="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>
        <div className="modal-body">
{/*-----------------------------------------------registration form---------------------------------------------------------------- */}
            <form>
              <div className="row">
                <div className="col">
                  <div className="form-group">
                    <label htmlFor="registerFirstName">First Name</label>
                    <input type="text" className="form-control" id="registerFirstName" placeholder="First Name" />
                  </div>
                </div>
                <div className="col">
                  <div className="form-group">
                    <label htmlFor="registerLastName">Last Name</label>
                    <input type="text" className="form-control" id="registerLastName" placeholder="Last Name" />
                  </div>
                </div>
              </div>
              <div className="form-group">
                <label htmlFor="registerShopName">{selectedOption} Name</label>
                <input type="text" className="form-control" id="registerShopName" placeholder="Shop Name"/>
              </div>
              <div className="form-group">
                <label htmlFor="registerShopAddress">{selectedOption} Address</label>
                <input type="text" className="form-control" id="registerShopAddress" placeholder="Address"/>
              </div>
              <div className="form-group">
                <label htmlFor="registerContact">Contact. no</label>
                <input type="tel" className="form-control" id="registerContact" placeholder="contact number" maxLength="10" pattern="[0-9]{10}" />
              </div>
              <div className="form-group">
                <label htmlFor="registerEmail">Email</label>
                <input type="email" className="form-control" id="registerEmail" placeholder="Email" />
              </div>
              <div className="form-group">
                <label htmlFor="registerPassword">Password</label>
                <input type="password" className="form-control" id="registerPassword" placeholder="Password" />
              </div>
              <div className="form-check mt-2">
                <input className="form-check-input" type="checkbox" value="" id="flexCheckDefault"/>
                <label className="form-check-label" for="flexCheckDefault">
                  I agree with terms and conditions.
                </label>
              </div>
              <div className='text-center'>
                <button type="submit" className="btn btn-success mt-4 custom-button-width"  data-bs-dismiss="modal" onClick={handleRegister}>Register</button>
              </div>           
            </form>
        </div>
        <div className="modal-footer">
          <div className='container text-center'>
           <button className="btn custom-btn-color ml-0 custom-button-width" data-bs-target="#exampleModalToggle" data-bs-toggle="modal" data-bs-dismiss="modal">Back to Login</button>
          </div>
        </div>   
      </div>
    </div>
  </div>
  {
    login ? (
      <>
        <h6 className='mb-2 mt-2 user-margin text-white'> User Name </h6>
        <a className="btn custom-btn-color" role="button" onClick={handleLogout}>Logout</a>
      </>
      
    ):(
      <a className="btn custom-btn-color" data-bs-toggle="modal" href="#exampleModalToggle" role="button">Login</a>
    )
  }
  
    
  </>
  )
}

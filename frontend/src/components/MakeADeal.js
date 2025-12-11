import React, {useState} from 'react'
import { useNavigate } from 'react-router-dom';

export default function MakeADeal() {

    const navigate = useNavigate()

    const[makeDeal, setMakeDeal] = useState(false)
    const[dealMatrics, setDealMatrix] = useState(false)
    const [showAlert, setShowAlert] = useState(false);
    

    const dealHandler =(e)=>{
        e.preventDefault();

        // Backend Logic

        // If deal successful.
        setMakeDeal(true)
        navigate('/confirmation')
    }

    const dealMetricsHandler=(e)=>{
        e.preventDefault();
        setDealMatrix(true)
        setShowAlert(true)
    }

    const handleCloseAlert = () => {
        setShowAlert(false);
      };


  return (
    <>
    {
        showAlert ? (
            <>           
             <div class="alert alert-warning alert-dismissible fade show" role="alert">
                <strong>Deal Matrics feature comeing soon!</strong> Stay Tuned.
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close" onClick={handleCloseAlert}></button>
            </div>       
            </>

        ):(
            ""
        )
    }
     <div className="container mt-4">
    <div className="row justify-content-center">
        <div className="col-md-6">
        <form>
        <h6>This section is only for restraunt and shop owners!</h6>
        <hr />
        <h4>Owner Details</h4>
        <div className="form-floating mb-3">
            <input type="text" className="form-control" id="floatingName" placeholder="shubham"/>
            <label for="floatingInput">Full Name</label>
        </div>
        <div className="form-floating mb-3">
            <input type="text" className="form-control" id="floatingAddress" placeholder="name@example.com"/>
            <label for="floatingInput">Restraunt/ Shop Name</label>
        </div>
        <div className="form-floating mb-3">
            <input type="text" className="form-control" id="floatingContact" placeholder="91234567890"/>
            <label for="floatingInput">Contact Number</label>
        </div>
        <hr />
        <h4>Food & Deal</h4>
        <h6>Food Quantity</h6>
        <div class="container">
            <div class="row">
                <div class="col-md-6">
                <div class="form-floating mb-3">
                    <input type="number" class="form-control" id="floatingfoodItemVeg" placeholder="0"/>
                    <label for="floatingfoodItemVeg">Quantity [Veg food packets]</label>
                </div>
                </div>
                <div class="col-md-6">
                <div class="form-floating mb-3">
                    <input type="number" class="form-control" id="floatingfoodItemNonVeg" placeholder="0"/>
                    <label for="floatingfoodItemNonVeg">Quantity [Non-Veg food packets]</label>
                </div>
                </div>
            </div>
        </div>
        <h6>   Food Price</h6>
        <div class="container">
            <div class="row">
                <div class="col-md-6">
                <div class="form-floating mb-3">
                    <input type="number" class="form-control" id="floatingfoodItemVeg" placeholder="0"/>
                    <label for="floatingfoodItemVeg">Price in Rs [1 Veg food packet]</label>
                </div>
                </div>
                <div class="col-md-6">
                <div class="form-floating mb-3">
                    <input type="number" class="form-control" id="floatingfoodItemNonVeg" placeholder="0"/>
                    <label for="floatingfoodItemNonVeg">Price in Rs [1 Non-Veg food packet]</label>
                </div>
                </div>
            </div>
        </div>
        <hr />
            <button className="btn custom-btn-color custom-left-margin-button1 custom-margin-bottom" onClick={dealMetricsHandler}>Deal Metrics</button>
            <button className="btn custom-btn-color custom-left-margin-button2 custom-margin-bottom" onClick={dealHandler}>Make Deal</button>
        </form>
        </div>
    </div>
    </div>

    </>
   
  )
}

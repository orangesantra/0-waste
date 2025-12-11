import React, {useState} from 'react'
import i3 from '../Assets/i3.jpg'
import Toast from './Toast';


export default function Home() {

    const[contactQueryData, setContactQueryData] = useState("")
    const[showToast, setShowToast] = useState(false)
 
    const onChangeHandler =(e) =>{
        setContactQueryData(e.target.value)
    }

    const onSubmitHandler = () =>{
       // Send the data to Backend

       // Toast componet
       setShowToast(true);
    }


  return (
    <>
    <divc id = "problem" className= 'section container text-center'>
        <div>
            <h1 className='kalam-font mt-2'>We Feed the peoples in need!</h1>
            <p className='display-4 fs-5 roboto-font custom-text-color'>NoWaste’s technology allows businesses to safely donate their excess food and access enhanced tax deductions.</p>
        </div> 
        <div className='container text-center'>
        <div id="carouselExampleCaptions" className="carousel slide custom-carousel mx-auto" data-bs-ride="carousel">
        <div className="carousel-indicators">
            <button type="button" data-bs-target="#carouselExampleCaptions" data-bs-slide-to="0" className="active" aria-current="true" aria-label="Slide 1"></button>
            <button type="button" data-bs-target="#carouselExampleCaptions" data-bs-slide-to="1" aria-label="Slide 2"></button>
            <button type="button" data-bs-target="#carouselExampleCaptions" data-bs-slide-to="2" aria-label="Slide 3"></button>
        </div>
        <div className="carousel-inner">
            <div className="carousel-item active carousel-item img">
            <img src={i3} className="d-block " alt="image1" />
            <div className="carousel-caption d-none d-md-block">
                <h5>First slide label</h5>
                <p>Some representative placeholder content for the first slide.</p>
            </div>
            </div>
            <div className="carousel-item carousel-item img">
            <img src={i3} className="d-block " alt="image2" />
            <div className="carousel-caption d-none d-md-block">
                <h5>Second slide label</h5>
                <p>Some representative placeholder content for the second slide.</p>
            </div>
            </div>
            <div className="carousel-item carousel-item img">
            <img src={i3} className="d-block " alt="image3" />
            <div className="carousel-caption d-none d-md-block">
                <h5>Third slide label</h5>
                <p>Some representative placeholder content for the third slide.</p>
            </div>
            </div>
        </div>
        <button className="carousel-control-prev" type="button" data-bs-target="#carouselExampleCaptions" data-bs-slide="prev">
            <span className="carousel-control-prev-icon" aria-hidden="true"></span>
            <span className="visually-hidden">Previous</span>
        </button>
        <button className="carousel-control-next" type="button" data-bs-target="#carouselExampleCaptions" data-bs-slide="next">
            <span className="carousel-control-next-icon" aria-hidden="true"></span>
            <span className="visually-hidden">Next</span>
        </button>
        </div>
        </div> 

    </divc>
    <hr />
    <div id = "solution" className='section container text-center custom-margin-top'>
        <h2>How does NoWaste's solution works?</h2>
        <div className="container custom-text-container">
        <p className='container display-3 fs-5 roboto-font mt-4 custom-text-color'>
        Food waste and hunger are inextricably linked issues, and NoWaste has developed the 
        solution to that addresses both. Restaurants, hotels, hospitals, corporate cafeterias, 
        and other businesses with food use our technology to deliver overproduced food items and reduce surplus 
        food wastage, while ensuring that excess food is used to its highest and best potential.
        </p>
    </div>   
    </div>
    <hr />
    <div className='row row justify-content-center custom-margin-top'>
        <div className="col-md-7">
        <div className="row row-cols-1 row-cols-md-2 g-0">
        <div className="col">
            <div className="card custom-card">
            <img src={i3} className="card-img-top" alt="..."/>
            <div className="card-body text-center">
                <h5 className="card-title text-center">1</h5>
                <p className="card-text roboto-font">Register on our platform.</p>
            </div>
            </div>
        </div>
        <div className="col">
            <div className="card custom-card">
            <img src={i3} className="card-img-top" alt="..."/>
            <div className="card-body text-center">
                <h5 className="card-title text-center">2</h5>
                <p className="card-text roboto-font">Inform us about your, leftout and remaining foods.</p>
            </div>
            </div>
        </div>
        <div className="col">
            <div className="card custom-card">
            <img src={i3} className="card-img-top" alt="..."/>
            <div className="card-body text-center">
                <h5 className="card-title text-center">3</h5>
                <p className="card-text roboto-font"> We pickup the foods and distribute to nearby NGOs and shelters.</p>
            </div>
            </div>
        </div>
        <div className="col">
            <div className="card custom-card">
            <img src={i3} className="card-img-top" alt="..."/>
            <div className="card-body text-center">
                <h5 className="card-title text-center">4</h5>
                <p className="card-text roboto-font">Save the tax, by our authenticated govenment funnels and track the food wastages.</p>
            </div>
            </div>
        </div>
        </div>
        </div>
    </div>
        <div className='container text-center custom-margin-top '>
            <h2 className='mt-20'>Why Choose us?</h2>
        </div>
        <div className='row row justify-content-center custom-margin-top'>
           <div className='col-md-9'>
             <div className="card mb-3">
                <div className="row g-0 mb-3">
                    <div className="col-md-4">
                    <img src={i3} className="img-fluid rounded-start h-100" alt="..."/>
                    </div>
                    <div className="col-md-8">
                    <div className="card-body">
                        <h5 className="card-title">Feed the Hunger</h5>
                        <p className="card-text">By parterning with us, you contribute in eradicating hunger.</p>
                    </div>
                    </div>
                </div>
                <div className="row g-0 mb-3">
                    <div className="col-md-4">
                    <img src={i3} className="img-fluid rounded-start h-100" alt="..."/>
                    </div>
                    <div className="col-md-8">
                    <div className="card-body">
                        <h5 className="card-title">Reliable Service</h5>
                        <p className="card-text">
                        We offers a best-in-class, professional pickup service that ensures 
                        your food is safely delivered to a nonprofit recipient.</p>
                    </div>
                    </div>
                </div>
                <div className="row g-0">
                    <div className="col-md-4">
                    <img src={i3} className="img-fluid rounded-start h-100" alt="..."/>
                    </div>
                    <div className="col-md-8">
                    <div className="card-body">
                        <h5 className="card-title">Access govenment verified tax deductions funnels.</h5>
                        <p className="card-text">
                            Our automated and audit-proof tax deduction service helps your business 
                            in unmatched financial savings.</p>
                    </div>
                    </div>
                </div>
             </div>
            </div>
        </div>
        <div id = "contactus" className='section container text-center custom-margin-top'>
            <h2>Any doubt? Contact us!</h2>
        </div>
        <div className='row row justify-content-center custom-margin-top-1'>
            <div className='col-md-4'>
            <form>
              <div className="form-group">
                <label htmlFor="contactName" className='roboto-font smaller-font'>Name</label>
                <input type="text" className="form-control" id="contactName" placeholder="Name" />
              </div>
              <div className="form-group">
                <label htmlFor="contactEmail" className='roboto-font smaller-font'>Email</label>
                <input type="email" className="form-control" id="contactEmal" placeholder="Email" />
              </div>
              <div className="form-group">
                <label htmlFor="contactPhone" className='roboto-font smaller-font'>Contact .no</label>
                <input type="number" className="form-control" id="contactPhone" placeholder="Phone" />
              </div>
              <div className="form-group">
                <label htmlFor="contactInfo" className='roboto-font smaller-font'>Enter your query below</label>
                <textarea name="textarea" id="contactQuery" cols="62" rows="5"></textarea>
              </div>
              <div className="text-center custom-margin-bottom"> 
                <button className="btn btn-success mt-2" value ={contactQueryData} onChange={onChangeHandler} onClick={onSubmitHandler}>Submit</button>
              </div>
            </form>
            </div>
        </div>

        {
            showToast? (
                <>
                {setShowToast(false)}
                <Toast />
                </>
            ):("") 
        }


    </>

        

  )
}

import React from 'react'
import { Link } from 'react-router-dom'

export default function ConfirmationPage() {
  return (
    <div>
        <div className="jumbotron text-center">
        <h1 className="display-3">Thank You for order!</h1>
        <p className="lead"><strong>Please check your email</strong> we will pickup your order soon.</p>
        <hr/>
        {/* <p>
            Having trouble? <a href="#contactus">Contact us</a>
        </p> */}
        <p className="lead">
            <Link className="btn btn-success btn-sm" to="/" role="button">Back to homepage</Link>
        </p>
        </div>

        <div className='container blank-height'>

        </div>
    </div>
  )
}

import React from 'react'

export default function Toast() {

  return (
    <div>
            <div aria-live="polite" aria-atomic="true" className="bg-dark position-relative bd-example-toasts">
            <div className="toast-container position-absolute p-3" id="toastPlacement">
                <div className="toast">
                <div className="toast-header">
                    <img src="..." className="rounded me-2" alt="..."/>
                    <strong className="me-auto">Success</strong>
                    <small>1 sec ago</small>
                </div>
                <div className="toast-body">
                    Your, query has been submited!
                </div>
                </div>
            </div>
            </div>
    </div>
  )
}

import React from 'react'

export default function MyDeals() {
  return (
    <>
      <div className="row justify-content-center">
        <div className="col-md-6">

        <table className="table table-hover">
            <thead>
                <tr>
                <th scope="col">#</th>
                <th scope="col">Dealer</th>
                <th scope="col">Time</th>
                <th scope="col">Food Packets</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                <th scope="row">1</th>
                <td>Mark</td>
                <td>14-Sep-2023</td>
                <td>100</td>
                </tr>
                <tr>
                <th scope="row">2</th>
                <td>Mark</td>
                <td>12-Sep-2023</td>
                <td>150</td>
                </tr>
                <tr>
                <th scope="row">3</th>
                <td>Mark</td>
                <td>11-Sep-2023</td>
                <td>130</td>
                </tr>
            </tbody>
       </table>
        </div>
    </div>

    <div className='container blank-height'>

    </div>
    </>
    
  )
}



//-------------------------------------------THIS COMPONENT NOT USED ANY WHERE IN THIS VERSION-----------------------------------------------------



// import React, {useState} from 'react'
// import MakeADeal from './MakeADeal';
// import MyDeals from './MyDeals';

// export default function Deal() {

//   const [deal, setDeal] = useState(null)

//   const headingStyle = {
//     color: 'green',
//     fontFamily: 'Roboto, sans-serif',
//     fontWeight: 'bold'
//   };

//   const handleMakeDeal = (e) => {
//     setDeal(e.target.value)
//   }

//   return (
//     <>
//     <div className='text-center mt-4 '>
//         <h1 className="text-success" style={headingStyle}>Deals</h1>
//         <div className="d-flex justify-content-center mt-3">
//           <button className="btn  custom-button-width custom-spacing custom-button-border" onClick={handleMakeDeal} value="mydeal"> My Deals </button>
//           <button className="btn  custom-button-width custom-button-border" onClick={handleMakeDeal}  value="makedeal"> Make a new Deal </button>
//         </div>
//     </div>

//     {(deal) ? (
//         (deal === 'mydeal')?(
//           <MyDeals/>
//         ):(
//           <MakeADeal/>
//         )
//       ):(
//         <div className='container text-center my-2'>
//           Select an option Above!
//         </div>
//       )
//     }
//     </>    
//   )
// }

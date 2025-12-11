import './App.css';
import Navbar from './components/Navbar';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Deal from './components/Deal';
import MyDeals from './components/MyDeals';
import MakeADeal from './components/MakeADeal';
import Home from './components/Home';
import { useState } from 'react';
import ConfirmationPage from './components/ConfirmationPage';


function App() {

  const[login, setLogin] = useState(false)

  return (
    <Router>
      <div>
        <Navbar login={login} setLogin={setLogin}/>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/mydeals" element={<MyDeals />} />
          <Route path="/makedeal" element={<MakeADeal />} />
          <Route path="/deal" element={<Deal/>} />
          <Route path='/confirmation' element={<ConfirmationPage/>} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;

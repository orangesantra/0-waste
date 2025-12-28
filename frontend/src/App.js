import './App.css';
import Navbar from './components/Navbar';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import MyDeals from './components/MyDeals';
import MakeADeal from './components/MakeADeal';
import Home from './components/Home';
import Dashboard from './components/Dashboard';
import ImpactNFTGallery from './components/ImpactNFTGallery';
import AvailableDeals from './components/AvailableDeals';
import TokenFaucet from './components/TokenFaucet';
import CertificateMarketplace from './components/CertificateMarketplace';
import About from './components/About';
import { Web3Provider } from './context/Web3Context';
import { ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';

function App() {
  return (
    <Web3Provider>
      <Router>
        <div className="App">
          <Navbar />
          <ToastContainer
            position="top-right"
            autoClose={5000}
            hideProgressBar={false}
            newestOnTop
            closeOnClick
            rtl={false}
            pauseOnFocusLoss
            draggable
            pauseOnHover
            theme="light"
          />
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/about" element={<About />} />
            <Route path="/dashboard" element={<Dashboard />} />
            <Route path="/mydeals" element={<MyDeals />} />
            <Route path="/makedeal" element={<MakeADeal />} />
            <Route path="/available" element={<AvailableDeals />} />
            <Route path="/nfts" element={<ImpactNFTGallery />} />
            <Route path="/marketplace" element={<CertificateMarketplace />} />
            <Route path="/faucet" element={<TokenFaucet />} />
          </Routes>
        </div>
      </Router>
    </Web3Provider>
  );
}

export default App;

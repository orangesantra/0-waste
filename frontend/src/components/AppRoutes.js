import React from 'react';
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';
import Deal from './Deal'; // Your "My Deals" and "Make a Deal" component
import TokenFaucet from './TokenFaucet';


function AppRoutes() {
  return (
    <Router>
      <Switch>
        <Route path="/deals" component={Deal} />
        <Route path="/faucet" component={TokenFaucet} />
        {/* Add more routes for other components as needed */}
      </Switch>
    </Router>
  );
}

export default AppRoutes;
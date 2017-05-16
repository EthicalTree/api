import React from 'react';
import ReactDOM from 'react-dom';
import { Route } from 'react-router';
import { BrowserRouter } from 'react-router-dom';
import App from './App.jsx';

// for hot reloading
if (module.hot) {
  module.hot.accept()
}


ReactDOM.render(
  <App />,
  document.getElementById('app')
);


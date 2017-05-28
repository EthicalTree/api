import React from 'react'
import { render } from 'react-dom'
import { AppContainer } from 'react-hot-loader'

import { Provider } from 'react-redux'
import configureStore from './store/configureStore'

import { createDevTools } from 'redux-devtools';
import LogMonitor from 'redux-devtools-log-monitor';
import DockMonitor from 'redux-devtools-dock-monitor';

import Root from './root/Root'

const store = configureStore(window.ET)

render(
  <AppContainer>
    <Root store={store}/>
  </AppContainer>,
  document.getElementById('app')
);

// for hot reloading
if (module.hot) {
  module.hot.accept('./root/Root', () => {
    const RootContainer = require('./root/Root').default
    render(
      <AppContainer>
        <RootContainer store={store} />
      </AppContainer>,
      document.getElementById('app')
    )
  })
}

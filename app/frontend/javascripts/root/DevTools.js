import React from 'react'
import { createDevTools  } from 'redux-devtools'

import SliderMonitor from 'redux-slider-monitor'
import LogMonitor from 'redux-devtools-log-monitor'
import DockMonitor from 'redux-devtools-dock-monitor'

export default createDevTools(
  <DockMonitor
    defaultIsVisible={false}
    defaultPosition="left"
    changeMonitorKey='ctrl-m'
    toggleVisibilityKey='ctrl-h'
    changePositionKey='ctrl-q'>
    <LogMonitor />
    <SliderMonitor />
  </DockMonitor>
)

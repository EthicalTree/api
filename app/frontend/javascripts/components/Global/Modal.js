import React from 'react'
import ReactModal from 'react-modal'

const baseStyles = {
  content: {
    position: 'absolute',
    border: '1px solid #ccc',
    background: '#fff',
    overflow: 'auto',
    WebkitOverflowScrolling: 'touch',
    borderRadius: '4px',
    outline: 'none',
    padding: '20px',
    top: '50%',
    left: '50%',
    right: 'auto',
    bottom: 'auto',
    marginRight: '-50%',
    transform: 'translate(-50%, -70%)'
  },
  overlay: {

  }
}

const Modal = (props) => {

  let { style } = props

  style = style || {}

  const newStyles = {
    content: {
      ...baseStyles.content,
      ...style.content
    },
    overlay: {
      ...baseStyles.overlay,
      ...style.overlay
    }
  }

  return (
    <ReactModal
      {...props}
      style={newStyles}
      className={`et-modal ${props.className}`}
      >

      <div className="modal-close-wrapper">
        <a href="#" className="modal-close" onClick={props.onRequestClose}>
          <i className="fa fa-times"></i>
        </a>
      </div>

      {props.children}
    </ReactModal>
  )
}

export default Modal

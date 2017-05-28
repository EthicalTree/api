import React from 'react'
import ReactModal from 'react-modal'

import {
  Container,
  Row,
  Col,
  Button
} from 'reactstrap'

import Loader from './Loader'

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
    top: '10%',
    left: '50%',
    right: 'auto',
    bottom: 'auto',
    marginRight: '-50%',
    transform: 'translateX(-50%)'
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
      shouldCloseOnOverlayClick={false}
      {...props}
      style={newStyles}
      className={`et-modal ${props.className}`}
      >

      <Loader loading={props.loading}>

        <div className="modal-close-wrapper">
          <a href="#" className="modal-close" onClick={props.onRequestClose}>
            <i className="fa fa-times"></i>
          </a>
        </div>

        {props.children}

      </Loader>
    </ReactModal>
  )
}

const ConfirmModal = (props) => {
  return (
    <Modal
      {...props}>

      <Container>
        <Row>
          <Col>
            <h5>{props.msg}</h5>
          </Col>
        </Row>

        <Row className="mt-4 text-center">
          <Col>
            <Button role="button" onClick={props.onRequestClose} className="">
              No
            </Button>

            <Button role="button" onClick={props.onConfirm} color="primary" className="ml-2">
              Yes
            </Button>
          </Col>
        </Row>
      </Container>
    </Modal>
  )
}

export {
  ConfirmModal
}

export default Modal


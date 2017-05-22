import React from 'react'
import { connect } from 'react-redux'
import { Modal } from '../Global'

import {
  Form,
  FormGroup,
  Label,
  Input,
  Button,
  Container,
  Row,
  Col,
  Alert
} from 'reactstrap'

const LoginModal = (props) => {
  const { dispatch } = props

  return (
    <Modal
      className="loginModal"
      contentLabel="Login"
      shouldCloseOnOverlayClick={true}
      onRequestClose={e => { dispatch({ type: 'CLOSE_LOGIN_MODAL' }) }}
      isOpen={props.session.isLoggingIn}>

      <Container>
        {props.session.loginError &&
          <Row>
            <Alert color="danger">
              {props.session.loginError}
            </Alert>
          </Row>
        }

        <Row>
          <Col>
            <Form action="/login" method="post">
              <FormGroup>
                <Label for="loginEmail">Email Address</Label>
                <Input type="email" name="email" id="loginEmail" placeholder="Enter email..."/>
              </FormGroup>

              <FormGroup>
                <Label for="loginPassword">Password</Label>
                <Input type="password" name="password" id="loginPassword" placeholder="Enter password..." />
              </FormGroup>

              <Button block color="primary" role="button">Login</Button>
            </Form>
          </Col>
        </Row>
      </Container>
    </Modal>
  )
}

const select = (state) => {
  return {
    session: state.session
  }
}

export default connect(select)(LoginModal)

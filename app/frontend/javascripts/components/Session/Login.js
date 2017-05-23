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

import { login } from '../../actions/session'

class LoginModal extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      email: '',
      password: ''
    }
  }

  submit(e) {
    const { dispatch } = this.props
    e.preventDefault();

    dispatch(login(this.state))
    this.setState({ password: '' })
  }

  render() {
    const { dispatch, session } = this.props

    return (
      <Modal
        className="loginModal"
        loading={session.loginLoading}
        contentLabel="Login"
        shouldCloseOnOverlayClick={false}
        onRequestClose={e => { dispatch({ type: 'SET_LOGIN_MODAL', data: false }) }}
        isOpen={session.isLoggingIn}>

        <Container>
          {session.loginError &&
            <Row>
              <Col>
                <Alert color="danger">
                  {session.loginError}
                </Alert>
              </Col>
            </Row>
          }

          <Row>
            <Col>
              <Form action="/login" method="post" onSubmit={this.submit.bind(this)}>
                <FormGroup>
                  <Label for="loginEmail">Email Address</Label>
                  <Input
                    autoFocus
                    value={this.state.email}
                    onChange={e => { this.setState({ email: e.target.value }) }}
                    type="email"
                    name="email"
                    id="loginEmail"
                    placeholder="Enter email..."/>
                </FormGroup>

                <FormGroup>
                  <Label for="loginPassword">Password</Label>
                  <Input
                    value={this.state.password}
                    onChange={e => { this.setState({ password: e.target.value }) }}
                    type="password"
                    name="password"
                    id="loginPassword"
                    placeholder="Enter password..." />
                </FormGroup>

                <Button block color="primary" role="button" type="submit">
                  Login
                </Button>
              </Form>
            </Col>
          </Row>
        </Container>
      </Modal>
    )
  }

}

const select = (state) => {
  return {
    session: state.session
  }
}

export default connect(select)(LoginModal)

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

import { signup } from '../../actions/session'

class SignupModal extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      email: '',
      password: '',
      confirmPassword: ''
    }

  }

  submit(e) {
    const { dispatch } = this.props
    e.preventDefault()

    dispatch(signup(this.state))
  }

  render() {
    const { dispatch, session } = this.props

    return (
      <Modal
        className="signup-modal small-modal"
        loading={session.signupLoading}
        contentLabel="Signup"
        onRequestClose={e => { dispatch({ type: 'SET_SIGNUP_MODAL', data: false }) }}
        isOpen={session.isSigningUp}>

        <Container>
          {session.signupErrors &&
            <Row>
              <Col>
                <Alert color="danger">
                  { session.signupErrors.map(err => {
                    return <span>{err}<br/></span>
                  })}
                </Alert>
              </Col>
            </Row>
          }

          <Row>
            <Col>
              <Form action="/signup" method="post" onSubmit={this.submit.bind(this)}>
                <FormGroup>
                  <Label for="signupEmail">Email Address</Label>
                  <Input
                    autoFocus
                    value={this.state.email}
                    onChange={e => { this.setState({ email: e.target.value }) }}
                    type="email"
                    name="email"
                    id="signupEmail"
                    placeholder="Enter email..."/>
                </FormGroup>

                <FormGroup>
                  <Label for="signupPassword">Password</Label>
                  <Input
                    value={this.state.password}
                    onChange={e => { this.setState({ password: e.target.value }) }}
                    type="password"
                    name="password"
                    id="signupPassword"
                    placeholder="Enter password..." />
                </FormGroup>

                <FormGroup>
                  <Label for="signupPasswordConfirm">Confirm Password</Label>
                  <Input
                    value={this.state.confirmPassword}
                    onChange={e => { this.setState({ confirmPassword: e.target.value }) }}
                    type="password"
                    name="confirmPassword"
                    id="signupConfirmPassword"
                    placeholder="Enter password again..." />
                </FormGroup>

                <FormGroup className="mt-4">
                  <Button block color="primary" role="button" type="submit">
                    Sign me up!
                  </Button>
                </FormGroup>
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

export default connect(select)(SignupModal)

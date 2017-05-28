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

import { verifyEmail } from '../../actions/session'

class VerifyEmailModal extends React.Component {

  constructor(props) {
    super(props)

    this.state = {
      token: ''
    }
  }

  submit(e) {
    const { dispatch } = this.props
    e.preventDefault()

    dispatch(verifyEmail(this.state))
  }

  render() {
    const { session } = this.props

    return (
      <Modal
        className="verify-email small-modal"
        loading={session.verifyEmailLoading}
        contentLabel="Verify Email"
        onRequestClose={e => { dispatch({ type: 'SET_VERIFY_EMAIL_MODAL', data: false }) }}
        isOpen={session.isVerifyingEmail}>

        <Container>
          {session.verifyEmailErrors &&
            <Row>
              <Col>
                <Alert color="danger">
                  { session.verifyEmailErrors.map(err => {
                    return <span>{err}<br/></span>
                  })}
                </Alert>
              </Col>
            </Row>
          }

          <Row>
            <Col>
              <p>
                Almost there! We sent a 6 digit token to your email address.
                Enter that token here to verify your account!
              </p>
            </Col>
          </Row>

          <Row>
            <Col>
              <Form action="/confirm_email" method="post" onSubmit={this.submit.bind(this)}>
                <FormGroup>
                  <Label for="verifyEmailToken">Token</Label>
                  <Input
                    value={this.state.token}
                    onChange={e => { this.setState({ token: e.target.value }) }}
                    type="text"
                    name="verifyEmailToken"
                    id="verifyEmailToken"
                    placeholder="- - - - - -" />
                </FormGroup>

                <FormGroup className="mt-4">
                  <Button block color="primary" role="button" type="submit">
                    Verify me, baby!
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

export default connect(select)(VerifyEmailModal)

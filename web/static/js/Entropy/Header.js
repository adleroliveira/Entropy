import { h, Component } from 'preact'
import Login from './Login'
import Register from './Register'

export default class Header extends Component {
  constructor() {
    super()
    this.state = {
      registerActive: false,
      loginActive: false,
      loading: false
    }
  }

  showLoginModal() {
    this.setState({loginActive: true})
  }

  showRegisterModal() {
    this.setState({registerActive: true})
  }

  hideLoginModal() {
    this.setState({loginActive: false})
  }

  hideRegisterModal() {
    this.setState({registerActive: false})
  }

  performLogin() {
    this.setState({loading: true})
  }

  performRegister() {
    this.setState({loading: true})
  }

  render(props, state) {
    console.log(state.loading)
    return (
      <header class="navbar">
        <Login
          active={state.loginActive}
          loading={state.loading}
          onSubmit={this.performLogin.bind(this)}
          hideLoginModal={this.hideLoginModal.bind(this)}
        />
        <Register
          active={state.registerActive}
          loading={state.loading}
          onSubmit={this.performRegister.bind(this)}
          hideLoginModal={this.hideRegisterModal.bind(this)}
        />
        <section class="navbar-section">
          <a href="#" class="btn btn-link">Entropy.io</a>
        </section>
        <section class="navbar-center">
        </section>
        <section class="navbar-section">
          <a
            href="#"
            class="btn btn-link"
            onClick={this.showLoginModal.bind(this)}
          >Login</a>
          <a
            href="#"
            class="btn btn-link"
            onClick={this.showRegisterModal.bind(this)}
          >Register</a>
        </section>
      </header>
    )
  }
}
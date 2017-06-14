import { h, Component } from 'preact'

export default class Header extends Component {
  render() {
    return (
      <header class="navbar">
        <section class="navbar-section">
          <a href="#" class="btn btn-link">Entropy.io</a>
        </section>
        <section class="navbar-center">
        </section>
        <section class="navbar-section">
          <a href="#" class="btn btn-link">Login</a>
        </section>
      </header>
    )
  }
}
import { h, Component } from 'preact'

export default class Empty extends Component {
  render() {
    return (
      <div class="empty">
        <div class="empty-icon">
          <i class="icon icon-people"></i>
        </div>
        <h4 class="empty-title">You don't have an account yet</h4>
        <p class="empty-subtitle">Click the button to create one</p>
        <div class="empty-action">
          <button class="btn btn-primary">Create Account</button>
        </div>
      </div>
    )
  }
}
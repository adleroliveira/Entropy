import { h, Component } from 'preact'

export default class Navigation extends Component {
  render() {
    return (
      <ul class="tab tab-block">
        <li class="tab-item active">
          <a href="#" class="badge" data-badge="9">
            Accounts
          </a>
        </li>
        <li class="tab-item">
          <a href="#">
            History
          </a>
        </li>
        <li class="tab-item">
          <a href="#">
            Bank
          </a>
        </li>
      </ul>
    )
  }
}
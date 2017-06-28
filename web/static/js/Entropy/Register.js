import { h, Component } from 'preact'

export default class Login extends Component {
  render(props, state) {
    const modalClass = props.active ? 'modal active' : 'modal'
    const registerButtonClass = props.loading ? 'btn btn-primary loading' : 'btn btn-primary'
    return (
      <div class={modalClass}>
        <div class="modal-overlay"></div>
        <div class="modal-container">
          <div class="modal-header">
            <button class="btn btn-clear float-right" onClick={props.hideLoginModal}></button>
            <div class="modal-title">Register</div>
          </div>
          <div class="modal-body">
            <div class="content modal-box">
              <form>
                <div class="form-group">
                  <label class="form-label" for="input-example-7">Name</label>
                  <input class="form-input" type="text" id="input-example-7" placeholder="Name" />
                </div>
                <div class="form-group">
                  <label class="form-label" for="input-example-7">Password</label>
                  <input class="form-input" type="password" id="input-example-7" placeholder="Password" />
                </div>
                <div class="form-group">
                  <label class="form-label" for="input-example-7">Confirm Password</label>
                  <input class="form-input" type="password" id="input-example-7" placeholder="Confirm Password" />
                </div>
              </form>
            </div>
          </div>
          <div class="modal-footer">
            <button class={registerButtonClass} onClick={props.onSubmit}>Submit</button>
          </div>
        </div>
      </div>
    )
  }
}

import { h, Component } from 'preact'

export default class Realtime extends Component {
  render() {
    return (
      <div class="columns">
        <div class="column col-md-6 col-xs-12">
          <ul class="menu">
            <li class="menu-item">
              <a href="#autocomplete">
                <div class="tile tile-centered">
                  <div class="tile-icon">
                    <img src="img/avatar-4.png" class="avatar avatar-sm" alt="Steve Rogers" />
                  </div>
                  <div class="tile-content">
                    <mark>S</mark>teve Roger<mark>s</mark>
                  </div>
                </div>
              </a>
            </li>
            <li class="menu-item">
              <a href="#autocomplete">
                <div class="tile tile-centered">
                  <div class="tile-icon">
                    <figure class="avatar avatar-sm" data-initial="TS" style="background-color: #5764c6;"></figure>
                  </div>
                  <div class="tile-content">
                    Tony <mark>S</mark>tark
                  </div>
                </div>
              </a>
            </li>
          </ul>
        </div>
        <div class="column col-md-6 col-xs-12">col-md-6<br />col-xs-12</div>
      </div>
    )
  }
}
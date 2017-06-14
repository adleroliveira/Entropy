import { h, Component } from 'preact'
import Header from './Header'
import Navigation from './Navigation'
import Empty from './Empty'
import Realtime from './Realtime'

export default class Entropy extends Component {
  render() {
    return(
      <div>
        <Header />
        <Realtime />
        <Navigation />
        <Empty />
      </div>
    )
  }
}
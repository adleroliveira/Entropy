import "phoenix_html"
import socket from "./socket"
import {h, render} from 'preact'
import Entropy from './Entropy'

render(<Entropy />, document.querySelector('#app'))

import axios from 'axios'
import createAxios from './createAxios'
import http from './http'
import { cancel } from './exCancel'
const { isCancel } = axios

export { axios, createAxios, http, cancel, isCancel }
export default http

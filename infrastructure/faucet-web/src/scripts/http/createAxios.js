

import _ from 'lodash'
import axios from 'axios'
import mergeConfig from 'axios/lib/core/mergeConfig'
import { qsStringify } from '@/scripts/utils'
import wrapAxios from './wrapAxios'
import exShowLoading from './exShowLoading'
import * as exCancel from './exCancel'

/**
 * @param {Parameters<axios['create']>[0]} config
 */
const requestHandle = config => {
  exCancel.setConfig(config)
  return config
}

const requestErrHandle = err => {
  throw err
}

/**
 * @param {import('axios').AxiosResponse} res
 */
const responseHandle = res => {
  res.exData = _.get(res.data, 'data')
  return res
}

const responseErrHandle = err => {
  if (err.response) {
    err.response.exData = _.get(err.response.data, 'data')
  }
  if (!err.response || !_.isPlainObject(err.response.data)) {
    if (!_.get(err.config, 'exNoErrorMassage') && !axios.isCancel(err)) {
      window.console.error(err.message) 
    }
  }
  throw err
}

/**
 * @param {Parameters<axios['create']>[0]} requestConfig
 * @param {(instance: ReturnType<axios['create']>) => any} [callback]
 */
export const createAxios = (requestConfig, callback) => {
  const defaults = {
    /* default config */
    paramsSerializer: params => qsStringify(params, { arrayFormat: 'comma' }),
  }
  const instance = wrapAxios(axios.create(mergeConfig(defaults, requestConfig)))
  instance.exHooks.add(exShowLoading)
  instance.exHooks.add(exCancel.hooks)
  instance.interceptors.request.use(requestHandle, requestErrHandle)
  instance.interceptors.response.use(responseHandle, responseErrHandle)
  callback && callback(instance)
  return instance
}

export default createAxios

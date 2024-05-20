

import _ from 'lodash'
import createAxios from './createAxios'

/**
 * @param {Parameters<createAxios>[0]} config
 */
const requestHandle = config => {
  return config
}

const requestErrHandle = err => {
  throw err
}

/**
 * @param {import('axios').AxiosResponse} res
 */
const responseHandle = res => {
  const { code, msg } = res.data || {}
  // 200 success
  if (
    code === 1 || 
    /^(arraybuffer|blob|stream)$/.test(_.get(res.request, 'responseType'))
  ) {
    return res
  }
  // 200 failure
  else {
    let message = `${msg || 'error'}`
    if (code) {
      message = `${code} :: ${message}`
    }
    if (!res.config.exNoErrorMassage) {
      window.console.error(message) 
    }
    const err = new Error(message)
    err['exRes'] = res
    throw err
  }
}

const responseErrHandle = err => {
  if (err.response && _.isPlainObject(err.response.data)) {
    if (!_.get(err.config, 'exNoErrorMassage')) {
      const code = _.get(err.response.data, 'code')
      let message = _.get(err.response.data, 'msg') || 'system error'
      if (code) {
        message = `${code} :: ${message}`
      }
      window.console.error(message) 
    }
  }
  throw err
}

export const http = createAxios(
  {
    baseURL:
      process.env.VUE_APP_ENV === 'stage'
        ? localStorage.baseurl_api || process.env.VUE_APP_BASEURL_API
        : process.env.VUE_APP_BASEURL_API,
    headers: {'token': '6LF8pdT3BlbkFJFJkUgwUz',"Authorization": "Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ik1UaEVOVUpHTkVNMVFURTRNMEZCTWpkQ05UZzVNRFUxUlRVd1FVSkRNRU13UmtGRVFrRXpSZyJ9.eyJodHRwczovL2FwaS5vcGVuYWkuY29tL2F1dGgiOnsidXNlcl9pZCI6InVzZXItV1dqZnFCUUsxVlJVNzdzekVSSGdjMEdaIn0sImlzcyI6Imh0dHBzOi8vYXV0aDAub3BlbmFpLmNvbS8iLCJzdWIiOiJnb29nbGUtb2F1dGgyfDEwNTYxNDc0MTg0OTA4NDE0ODM4OSIsImF1ZCI6WyJodHRwczovL2FwaS5vcGVuYWkuY29tL3YxIiwiaHR0cHM6Ly9vcGVuYWkuYXV0aDAuY29tL3VzZXJpbmZvIl0sImlhdCI6MTY3MDMwNjY5NywiZXhwIjoxNjcwMzkzMDk3LCJhenAiOiJUZEpJY2JlMTZXb1RIdE45NW55eXdoNUU0eU9vNkl0RyIsInNjb3BlIjoib3BlbmlkIGVtYWlsIHByb2ZpbGUgbW9kZWwucmVhZCBtb2RlbC5yZXF1ZXN0IG9yZ2FuaXphdGlvbi5yZWFkIG9mZmxpbmVfYWNjZXNzIn0.Ae_BE4u9arn1Fnpk48L9k_Q3mtRAqRbaf--jMmmP9rk3YJYppt6S01EgV9Pr9gKiapKoEK469rUyA2hpa7LdnnXyevnr34hF_V2xBdpdmFK3BEDmDid7omCDsYx-hDenLRKab9h4OPEM5JE4KoH6ZcXMATH4Bc0Sm6gz-h4CgIULlxB2f134BYsYbNZ3rixuo8Jp_PeXI88kzJ_rimxDQHrDcgTI-8w7bk2ujiyblvlTBSksfK614dhYeg1tYCqJbiXO9fX3K4EFBBN8Wrenpf0rCOWE0k93PCwuypRa6KJifqSq1P33oIzRCZwtsw_pOG6E0SwVI2CCnhKqgeBBjw",}
  },
  instance => {
    instance.interceptors.request.use(requestHandle, requestErrHandle)
    instance.interceptors.response.use(responseHandle, responseErrHandle)
  },
)

export default http

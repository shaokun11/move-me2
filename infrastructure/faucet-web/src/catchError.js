import Vue from 'vue'
import axios from 'axios'

/**
 * error
 */

const isError = err => err instanceof Error
const isSystemError = function(err) {
  if (!isError(err)) return false
  const reg = /^(TypeError|SyntaxError|ReferenceError|URIError|EvalError|RangeError)$/
  return reg.test(err.name)
}

/*  Promise */
window.addEventListener('unhandledrejection', function(event) {
  const { reason } = event
  if (!isSystemError(reason)) {
    if (
      process.env.VUE_APP_ENV === 'prod' ||
      (isError(reason) && reason.isAxiosError) ||
      axios.isCancel(reason)
    ) {
      event.preventDefault() 
    }
  }
})

Vue.config.errorHandler = function(err, vm, info) {
  if (info.includes('Promise/async')) {
    Promise.reject(err) 
    return
  }
  window.console.error(err)
}

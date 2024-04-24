import _ from 'lodash'
import axios from 'axios'
import stringify from 'qs/lib/stringify'
import dateFns_format from 'date-fns/format'
import download from './download'

export {
  download, 
}

/**
 * @param {object[]} list
 * @param {string} [valueKey]
 * @param {string} [labelKey]
 * @returns {object}
 */
export const listToMap = function(list, valueKey, labelKey) {
  valueKey = valueKey || 'value'
  labelKey = labelKey || 'label'
  const map = {}
  _.each(list, item => {
    map[item[valueKey]] = item[labelKey]
  })
  return map
}


export const dateFormat = function(date, format = 'YYYY-MM-DD') {
  if (!date) return ''
  if (format === '@iso') format = 'YYYY-MM-DDTHH:mm:ss.SSSZ'
  return dateFns_format(date, format)
}

/**
 * @param {object} data
 * @param {Parameters<qs.stringify>[1]} [options]
 */
export const qsStringify = function(data, options) {
  options = { arrayFormat: 'repeat', ...options }
  return stringify(data, options)
}

/**
 * @typedef {string | number | boolean | File | Blob} Val
 * @param {{[key: string]: Val | Val[]}} data
 * @param {'repeat' | 'brackets' | 'indices'} [arrayFormat]
 */
export const toFormData = function(data, arrayFormat = 'repeat') {
  if (data instanceof FormData) return data
  const formData = new FormData()
  _.each(data, (val, key) => {
    if (val === undefined) return
    if (Array.isArray(val)) {
      val = val.filter(v => v !== undefined)
      val.forEach((v, i) => {
        let k = key
        if (arrayFormat === 'brackets') k += '[]'
        else if (arrayFormat === 'indices') k += `[${i}]`
        formData.append(k, v === null ? '' : v)
      })
    } else {
      formData.append(key, val === null ? '' : val)
    }
  })
  return formData
}

/**
 */
export const isCancel = axios.isCancel

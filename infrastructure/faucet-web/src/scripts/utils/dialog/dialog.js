/* @PC.element-ui */

import _ from 'lodash'
import Vue from 'vue'
import { Dialog } from 'element-ui'
import root from '@/main'
const DialogConstructor = Vue.extend(Dialog)

/**
 * @typedef {import('vue').VNode} VNode
 * @param {object} props
 * @param {VNode | string | number} [props.title]
 * @param {VNode | string | number} [props.main]
 * @param {VNode | string | number} [props.footer]
 * @param {Function} [props.onOpen]
 * @param {Function} [props.onOpened]
 * @param {Function} [props.onClose]
 * @param {Function} [props.onClosed]
 * @returns {Function}
 * @example
 */
export default function dialog(props) {
  if (!root) {
    let close = _.noop
    Vue.nextTick(() => {
      close = dialog.apply(this, arguments)
    })
    return () => close()
  }

  const { title, main, footer, ...rest } = props
  const { onOpen, onOpened, onClose, onClosed, ...attrs } = rest
  const propsData = {
    ...attrs,
    visible: false, 
    destroyOnClose: false, 
    appendToBody: false,
    modalAppendToBody: true,
  }
  let instance = new DialogConstructor({
    propsData,
    parent: root, 
  })

  _.isFunction(onOpen) && instance.$on('open', onOpen)
  _.isFunction(onOpened) && instance.$on('opened', onOpened)
  _.isFunction(onClose) && instance.$on('close', onClose)
  _.isFunction(onClosed) && instance.$on('closed', onClosed)

  instance.$on('update:visible', visible => {
    setProps(instance, { visible })
  })
  instance.$on('closed', () => {
    instance.$destroy()
    if (document.body.contains(instance.$el)) {
      document.body.removeChild(instance.$el)
    }
    instance = null
  })

  instance.$slots.title = title
  instance.$slots.default = main
  instance.$slots.footer = footer

  instance.$mount()
  document.body.appendChild(instance.$el)
  setProps(instance, { visible: true })

  return () => {
    if (instance) {
      setProps(instance, { visible: false })
    }
  }
}

const setProps = function(ins, props) {
  const oldSilent = Vue.config.silent
  Vue.config.silent = true
  _.each(props, (val, key) => {
    ins.$props[key] = val
  })
  Vue.config.silent = oldSilent
}

Object.defineProperty(dialog, 'h', {
  value: new Vue().$createElement,
  enumerable: true,
})

/* @PC.element-ui */

import _ from 'lodash'
import Vue from 'vue'
import root from '@/main'

/**
 * @param {import('vue').VNode} vNode
 * @returns {Function}
 * @example
   const h = dialogWrap.h 
   dialogWrap(<CreateOrEdit props={props} />) 
   // or
   const close = dialogWrap(<CreateOrEdit props={{ ...props, close: () => close() }} />) 
 */
export default function dialogWrap(vNode) {
  if (!root) {
    let close = _.noop
    Vue.nextTick(() => {
      close = dialogWrap.apply(this, arguments)
    })
    return () => close()
  }

  const instance = new Vue({
    parent: root, 
    render: () => vNode,
  }).$mount()
  let dialogInstance = findDialogInstance(instance.$children)
  if (!dialogInstance) {
    instance.$destroy()
    return _.noop
  }

  dialogInstance.$on('update:visible', visible => {
    setProps(dialogInstance, { visible })
  })
  dialogInstance.$on('closed', () => {
    instance.$destroy()
    if (document.body.contains(instance.$el)) {
      document.body.removeChild(instance.$el)
    }
    dialogInstance = null
  })

  document.body.appendChild(instance.$el)
  Object.defineProperties(dialogInstance, {
    destroyOnClose: {
      get: () => false, 
      enumerable: true,
    },
    appendToBody: {
      get: () => true, 
      enumerable: true,
    },
    modalAppendToBody: {
      get: () => true, 
      enumerable: true,
    },
  })
  const oldVisible = dialogInstance.$props.visible
  setProps(dialogInstance, { visible: true })
  oldVisible !== true && dialogInstance.$emit('update:visible', true)

  return () => {
    if (dialogInstance) {
      setProps(dialogInstance, { visible: false })
    }
  }
}

const findDialogInstance = function(children) {
  for (const ins of children) {
    if (ins.$options.name === 'ElDialog') return ins
    if (ins.$children.length > 0) {
      return findDialogInstance(ins.$children)
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

Object.defineProperty(dialogWrap, 'h', {
  value: new Vue().$createElement,
  enumerable: true,
})

/**
 * !!! Use global registration with caution
 * This is suitable for registration only, the implementation needs to be split into a separate file
 */

import Vue from 'vue'
import * as utils from '@/scripts/utils'
import * as constants from '@/scripts/constants'
import eventBus from '@/scripts/eventBus'
const SvgIcon = function() {
  return import(
    /* webpackChunkName: "low-priority" */ '@/components/SvgIcon/index.vue'
  )
}

/* Prototype properties/methods Vue.prototype (prefixed with $) */
Vue.prototype.$env = Object.freeze(process.env)
Vue.prototype.$utils = Object.freeze({ ...utils })
Vue.prototype.$const = Object.freeze({ ...constants })
Vue.prototype.$isCancel = utils.isCancel
Vue.prototype.$eventBus = eventBus

/* Global filter  Vue.filter */
Vue.filter('dateFormat', utils.dateFormat)

/* Global directive Vue.directive */

/*  Vue.mixin */

/* Global component Vue.component */
Vue.component('svg-icon', SvgIcon)

/* Small plug-in Vue.use (heavy plug-in home directory, such as: vue-router, vuex, element-ui, i18n...) */

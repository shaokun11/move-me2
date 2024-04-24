import Vue from 'vue'
import Vuex from 'vuex'
import root from './root'
import getters from "./getters"
import modules from './modules/index'
Vue.use(Vuex)

/**
 */
export const store = new Vuex.Store({
  devtools:
    process.env.VUE_APP_ENV === 'dev' || process.env.VUE_APP_ENV === 'stage',
  strict: process.env.VUE_APP_ENV === 'dev',
  // ...root,

  modules: modules,
  getters
})

export default store

import 'normalize.css'
import './styles/reset.less'
import Vue from 'vue'
import './catchError'
import './element-ui' // @PC.element-ui
import './vant' // @H5.vant
import router from './router'
import store from './store'
import './injects'
import '../theme/index.css'
import './styles/global.less'
import App from './App.vue'



/* Conditional compilation (must be an environment variable available at run time and not undefined, or the module will be packed) */
if (process.env.VUE_APP_MOCK === 'true') {
  require('./api/mock')
}
if (process.env.VUE_APP_ENV === 'dev' || process.env.VUE_APP_ENV === 'stage') {
  require('./vconsole') // @H5
}

Vue.config.devtools =
  process.env.VUE_APP_ENV === 'dev' || process.env.VUE_APP_ENV === 'stage'
Vue.config.silent = process.env.VUE_APP_ENV === 'prod'
Vue.config.productionTip = false

export default new Vue({
  router,
  store,
  render: h => h(App),
}).$mount('#app')

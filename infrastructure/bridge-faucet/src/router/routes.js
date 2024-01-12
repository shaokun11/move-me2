/*  path Matching example：https://github.com/vuejs/vue-router/blob/dev/examples/route-matching/app.js */

import router from '@/router'
import Home from '@/views/Home/index.vue'

/**
 * @type {import('vue-router').RouteConfig[]}
 */
export const routes = [
  {
    path: '/',
    name: 'Bridge',
    meta: { title: 'Bridge' },
    component: Home,
  },
  {
    path: '/Faucet',
    name: 'Faucet',
    meta: { title: 'Faucet' },
    component: () =>
      import( '@/views/Faucet.vue'),
  },
  // {
  //   path: '/projects/info',
  //   name: 'projects-info',
  //   meta: { title: 'Projects Info' },
  //   component: () =>
  //     import('@/views/projects-info.vue'),
  // },
  // {
  //   path: '/*',
  //   name: '404',
  //   meta: { title: '404' },
  //   component: () =>
  //     import(/* webpackChunkName: "low-priority" */ '@/views/404.vue'),
  // },
]

if (process.env.VUE_APP_ENABLE_DOCS === 'true') {
  routes.unshift({
    path: '/component-examples',
    name: 'component-examples',
    meta: { title: 'Develop related documents' },
    component: () => import('@/components/ComponentExamples/index.vue'),
    beforeEnter(to, from, next) {
      if (from.matched.length === 0 && from.path === '/') {
        next()
        return
      }
      next(false)
      window.open(router.resolve(to.fullPath).href)
    },
  })
}

export default routes

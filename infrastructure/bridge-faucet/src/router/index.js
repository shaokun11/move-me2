/**
 * Route permission control mode:beforeEach | addRoutes | Combination of both
 *  addRoutes ， resetRoutes and filterMapRoutes
 */

import Vue from 'vue'
import Router from 'vue-router'
import scrollBehavior from './scrollBehavior'
import routes from './routes'
import registerInterceptor from './registerInterceptor'
Vue.use(Router)

const mode = 'hash'
const createRouter = function() {
  const base = mode === 'hash' ? '/' : process.env.BASE_URL
  return new Router({ mode, base, scrollBehavior })
}

/**
 * Globally unique Router instance
 */
export const router = createRouter()

/**
 * Route reset
 * @param {routes} newRoutes
 */
export const resetRoutes = function(newRoutes) {
  router.matcher = createRouter().matcher
  newRoutes.forEach(route => router.addRoute(route))
  if (router.app) {
    const { path, query, hash } = router.currentRoute
    router
      .replace({ path, query: { ...query, _resetRoutes: '1' }, hash })
      .then(() => router.replace({ path, query, hash }))
  }
}

/**
 * Route filtering (Filtering out authorized routes)
 * @param {(meta: object, route: routes[0]) => boolean} filterCallback
 * @returns {routes}
 */
export const filterMapRoutes = function(filterCallback) {
  const loop = curRoutes =>
    curRoutes
      .filter(route => filterCallback(route.meta || {}, route))
      .map(({ children, ...newRoute }) => {
        if (children) newRoute.children = loop(children)
        return newRoute
      })
  return loop(routes)
}

/* Register the route interceptor */
registerInterceptor(router)
/* Example Initialize the public route */
resetRoutes(
  filterMapRoutes(meta => {
    return meta.roles == null 
  }),
)

export default router

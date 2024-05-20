/**
 * Static resource service (node running)
 * Often used to preview/review packaging results, or to temporarily enable front-end services for other people
 */

const express = require('express')
const compression = require('compression')
const { createProxyMiddleware } = require('http-proxy-middleware')
const { join } = require('path')
const os = require('os')
const open = require('open')

const BASE_URL = '' // packaged process.env.BASE_URL
const port = 8181
const isHistoryMode = false
const projectDir = join(__dirname, './dist')
const app = express()

/* Proxy, more detailed configuration rules：https://github.com/chimurai/http-proxy-middleware#options */
// app.use(
//   '/api',
//   createProxyMiddleware({
//     target: 'http://0.0.0.0:123',
//     pathRewrite: { '^/api': '' },
//   }),
// )

/* Static resource */
app.use(compression())
app.use(BASE_URL, function(req, res) {
  let sendfilePath = req.path
  let cacheControl = 'no-cache'
  const isStatic = /\.\w+$/.test(req.path)
  const isStaticHtmlEntry = isStatic && /^\/index\.html/.test(req.path)
  const isStaticHashCache = isStatic && /^\/static-hash\//.test(req.path)
  if (isStatic) {
    if (isStaticHtmlEntry) {
      cacheControl = 'no-store'
    } else if (isStaticHashCache) {
      cacheControl = 'public,max-age=31536000'
    }
  } else {
    if (isHistoryMode) {
      cacheControl = 'no-store'
      sendfilePath = '/index.html'
    } else {
      if (req.path === '/') {
        cacheControl = 'no-store'
      }
      sendfilePath = join(req.path, '/index.html')
    }
  }
  res.setHeader('Cache-Control', cacheControl)
  res.sendfile(
    join(projectDir, sendfilePath),
    err => err && res.status(err.status).send(err.status),
  )
})
app.use((req, res) => res.status(404).send(404))

/* Start */
app.listen(port, function() {
  const ip = (() => {
    const interfaces = os.networkInterfaces()
    for (const devName in interfaces) {
      const iface = interfaces[devName]
      for (let i = 0; i < iface.length; i++) {
        const alias = iface[i]
        if (
          alias.family === 'IPv4' &&
          alias.address !== '127.0.0.1' &&
          !alias.internal
        ) {
          return alias.address
        }
      }
    }
  })()
  const local1 = `http://localhost:${port}${BASE_URL}`
  const local2 = `http://127.0.0.1:${port}${BASE_URL}`
  const network = `http://${ip || 'Unconnected network'}:${port}${BASE_URL}`
  global.console.log('')
  global.console.log(` Local1: ${local1}`)
  global.console.log(` Local2: ${local2}`)
  global.console.log(`Network: ${network}`)
  global.console.log('')
  open(ip ? network : local2)
})

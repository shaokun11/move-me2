
declare namespace NodeJS {
  interface ProcessEnv {
    readonly NODE_ENV: 'development' | 'production' | 'test'
    readonly VUE_APP_ENV: 'dev' | 'stage' | 'prod'

    readonly BASE_URL: '' | '/**/'
    readonly VUE_APP_BASEURL_API: '/**/*' | 'http*(s)://**/*'

    readonly VUE_APP_ENABLE_DOCS: 'true' | 'false'
    readonly VUE_APP_MOCK: 'true' | 'false'
  }
}

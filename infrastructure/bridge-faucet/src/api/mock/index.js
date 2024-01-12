
import createMock from './createMock'
import * as news from './news'
const myMock = createMock(process.env.VUE_APP_BASEURL_API)

myMock('reg:/news/getList\\?.+', news.getList)
myMock('reg:/news/getDetails/.+', news.getDetails)

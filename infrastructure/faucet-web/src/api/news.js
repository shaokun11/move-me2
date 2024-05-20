import http from '@/scripts/http'
import {fetch as fetch2} from 'whatwg-fetch'
// import 'whatwg-fetch'
// require('isomorphic-fetch');


/**
 * @param {object} [params]
 * @param {string} [params.keyword]
 * @param {number | string | Array<number | string>} [params.status]
 * @param {number | string} [params.pageNum]
 * @param {number | string} [params.pageSize]
 */
export const getNewsList = params => {
  params = {
    pageNum: 1,
    pageSize: 10,
    ...params,
  }
  return http.get('/news/getList', { params })
}

export const postMsg = params =>{
  //httpRequest.setRequestHeader("token", "6LF8pdT3BlbkFJFJkUgwUz");
  // { msg: value, id: "chatcmpl-6vzZqA9zkGTBl7wh6b3x0nKAne4xQ" }
  // http.head["token"]
  return http.post('https://api-moonbox.bbd.sh/chat', params)
  // return http.post('https://gpt.bbd.sh/chat', params)
  
}
async function post(url, query) {
  return fetch2(url, {
    method: "POST",
    headers: {
      "Content-type": "application/json",
      "Authorization": "Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ik1UaEVOVUpHTkVNMVFURTRNMEZCTWpkQ05UZzVNRFUxUlRVd1FVSkRNRU13UmtGRVFrRXpSZyJ9.eyJodHRwczovL2FwaS5vcGVuYWkuY29tL2F1dGgiOnsidXNlcl9pZCI6InVzZXItV1dqZnFCUUsxVlJVNzdzekVSSGdjMEdaIn0sImlzcyI6Imh0dHBzOi8vYXV0aDAub3BlbmFpLmNvbS8iLCJzdWIiOiJnb29nbGUtb2F1dGgyfDEwNTYxNDc0MTg0OTA4NDE0ODM4OSIsImF1ZCI6WyJodHRwczovL2FwaS5vcGVuYWkuY29tL3YxIiwiaHR0cHM6Ly9vcGVuYWkuYXV0aDAuY29tL3VzZXJpbmZvIl0sImlhdCI6MTY3MDMwNjY5NywiZXhwIjoxNjcwMzkzMDk3LCJhenAiOiJUZEpJY2JlMTZXb1RIdE45NW55eXdoNUU0eU9vNkl0RyIsInNjb3BlIjoib3BlbmlkIGVtYWlsIHByb2ZpbGUgbW9kZWwucmVhZCBtb2RlbC5yZXF1ZXN0IG9yZ2FuaXphdGlvbi5yZWFkIG9mZmxpbmVfYWNjZXNzIn0.Ae_BE4u9arn1Fnpk48L9k_Q3mtRAqRbaf--jMmmP9rk3YJYppt6S01EgV9Pr9gKiapKoEK469rUyA2hpa7LdnnXyevnr34hF_V2xBdpdmFK3BEDmDid7omCDsYx-hDenLRKab9h4OPEM5JE4KoH6ZcXMATH4Bc0Sm6gz-h4CgIULlxB2f134BYsYbNZ3rixuo8Jp_PeXI88kzJ_rimxDQHrDcgTI-8w7bk2ujiyblvlTBSksfK614dhYeg1tYCqJbiXO9fX3K4EFBBN8Wrenpf0rCOWE0k93PCwuypRa6KJifqSq1P33oIzRCZwtsw_pOG6E0SwVI2CCnhKqgeBBjw",
    },
    body: JSON.stringify(query),
  }).then((response) => response.json());
}

async function get(url) {
  return fetch2(url, {
    method: "GET",
    headers: {
      "Content-type": "application/json",
      "Authorization": "Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ik1UaEVOVUpHTkVNMVFURTRNMEZCTWpkQ05UZzVNRFUxUlRVd1FVSkRNRU13UmtGRVFrRXpSZyJ9.eyJodHRwczovL2FwaS5vcGVuYWkuY29tL2F1dGgiOnsidXNlcl9pZCI6InVzZXItV1dqZnFCUUsxVlJVNzdzekVSSGdjMEdaIn0sImlzcyI6Imh0dHBzOi8vYXV0aDAub3BlbmFpLmNvbS8iLCJzdWIiOiJnb29nbGUtb2F1dGgyfDEwNTYxNDc0MTg0OTA4NDE0ODM4OSIsImF1ZCI6WyJodHRwczovL2FwaS5vcGVuYWkuY29tL3YxIiwiaHR0cHM6Ly9vcGVuYWkuYXV0aDAuY29tL3VzZXJpbmZvIl0sImlhdCI6MTY3MDMwNjY5NywiZXhwIjoxNjcwMzkzMDk3LCJhenAiOiJUZEpJY2JlMTZXb1RIdE45NW55eXdoNUU0eU9vNkl0RyIsInNjb3BlIjoib3BlbmlkIGVtYWlsIHByb2ZpbGUgbW9kZWwucmVhZCBtb2RlbC5yZXF1ZXN0IG9yZ2FuaXphdGlvbi5yZWFkIG9mZmxpbmVfYWNjZXNzIn0.Ae_BE4u9arn1Fnpk48L9k_Q3mtRAqRbaf--jMmmP9rk3YJYppt6S01EgV9Pr9gKiapKoEK469rUyA2hpa7LdnnXyevnr34hF_V2xBdpdmFK3BEDmDid7omCDsYx-hDenLRKab9h4OPEM5JE4KoH6ZcXMATH4Bc0Sm6gz-h4CgIULlxB2f134BYsYbNZ3rixuo8Jp_PeXI88kzJ_rimxDQHrDcgTI-8w7bk2ujiyblvlTBSksfK614dhYeg1tYCqJbiXO9fX3K4EFBBN8Wrenpf0rCOWE0k93PCwuypRa6KJifqSq1P33oIzRCZwtsw_pOG6E0SwVI2CCnhKqgeBBjw",
    },
  }).then((response) => response.json());
}

export const postMsg2 = params =>{
  return post('https://api-moonbox.bbd.sh/chat' , params)
}

export const getMsg = params =>{
  let {address} = params
  return get('https://api-moonbox.bbd.sh/reply?address=' + address)
}

export const getHis = params =>{
  let {address} = params
  return get('https://api-moonbox.bbd.sh/history?address=' + address)
}


export const getNewsDetails = id => http.get(`/news/getDetails/${id}`)

import { TokenList } from '@uniswap/token-lists'
import schema from '@uniswap/token-lists/src/tokenlist.schema.json'
import Ajv from 'ajv'
import contenthashToUri from './contenthashToUri'
import { parseENSAddress } from './parseENSAddress'
import uriToHttp from './uriToHttp'
import {G_CONFIG} from "./MyPair";

const tokenListValidator = new Ajv({ allErrors: true }).compile(schema)

/**
 * Contains the logic for resolving a list URL to a validated token list
 * @param listUrl list url
 * @param resolveENSContentHash resolves an ens name to a contenthash
 */
export default async function getTokenList(
  listUrl: string,
  resolveENSContentHash: (ensName: string) => Promise<string>
): Promise<TokenList> {

  // console.log('gettoken-111')
    const json:any = {
      "name": "1inch",
      "timestamp": "2022-04-06T22:19:09+00:00",
      "version": {
          "major": 145,
          "minor": 0,
          "patch": 0
      },
      "keywords": [
          "1inch",
          "default",
          "list"
      ],
      tokens:[]
    }
    json.tokens.push(
      ...G_CONFIG.tokens
    )

    return json
  // const parsedENS = parseENSAddress(listUrl)
  // let urls: string[]
  
  // if (parsedENS) {
  //   let contentHashUri
  //   try {
  //     contentHashUri = await resolveENSContentHash(parsedENS.ensName)
  //   } catch (error) {
  //     console.debug(`Failed to resolve ENS name: ${parsedENS.ensName}`, error)
  //     throw new Error(`Failed to resolve ENS name: ${parsedENS.ensName}`)
  //   }
  //   let translatedUri
  //   try {
  //     translatedUri = contenthashToUri(contentHashUri)
  //   } catch (error) {
  //     console.debug('Failed to translate contenthash to URI', contentHashUri)
  //     throw new Error(`Failed to translate contenthash to URI: ${contentHashUri}`)
  //   }
  //   urls = uriToHttp(`${translatedUri}${parsedENS.ensPath ?? ''}`)
  // } else {
  //   urls = uriToHttp(listUrl)
  // }
  // for (let i = 0; i < urls.length; i++) {
  //   const url = urls[i]
  //   const isLast = i === urls.length - 1
  //   let response
  //   try {
  //     response = await fetch(url)
  //   } catch (error) {
  //     console.debug('Failed to fetch list', listUrl, error)
  //     if (isLast) throw new Error(`Failed to download list ${listUrl}`)
  //     continue
  //   }

  //   if (!response.ok) {
  //     if (isLast) throw new Error(`Failed to download list ${listUrl}`)
  //     continue
  //   }
    
    // const json = await response.json()
    // if (!tokenListValidator(json)) {
    //   const validationErrors: string =
    //     tokenListValidator.errors?.reduce<string>((memo, error) => {
    //       const add = `${error.dataPath} ${error.message ?? ''}`
    //       return memo.length > 0 ? `${memo}; ${add}` : `${add}`
    //     }, '') ?? 'unknown error'
    //   throw new Error(`Token list failed validation: ${validationErrors}`)
    // }
    // json.tokens=G_CONFIG.tokens
    
  // }
  // throw new Error(/'Unrecognized list URL protocol.')
}

import {UseQueryResult} from "@tanstack/react-query";
import {ResponseError} from "./client";

type CombinedQueryResultState = {
  isLoading: boolean;
  error: ResponseError | null;
};

/**
 * Combines multiple react-query queries into a single query state.
 * This is useful if your component needs to make multiple API calls concurrently in order to render the desires data.
 * @param queries
 * @returns
 * @example
 * const {
 *  combinedQueryState: {error, isLoading}},
 *  queries: [query1, query2, query3],
 * } = combineQueries([
 * useQuery(...),
 * useQuery(...),
 * useQuery(...),
 * ]);
 */
export function combineQueries<
  T extends UseQueryResult<unknown, ResponseError>[],
>(queries: [...T]): {combinedQueryState: CombinedQueryResultState; queries: T} {
  const error = queries.find((query) => query.isError)?.error;
  const isLoading = queries.some((query) => query.isLoading);
  return {combinedQueryState: {error: error ?? null, isLoading}, queries};
}


interface RequestData {
  id: string;
  jsonrpc: string;
  method: string;
  params: string[];
}

interface RequestOptions {
  method: string;
  headers: Record<string, string>;
  body: string;
}


//check move hash and address method(debug_getMoveHash/debug_getMoveAddress)
export async function getMoveHA(method: string, param: string): Promise<any> {
  const url = import.meta.env.REACT_APP_MOVE_EVMCHECK||'https://mevm.testnet.imola.movementlabs.xyz/';

  const data: RequestData = {
      id: "1",
      jsonrpc: "2.0",
      method: method,
      params: [param]
  };

  const options: RequestOptions = {
      method: 'POST',
      headers: {
          'Content-Type': 'application/json'
      },
      body: JSON.stringify(data)
  };

  try {
      const response = await fetch(url, options);
      const responseJson = await response.json();
      if(responseJson.error){
        return {code:0,data:param};
      
      }else{
        return {code:1,data:responseJson.result};
      }
      // console.log('Response:', responseJson);
      
  } catch (error) {
      // console.error('Error:', error);
      return {code:0,data:param};
  }
}
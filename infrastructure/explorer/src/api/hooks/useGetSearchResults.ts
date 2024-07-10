import {useEffect, useState} from "react";
import {
  getAccount,
  getBlockByHeight,
  getBlockByVersion,
  getTransaction,
} from "../../api";
import {GTMEvents} from "../../dataConstants";
import {useGlobalState} from "../../global-config/GlobalConfig";
import {
  isNumeric,
  isValidAccountAddress,
  isValidTxnHashOrVersion,
  truncateAddress,
} from "../../pages/utils";
import {getAddressFromName} from "./useGetANS";
import {sendToGTM} from "./useGoogleTagManager";
import {useAugmentToWithGlobalSearchParams} from "../../routing";

export type SearchResult = {
  label: string;
  label0: string| null;
  to: string | null;
};

export const NotFoundResult: SearchResult = {
  label: "No Results",
  label0: null,
  to: null,
};

export default function useGetSearchResults(input:{old:string,newstr:string}) {
  const [results, setResults] = useState<SearchResult[]>([]);
  const [state, _setState] = useGlobalState();

  const {old, newstr} = input;
  const isSame = old === newstr;

  const searchText = newstr;

  const augmentToWithGlobalSearchParams = useAugmentToWithGlobalSearchParams();

  useEffect(() => {
    if (searchText === "") {
      setResults([NotFoundResult]);
      return;
    }

    const fetchData = async () => {
      const searchPerformanceStart = GTMEvents.SEARCH_STATS + " start";
      const searchPerformanceEnd = GTMEvents.SEARCH_STATS + " end";
      window.performance.mark(searchPerformanceStart);

      const isValidAccountAddr = isValidAccountAddress(searchText);
      const isValidTxnHashOrVer = isValidTxnHashOrVersion(searchText);
      const isValidBlockHeightOrVer = isNumeric(searchText);

      const namePromise = getAddressFromName(searchText, state.network_name)
        .then(({address, primaryName}): SearchResult | null => {
          // console.log("namePromise", address, primaryName);
          if (address) {
            return {
              label0:null,
              label: `Account ${truncateAddress(address)}${
                primaryName ? ` | ${primaryName}.apt` : ``
              }`,
              to: `/account/${address}`,
            };
          } else {
            return null;
          }
        })
        .catch(() => {
          return null;
          // Do nothing. It's expected that not all search input is a valid transaction
        });

      const accountPromise = getAccount(
        {address: searchText},
        state.network_value,
      )
        .then((): SearchResult => {
          // console.log("accountPromise", searchText);
          if(isSame){
            return {
              label0:null,
              label: `Account ${searchText}`,
              to: `/account/${searchText}`,
            };
          }else{
            return {
              label0: `Account (MEVM) ${old}`,
              label: `Account (MOVE)  ${searchText}`,
              to: `/account/${searchText}`,
            };
          }

          
        })
        .catch(() => {
          return null;
          // Do nothing. It's expected that not all search input is a valid account
        });

      const txnPromise = getTransaction(
        {txnHashOrVersion: searchText},
        state.network_value,
      )
        .then((): SearchResult => {
          // console.log("txnPromise", searchText);
          if(isSame){
            return {
              label0:null,
              label: `Transaction ${searchText}`,
              to: `/txn/${searchText}`,
            };
          }else{
            return {
              label: `Transaction (MOVE) ${searchText}`,
              to: `/txn/${searchText}`,
              label0: `Transaction (MEVM) ${old}`,
            };
          }
        })
        .catch(() => {
          return null;
          // Do nothing. It's expected that not all search input is a valid transaction
        });

      const blockByHeightPromise = getBlockByHeight(
        {height: parseInt(searchText), withTransactions: false},
        state.network_value,
      )
        .then((): SearchResult => {
          // console.log("blockByHeightPromise", searchText);
          return {
            label0:null,
            label: `Block ${searchText}`,
            to: `/block/${searchText}`,
          };
        })
        .catch(() => {
          return null;
          // Do nothing. It's expected that not all search input is a valid transaction
        });

      const blockByVersionPromise = getBlockByVersion(
        {version: parseInt(searchText), withTransactions: false},
        state.network_value,
      )
        .then((block): SearchResult => {
          return {
            label0:null,
            label: `Block with Txn Version ${searchText}`,
            to: `/block/${block.block_height}`,
          };
        })
        .catch(() => {
          return null;
          // Do nothing. It's expected that not all search input is a valid transaction
        });

      const promises = [];

      promises.push(namePromise);
      if (isValidAccountAddr) {
        promises.push(accountPromise);
      }
      if (isValidTxnHashOrVer) {
        promises.push(txnPromise);
      }
      if (isValidBlockHeightOrVer) {
        promises.push(blockByHeightPromise);
        promises.push(blockByVersionPromise);
      }

      const resultsList = await Promise.all(promises);
      const results = resultsList
        .filter((result): result is SearchResult => !!result)
        .map((result) => ({
          ...result,
          to:
            result.to !== null
              ? augmentToWithGlobalSearchParams(result.to)
              : null,
        }));

      window.performance.mark(searchPerformanceEnd);
      sendToGTM({
        dataLayer: {
          event: GTMEvents.SEARCH_STATS,
          network: state.network_name,
          searchText: searchText,
          searchResult: results.length === 0 ? "notFound" : "success",
          duration: window.performance.measure(
            GTMEvents.SEARCH_STATS,
            searchPerformanceStart,
            searchPerformanceEnd,
          ).duration,
        },
      });
      if (results.length === 0) {
        results.push(NotFoundResult);
      }

      setResults(results);
    };

    fetchData();
  }, [searchText, state]);

  return results;
}

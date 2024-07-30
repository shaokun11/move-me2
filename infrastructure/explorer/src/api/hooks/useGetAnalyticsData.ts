import {useEffect, useState} from "react";
import {defaultNetworkName} from "../../constants";
import {useGlobalState} from "../../global-config/GlobalConfig";

export const ANALYTICS_DATA_URL =
  "https://storage.googleapis.com/aptos-mainnet/explorer/chain_stats_v2.json?cache-version=0";

export type AnalyticsData = {
  daily_active_users: DailyActiveUserData[];
  daily_average_gas_unit_price: DailyAvgGasData[];
  daily_gas_from_user_transactions: DailyGasCostData[];
  daily_contract_deployers: DailyContractDeployerData[];
  daily_deployed_contracts: DailyContractData[];
  daily_max_tps_15_blocks: DailyPeakTPSData[];
  daily_new_accounts_created: DailyNewAccountData[];
  daily_user_transactions: DailyUserTxnData[];
  mau_signers: MonthlyActiveUserData[];
  max_tps_15_blocks_in_past_30_days: {
    max_tps_15_blocks_in_past_30_days: number;
  }[];
};

export type DailyAnalyticsData =
  | DailyActiveUserData
  | DailyAvgGasData
  | DailyGasCostData
  | DailyContractDeployerData
  | DailyContractData
  | DailyPeakTPSData
  | DailyNewAccountData
  | DailyUserTxnData
  | MonthlyActiveUserData;

export type DailyActiveUserData = {
  daily_active_user_count: number;
  date: string;
};

export type DailyAvgGasData = {
  avg_gas_unit_price: string;
  date: string;
};

export type DailyGasCostData = {
  gas_cost: string;
  date: string;
};

export type DailyContractDeployerData = {
  distinct_deployers: number;
  date: string;
};

export type DailyContractData = {
  daily_contract_deployed: number;
  date: string;
};

export type DailyPeakTPSData = {
  max_tps_15_blocks: number;
  date: string;
};

export type DailyNewAccountData = {
  new_account_count: number;
  date: string;
};

export type DailyUserTxnData = {
  num_user_transactions: number;
  date: string;
};

export type MonthlyActiveUserData = {
  mau_signer_30: number;
  date: string;
};

export function useGetAnalyticsData() {
  const [state] = useGlobalState();
  const [data, setData] = useState<AnalyticsData>();

  useEffect(() => {
    if (state.network_name === defaultNetworkName) {
      const fetchData = async () => {
        const response = await fetch(ANALYTICS_DATA_URL);
        const data = await response.json();
        setData(data);
      };

      fetchData().catch((error) => {
        console.error("ERROR!", error, typeof error);
      });
    } else {
      setData(undefined);
    }
  }, [state]);

  return data;
}

// export async function getTotalData() {

//   let addressCount= 0;
//   let txCount= 0;
//   let evmaddressCount= 0;
//   let evmtxCount= 0;

//   const aa1 = async function() {
//     type JsonRpcRequest = {
//         method: string;
//         params: any[];
//         id: number;
//         jsonrpc: string;
//     };
  
//   const request: JsonRpcRequest = {
//       method: "admin_getEvmTxSummary",
//       params: [],
//       id: 1,
//       jsonrpc: "2.0"
//   };
  
//   const url = import.meta.env.REACT_APP_MOVE_EVMCHECK||'https://mevm.testnet.imola.movementlabs.xyz/';
  
//   const res1:any = await fetch(url, {
//       method: 'POST',
//       headers: {
//           'Content-Type': 'application/json'
//       },
//       body: JSON.stringify(request)
//   });
//   evmaddressCount = res1.result?.addressCount||0;
//   evmtxCount = res1.result?.txCount||0;
// }

// const aa2 = async function() {
//   const res2:any = await fetch('https://aptos.testnet.imola.movementlabs.xyz/indexer/v1/graphql', {
//     method: 'POST',
//     headers: {
//       'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
//       'Content-Type': 'application/json'
//     },
//     body: JSON.stringify({
//       operationName: "MyQuery",
//       variables: {},
//       query: `query MyQuery {
//         account_transactions_aggregate(distinct_on: account_address) {
//           aggregate {
//             count(distinct: true)
//           }
//         }
//       }`
//     })
//   });
//   addressCount = res2?.data?.account_transactions_aggregate?.aggregate?.count||0;
// }

// const aa3 = async function() {

//   const url = "https://aptos.testnet.imola.movementlabs.xyz/api/v1";
//   const res3:any = await fetch(url,{
//     method: 'POST',
//     headers: {
//       'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
//       'Content-Type': 'application/json'
//     },
//   });
 
//   txCount = res3.ledger_version||0;
// }

//   await aa1();
//   await aa2();
//   await aa3();
    

//   return {addressCount, txCount, evmaddressCount, evmtxCount};
   
// }

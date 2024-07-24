import React, {createContext, useEffect, useState} from "react";
import Grid from "@mui/material/Grid";
import TotalSupply from "./TotalSupply";
// import TotalStake from "./TotalStake";
// import TPS from "./TPS";
// import ActiveValidators from "./ActiveValidators";
// import TotalTransactions from "./TotalTransactions";
import {useGetInMainnet} from "../../../api/hooks/useGetInMainnet";
import {Link} from "../../../routing";
import { useGlobalState } from "../../../global-config/GlobalConfig";
import { getLedgerInfo } from "../../../api";
import {Types} from "aptos";
import { useQuery } from "@tanstack/react-query";


type CardStyle = "default" | "outline";

export const StyleContext = createContext<CardStyle>("default");

export async function getTotalData() {

  let addressCount= 0;
  let txCount= 0;
  let evmaddressCount= 0;
  let evmtxCount= 0;

  const aa1 = async function() {
    type JsonRpcRequest = {
        method: string;
        params: any[];
        id: number;
        jsonrpc: string;
    };
  
  const request: JsonRpcRequest = {
      method: "admin_getEvmTxSummary",
      params: [],
      id: 1,
      jsonrpc: "2.0"
  };
  
  const url = import.meta.env.REACT_APP_MOVE_EVMCHECK||'https://mevm.testnet.imola.movementlabs.xyz/';
  
  let res1:any = await fetch(url, {
      method: 'POST',
      headers: {
          'Content-Type': 'application/json'
      },
      body: JSON.stringify(request)
  });
  res1 = await res1.json();
  // console.log("res1", res1);
  evmaddressCount = res1.result?.addressCount||0;
  evmtxCount = res1.result?.txCount||0;
}

const aa2 = async function() {
  let res2:any = await fetch(import.meta.env.REACT_APP_MOVE_GQL, {
    method: 'POST',
    headers: {
      'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      operationName: "MyQuery",
      variables: {},
      query: `query MyQuery {
        account_transactions_aggregate(distinct_on: account_address) {
          aggregate {
            count(distinct: true)
          }
        }
      }`
    })
  });
  res2 = await res2.json();
  addressCount = res2?.data?.account_transactions_aggregate?.aggregate?.count||0;
}

const aa3 = async function() {

  const url = import.meta.env.REACT_APP_MOVE_ENDPOINT;
  let res3:any = await fetch(url,{
    method: 'GET',
    headers: {
      'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
      'Content-Type': 'application/json'
    },
  });
  res3 = await res3.json();
 
  txCount = res3.ledger_version||0;
}

  await aa1();
  await aa2();
  await aa3();
    

  return {addressCount, txCount, evmaddressCount, evmtxCount};
   
}

function LinkableContainer({
  linkToAnalyticsPage,
  children,
}: {
  linkToAnalyticsPage: boolean;
  children: React.ReactNode;
}) {
  const inMainnet = useGetInMainnet();

  return inMainnet && linkToAnalyticsPage ? (
    <Link to="/analytics" underline="none" color="inherit" variant="inherit">
      {children}
    </Link>
  ) : (
    <>{children}</>
  );
}

type NetworkInfoProps = {
  isOnHomePage?: boolean;
};

export default function NetworkInfo({isOnHomePage}: NetworkInfoProps) {
  const onHomePage = isOnHomePage === true;
  const [data, setData] = useState<any | null>(null);
  const [up,setUp] = useState<number>(1);

  setTimeout(() => {
    // console.log("up", up);
    setUp(up+1);
  },3000)
  

  useEffect(() => {
    getTotalData().then((data) => {
      data&&setData(data);
    });
  }, [up]);

  if(data == null) {
    return null;
  }
  const {addressCount, txCount, evmaddressCount, evmtxCount} = data;
  return (
    <StyleContext.Provider value={onHomePage ? "default" : "outline"}>
      <Grid
        container
        spacing={3}
        direction="row"
        sx={{alignContent: "flex-start"}}
        marginBottom={onHomePage ? 6 : 0}
      >
        {/* {onHomePage && (
          <Grid item xs={12} md={12} lg={12}>
            <TotalTransactions />
          </Grid>
        )} */}
        <Grid item xs={12} md={6} lg={3}>
          <LinkableContainer linkToAnalyticsPage={onHomePage}>
            <TotalSupply totalSupply={addressCount} title={"Total Move Wallets"} />
          </LinkableContainer>
        </Grid>
        <Grid item xs={12} md={6} lg={3}>
          <LinkableContainer linkToAnalyticsPage={onHomePage}>
            {/* <TotalStake /> */}
            <TotalSupply totalSupply={evmaddressCount} title={"Total EVM Wallets"} />
          </LinkableContainer>
        </Grid>
        <Grid item xs={12} md={6} lg={3}>
          <LinkableContainer linkToAnalyticsPage={onHomePage}>
            {/* <TPS /> */}
            <TotalSupply totalSupply={txCount} title={"Total Move Transactions"} />
          </LinkableContainer>
        </Grid>
        <Grid item xs={12} md={6} lg={3}>
          <LinkableContainer linkToAnalyticsPage={onHomePage}>
            {/* <ActiveValidators /> */}
            <TotalSupply totalSupply={evmtxCount} title={"Total EVM Transactions"} />
          </LinkableContainer>
        </Grid>
      </Grid>
    </StyleContext.Provider>
  );
}

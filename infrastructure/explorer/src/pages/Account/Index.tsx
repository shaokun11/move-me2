import {useParams} from "react-router-dom";
import {Grid} from "@mui/material";
import React, { useState } from "react";
import AccountTabs, {TabValue} from "./Tabs";
import AccountTitle from "./Title";
import BalanceCard from "./BalanceCard";
import PageHeader from "../layout/PageHeader";
import {useGetIsGraphqlClientSupported} from "../../api/hooks/useGraphqlClient";
import {useGetAccount} from "../../api/hooks/useGetAccount";
import LoadingModal from "../../components/LoadingModal";
import Error from "./Error";
import {AptosNamesBanner} from "./Components/AptosNamesBanner";
import {useGlobalState} from "../../global-config/GlobalConfig";
import {Network} from "aptos";
import { getMoveHA } from "../../api/query-utils";

const TAB_VALUES_FULL: TabValue[] = [
  "transactions",
  "coins",
  "tokens",
  "resources",
  "modules",
  "info",
];

const TAB_VALUES: TabValue[] = ["transactions", "resources", "modules", "info"];

export default function AccountPage() {
  const isGraphqlClientSupported = useGetIsGraphqlClientSupported();
  let address1 = useParams().address ?? "";
  
  
  const [state] = useGlobalState();

  if(address1.length === 42) {
    getMoveHA('debug_getMoveAddress',address1).then((res:any)=>{
      setAddress(res.data);
    });
  }
  const [address, setAddress] = useState<string>(address1.length === 42 ? "" : address1);

  const {data, error, isLoading} = useGetAccount(address);

  // TODO: [BE] instead of passing down address as props, use context
  // make sure that addresses will always start with "0X"
  const addressHex = address.startsWith("0x") ? address : "0x" + address;

  return (
    <Grid container spacing={1}>
      <LoadingModal open={isLoading} />
      <Grid item xs={12} md={12} lg={12}>
        <PageHeader />
      </Grid>
      <Grid item xs={12} md={8} lg={9} alignSelf="center">
        <AccountTitle address={addressHex} />
      </Grid>
      <Grid item xs={12} md={4} lg={3} marginTop={{md: 0, xs: 2}}>
        <BalanceCard address={addressHex} />
      </Grid>

      
      <Grid item xs={12} md={8} lg={12} marginTop={4} alignSelf="center">
        {state.network_name === Network.MAINNET && <AptosNamesBanner />}
      </Grid>
      
      <Grid item xs={12} md={12} lg={12} marginTop={4}>
        {error ? (
          <Error address={addressHex} error={error} />
        ) : (
          <AccountTabs
            address={addressHex}
            accountData={data}
            tabValues={isGraphqlClientSupported ? TAB_VALUES_FULL : TAB_VALUES}
          />
        )}
      </Grid> 
       
       
    </Grid>
  );
}

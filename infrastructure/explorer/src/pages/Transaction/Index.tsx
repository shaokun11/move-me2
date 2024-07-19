import React from "react";
import {Stack, Grid, Alert} from "@mui/material";
import {Types} from "aptos";
import {useGlobalState} from "../../global-config/GlobalConfig";
import {useParams} from "react-router-dom";
import {useQuery} from "@tanstack/react-query";
import {ResponseError} from "../../api/client";
import {getTransaction} from "../../api";
import Error from "./Error";
import TransactionTitle from "./Title";
import TransactionTabs from "./Tabs";
import PageHeader from "../layout/PageHeader";
import { getMoveHA } from "../../api/query-utils";

export default function TransactionPage() {
  const [state, _] = useGlobalState();
  const {txnHashOrVersion: txnParam} = useParams();
  const txnHashOrVersion1 = txnParam ?? "";
  const [txnHashOrVersion, setTxnHashOrVersion] = React.useState<string>(txnHashOrVersion1);

  if(txnHashOrVersion1.length === 66) {
    getMoveHA('debug_getMoveHash',txnHashOrVersion1).then((res:any)=>{
      setTxnHashOrVersion(res.data);
      // console.log('txnHashOrVersion',txnHashOrVersion1,txnHashOrVersion,res);
    });
  }
  // else{
  //   setTxnHashOrVersion(txnHashOrVersion1);
  // }

  const {isLoading, data, error} = useQuery<Types.Transaction, ResponseError>(
    ["transaction", {txnHashOrVersion}, state.network_value],
    () => getTransaction({txnHashOrVersion}, state.network_value),
  );

  if (isLoading) {
    return null;
  }

  if (error) {
    return <Error error={error} txnHashOrVersion={txnHashOrVersion} />;
  }

  if (!data) {
    return (
      <Alert severity="error">
        Got an empty response fetching transaction with version or hash{" "}
        {txnHashOrVersion}
        <br />
        Try again later
      </Alert>
    );
  }

  return (
    <Grid container>
      <PageHeader />
      <Grid item xs={12}>
        <Stack direction="column" spacing={4} marginTop={2}>
          <TransactionTitle transaction={data} />
          <TransactionTabs transaction={data} />
        </Stack>
      </Grid>
    </Grid>
  );
}

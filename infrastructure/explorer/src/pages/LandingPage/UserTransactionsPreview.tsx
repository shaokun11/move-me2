import Button from "@mui/material/Button";
import Box from "@mui/material/Box";
import * as RRD from "react-router-dom";
import {Stack, Typography} from "@mui/material";
import {UserTransactionsTable} from "../Transactions/TransactionsTable";
import useGetUserTransactionVersions from "../../api/hooks/useGetUserTransactionVersions";
import TransactionsPreview from "./TransactionsPreview";
import {useAugmentToWithGlobalSearchParams} from "../../routing";
// import { useEffect, useState } from "react";

const PREVIEW_TRANSACTIONS_COUNT = 10;

export default function UserTransactionsPreview() {
  // const [startVersion, setStartVersion] = useState<number | undefined>(1);
  const versions = useGetUserTransactionVersions(PREVIEW_TRANSACTIONS_COUNT);
  const augmentTo = useAugmentToWithGlobalSearchParams();

  // const [up,setUp] = useState<number>(1);

  // setTimeout(() => {
  //   console.log("versions", versions,versions.length);
  //   const aa = Math.max(versions?.length>0?versions[0]+1:0,(startVersion||0)+1);
  //   setStartVersion(aa)
  // },6000)
  

  // useEffect(() => {
    
  //   console.log("versions", versions,versions.length);
  //   setTimeout(() => {
  //     setStartVersion(versions?.length>0?versions[0]:0)
  //   },6000)
  //   // setStartVersion(versions?.length>0?versions[0]:0)
  // }, [startVersion]);
  

  // TODO: remove the fallback below when indexer is stable
  
  if (versions.length === 0) {
    // console.log("versions", versions);
    return <TransactionsPreview />;
  }

  return (
    <>
      <Stack spacing={2}>
        <Typography variant="h5">User Transactions</Typography>
        <Box sx={{width: "auto", overflowX: "auto"}}>
          <UserTransactionsTable versions={versions} />
        </Box>
        <Box sx={{display: "flex", justifyContent: "center"}}>
          <Button
            component={RRD.Link}
            to={augmentTo("/transactions")}
            variant="primary"
            sx={{margin: "0 auto", mt: 3}}
          >
            View all Transactions
          </Button>
        </Box>
      </Stack>
    </>
  );
}

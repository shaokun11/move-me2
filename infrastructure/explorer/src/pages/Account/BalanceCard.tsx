import React from "react";
import {Stack, Typography} from "@mui/material";
import {getFormattedBalanceStr} from "../../components/IndividualPageContent/ContentValue/CurrencyValue";
import {Card} from "../../components/Card";
import {grey} from "../../themes/colors/aptosColorPalette";
import StyledTooltip from "../../components/StyledTooltip";
import InfoOutlinedIcon from "@mui/icons-material/InfoOutlined";
import {useGetAccountAPTBalance} from "../../api/hooks/useGetAccountAPTBalance";
import { useGetAccountResources } from "../../api/hooks/useGetAccountResources";

type BalanceCardProps = {
  address: string;
};

export default function BalanceCard({address}: BalanceCardProps) {
  const balance1 = useGetAccountAPTBalance(address);

  // const [balance2, setBalance2] = React.useState<string | null>(null);
  // const [balance, setBalance] = React.useState<string | null>(null);
  let balance2 = null;
  let balance = null;

  const {isLoading, data, error} = useGetAccountResources(address);

  // console.log("balance", balance1,isLoading, data, error);
  
  if(balance1&&!isLoading && !error && data) {

    // console.log("check data", data);

    const resources = data as any[] ;
    const aptResource = resources.find((resource) => resource?.type === "0x1::evm_storage::AccountStorage");
    if (aptResource) {
      // console.log("aptResource-balance", aptResource?.data?.balance);
      balance2 = Number(aptResource?.data?.balance)*1e-10;
    }else{
      balance2 = ("0");
    }
  }
  
  if(balance1&&balance2){
    console.log("balance", balance1,balance2);
    balance = Math.floor(Math.max(Number(balance1),Number(balance2))).toString();
  }

  

  return balance ? (
    <Card height="auto">
      <Stack spacing={1.5} marginY={1}>
        <Typography fontSize={17} fontWeight={700}>
          {`${getFormattedBalanceStr(balance)} MVMT`}
        </Typography>
        <Stack direction="row" spacing={1} alignItems="center">
          <Typography fontSize={12} color={grey[450]}>
            Balance
          </Typography>
          <StyledTooltip title="This balance reflects the amount of MVMT tokens held in your wallet.">
            <InfoOutlinedIcon sx={{fontSize: 15, color: grey[450]}} />
          </StyledTooltip>
        </Stack>
      </Stack>
    </Card>
  ) : null;
}

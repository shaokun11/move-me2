import React from "react";
// import {useGetCoinSupplyLimit} from "../../../api/hooks/useGetCoinSupplyLimit";
import {getFormattedBalanceStr} from "../../../components/IndividualPageContent/ContentValue/CurrencyValue";
import MetricCard from "./MetricCard";

export default function TotalSupply(totalSupply:any) {
  // const totalSupply = useGetCoinSupplyLimit();
  const aa = getFormattedBalanceStr((totalSupply.totalSupply*1e8).toString(), undefined, 0);
  // console.log("aa", aa,totalSupply,totalSupply.totalSupply.toString());

  return (
    <MetricCard
      data={
        totalSupply
          ? aa
          : "-"
      }
      label={totalSupply.title}
      tooltip={totalSupply.title}
    />
  );
}

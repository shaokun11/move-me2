import { Stack, Typography} from "@mui/material";
import { useGetTPS} from "../../../api/hooks/useGetTPS";

function getFormattedTPS(tps: number) {
  const tpsWithDecimal = parseFloat(tps.toFixed(0));
  return tpsWithDecimal.toLocaleString("en-US");
}

export default function TPS() {
  const {tps} = useGetTPS();
  // const {peakTps} = useGetPeakTPS();
  // const [state] = useGlobalState();
  // const [showPeakTps, setShowPeakTps] = useState<boolean>(true);

  // useEffect(() => {
  //   if (state.network_name === "mainnet") {
  //     setShowPeakTps(true);
  //   } else {
  //     setShowPeakTps(false);
  //   }
  // }, [state]);

  return (
    <Stack direction="column">
      <Typography variant="body2" alignSelf="flex-end">
        {`TPS: ${
          tps ? getFormattedTPS(tps) : "-"
        }`}
      </Typography>
    </Stack>
  );

  

  // return showPeakTps ? (
  //   <DoubleMetricCard
  //     data1={tps ? getFormattedTPS(tps) : "-"}
  //     data2={peakTps ? getFormattedTPS(peakTps) : "-"}
  //     label1="REAL-TIME"
  //     label2="PEAK LAST 30 DAYS"
  //     cardLabel="TPS"
  //     tooltip={
  //       <Stack spacing={1}>
  //         <Box>
  //           <Box sx={{fontWeight: 700}}>Real-Time</Box>
  //           <Box>Current rate of transactions per second on the network.</Box>
  //         </Box>
  //         <Box>
  //           <Box sx={{fontWeight: 700}}>Peak Last 30 Days</Box>
  //           <Box>
  //             Highest rate of transactions per second over the past 30 days,
  //             averaged over 15 blocks.
  //           </Box>
  //         </Box>
  //       </Stack>
  //     }
  //   />
  // ) : (
  //   <MetricCard
  //     data={tps ? getFormattedTPS(tps) : "-"}
  //     label="TPS"
  //     tooltip="Current rate of transactions per second on the network."
  //   />
  // );
}

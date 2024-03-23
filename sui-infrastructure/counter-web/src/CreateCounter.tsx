import {
  useSignAndExecuteTransactionBlock,
  useSuiClient,
} from "@mysten/dapp-kit";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import { COUNTER_PACKAGE_ID } from "./constants";
import React from "react";

export function CreateCounter(props: { onCreated: (id: string) => void }) {
  const suiClient = useSuiClient();
  const [v, setV] = React.useState(10);
  const { mutate: signAndExecute } = useSignAndExecuteTransactionBlock();
  return (
    <div style={{ marginTop: "20px" }}>
      <div>
      <input type="number" value={v} onChange={(v)=>setV(+v.target.value)} />
      </div>
      <button
        onClick={() => {
          create(v);
        }}
      >
        Create Counter
      </button>
    </div>
  );

  function create(v:number) {
    const txb = new TransactionBlock();
    txb.moveCall({
      arguments: [txb.pure.u64(v)],
      target: `${COUNTER_PACKAGE_ID}::counter::create`,
    });
    signAndExecute(
      {
        transactionBlock: txb,
        options: {
          showEffects: true,
        },
      },
      {
        onError(error) {
          console.error("executeMoveCall onError", error);
        },
        onSuccess(data) {
          console.log("executeMoveCall onSuccess", data);
          suiClient
            .waitForTransactionBlock({ digest: data.digest })
            .then(() => {
              const objectId = data.effects?.created?.[0]?.reference?.objectId;
              if (objectId) {
                props.onCreated(objectId);
              }
            });
        },
      },
    );
  }
}

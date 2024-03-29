import {
  useCurrentAccount,
  useSignAndExecuteTransactionBlock,
  useSuiClient,
  useSuiClientQuery,
} from "@mysten/dapp-kit";
import { SuiObjectData } from "@mysten/sui.js/client";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import { COUNTER_PACKAGE_ID } from "./constants";

export function Counter({ id }: { id: string }) {
  const currentAccount = useCurrentAccount();
  const suiClient = useSuiClient();
  const { mutate: signAndExecute } = useSignAndExecuteTransactionBlock();
  const { data, refetch } = useSuiClientQuery("getObject", {
    id,
    options: {
      showContent: true,
    },
  });

  if (!data?.data) return <div>Not found</div>;

  const ownedByCurrentAccount =
    getCounterFields(data.data)?.owner === currentAccount?.address;

  return (
    <div  style={{ marginTop: "20px" }}>
      <div>Count: {getCounterFields(data.data)?.value}</div>

      <button onClick={() => executeMoveCall("increment")}>Increment</button>
      {ownedByCurrentAccount ? (
        <button onClick={() => executeMoveCall("reset")}>Reset</button>
      ) : null}
    </div>
  );

  function executeMoveCall(method: "increment" | "reset") {
    const txb = new TransactionBlock();

    if (method === "reset") {
      txb.moveCall({
        arguments: [txb.object(id), txb.pure.u64(0)],
        target: `${COUNTER_PACKAGE_ID}::counter::set_value`,
      });
    } else {
      txb.moveCall({
        arguments: [txb.object(id)],
        target: `${COUNTER_PACKAGE_ID}::counter::increment`,
      });
    }

    signAndExecute(
      {
        transactionBlock: txb,
      },
      {
        onSuccess: (tx) => {
          suiClient.waitForTransactionBlock({ digest: tx.digest }).then(() => {
            refetch();
          });
        },
      },
    );
  }
}

function getCounterFields(data: SuiObjectData) {
  if (data.content?.dataType !== "moveObject") {
    return null;
  }

  return data.content.fields as { value: number; owner: string };
}

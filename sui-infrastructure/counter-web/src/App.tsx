import { ConnectButton, useCurrentAccount } from "@mysten/dapp-kit";
import { isValidSuiObjectId } from "@mysten/sui.js/utils";
import { useState } from "react";
import { Counter } from "./counter";
import { CreateCounter } from "./CreateCounter";

export default function App() {
  const currentAccount = useCurrentAccount();
  const [counterId, setCounter] = useState(() => {
    const hash = window.location.hash.slice(1);
    return isValidSuiObjectId(hash) ? hash : null;
  });

  return (
    <div >
      <nav style={{marginTop:'20px'}}>
        <ConnectButton />
      </nav>
      <section>
        {!currentAccount ? (
          "Please connect your wallet"
        ) : counterId ? (
          <Counter id={counterId} />
        ) : (
            <CreateCounter
              onCreated={(id) => {
                window.location.hash = id;
                setCounter(id);
              }}
            />
        )}
      </section>
    </div>
  );
}

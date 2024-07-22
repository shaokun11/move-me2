
<a id="0x1_evm_storage"></a>

# Module `0x1::evm_storage`



-  [Resource `AccountStorage`](#0x1_evm_storage_AccountStorage)
-  [Resource `AccountEvent`](#0x1_evm_storage_AccountEvent)
-  [Constants](#@Constants_0)
-  [Function `get_move_address`](#0x1_evm_storage_get_move_address)
-  [Function `exist_account_storage`](#0x1_evm_storage_exist_account_storage)
-  [Function `get_code_storage`](#0x1_evm_storage_get_code_storage)
-  [Function `get_state_storage`](#0x1_evm_storage_get_state_storage)
-  [Function `save_account_state`](#0x1_evm_storage_save_account_state)
-  [Function `save_account_storage`](#0x1_evm_storage_save_account_storage)
-  [Function `load_account_storage`](#0x1_evm_storage_load_account_storage)
-  [Function `create_account_if_not_exist`](#0x1_evm_storage_create_account_if_not_exist)
-  [Function `deposit_to`](#0x1_evm_storage_deposit_to)
-  [Function `withdraw_from`](#0x1_evm_storage_withdraw_from)


<pre><code><b>use</b> <a href="account.md#0x1_account">0x1::account</a>;
<b>use</b> <a href="aptos_account.md#0x1_aptos_account">0x1::aptos_account</a>;
<b>use</b> <a href="aptos_coin.md#0x1_aptos_coin">0x1::aptos_coin</a>;
<b>use</b> <a href="coin.md#0x1_coin">0x1::coin</a>;
<b>use</b> <a href="create_signer.md#0x1_create_signer">0x1::create_signer</a>;
<b>use</b> <a href="util.md#0x1_evm_util">0x1::evm_util</a>;
<b>use</b> <a href="../../aptos-stdlib/doc/from_bcs.md#0x1_from_bcs">0x1::from_bcs</a>;
<b>use</b> <a href="../../aptos-stdlib/doc/table.md#0x1_table">0x1::table</a>;
</code></pre>



<a id="0x1_evm_storage_AccountStorage"></a>

## Resource `AccountStorage`



<pre><code><b>struct</b> <a href="storage.md#0x1_evm_storage_AccountStorage">AccountStorage</a> <b>has</b> store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>balance: u256</code>
</dt>
<dd>

</dd>
<dt>
<code><a href="code.md#0x1_code">code</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>nonce: u256</code>
</dt>
<dd>

</dd>
<dt>
<code>storage: <a href="../../aptos-stdlib/doc/table.md#0x1_table_Table">table::Table</a>&lt;u256, u256&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0x1_evm_storage_AccountEvent"></a>

## Resource `AccountEvent`



<pre><code><b>struct</b> <a href="storage.md#0x1_evm_storage_AccountEvent">AccountEvent</a> <b>has</b> store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="@Constants_0"></a>

## Constants


<a id="0x1_evm_storage_CONVERT_BASE"></a>



<pre><code><b>const</b> <a href="storage.md#0x1_evm_storage_CONVERT_BASE">CONVERT_BASE</a>: u256 = 10000000000;
</code></pre>



<a id="0x1_evm_storage_ERROR_ACCOUNT_NOT_CREATED"></a>



<pre><code><b>const</b> <a href="storage.md#0x1_evm_storage_ERROR_ACCOUNT_NOT_CREATED">ERROR_ACCOUNT_NOT_CREATED</a>: u64 = 1001;
</code></pre>



<a id="0x1_evm_storage_ERROR_INSUFFIENT_BALANCE"></a>



<pre><code><b>const</b> <a href="storage.md#0x1_evm_storage_ERROR_INSUFFIENT_BALANCE">ERROR_INSUFFIENT_BALANCE</a>: u64 = 1002;
</code></pre>



<a id="0x1_evm_storage_get_move_address"></a>

## Function `get_move_address`



<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_get_move_address">get_move_address</a>(evm_address: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_get_move_address">get_move_address</a>(evm_address: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): <b>address</b> {
    to_address(to_32bit(evm_address))
}
</code></pre>



</details>

<a id="0x1_evm_storage_exist_account_storage"></a>

## Function `exist_account_storage`



<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_exist_account_storage">exist_account_storage</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_exist_account_storage">exist_account_storage</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): bool {
    <b>let</b> move_address = <a href="storage.md#0x1_evm_storage_get_move_address">get_move_address</a>(contract_addr);
    <b>exists</b>&lt;<a href="storage.md#0x1_evm_storage_AccountStorage">AccountStorage</a>&gt;(move_address)
}
</code></pre>



</details>

<a id="0x1_evm_storage_get_code_storage"></a>

## Function `get_code_storage`



<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_get_code_storage">get_code_storage</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_get_code_storage">get_code_storage</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; <b>acquires</b> <a href="storage.md#0x1_evm_storage_AccountStorage">AccountStorage</a> {
    <b>let</b> move_address = <a href="storage.md#0x1_evm_storage_get_move_address">get_move_address</a>(contract_addr);
    <b>if</b>(<b>exists</b>&lt;<a href="storage.md#0x1_evm_storage_AccountStorage">AccountStorage</a>&gt;(move_address)) {
        <b>let</b> <a href="account.md#0x1_account">account</a> = <b>borrow_global</b>&lt;<a href="storage.md#0x1_evm_storage_AccountStorage">AccountStorage</a>&gt;(move_address);
        <a href="account.md#0x1_account">account</a>.<a href="code.md#0x1_code">code</a>
    } <b>else</b> {
        x""
    }
}
</code></pre>



</details>

<a id="0x1_evm_storage_get_state_storage"></a>

## Function `get_state_storage`



<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_get_state_storage">get_state_storage</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_get_state_storage">get_state_storage</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256): u256 <b>acquires</b> <a href="storage.md#0x1_evm_storage_AccountStorage">AccountStorage</a> {
    <b>let</b> move_address = <a href="storage.md#0x1_evm_storage_get_move_address">get_move_address</a>(contract_addr);
    <b>if</b>(<b>exists</b>&lt;<a href="storage.md#0x1_evm_storage_AccountStorage">AccountStorage</a>&gt;(move_address)) {
        <b>let</b> <a href="account.md#0x1_account">account</a> = <b>borrow_global</b>&lt;<a href="storage.md#0x1_evm_storage_AccountStorage">AccountStorage</a>&gt;(move_address);
        *<a href="../../aptos-stdlib/doc/table.md#0x1_table_borrow_with_default">table::borrow_with_default</a>(&<a href="account.md#0x1_account">account</a>.storage, key, &0)
    } <b>else</b> {
        0
    }
}
</code></pre>



</details>

<a id="0x1_evm_storage_save_account_state"></a>

## Function `save_account_state`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="storage.md#0x1_evm_storage_save_account_state">save_account_state</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, keys: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, values: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="storage.md#0x1_evm_storage_save_account_state">save_account_state</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, keys: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, values: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;) <b>acquires</b> <a href="storage.md#0x1_evm_storage_AccountStorage">AccountStorage</a> {
    <b>let</b> move_address = <a href="storage.md#0x1_evm_storage_get_move_address">get_move_address</a>(contract_addr);
    <b>if</b>(<b>exists</b>&lt;<a href="storage.md#0x1_evm_storage_AccountStorage">AccountStorage</a>&gt;(move_address)) {
        <b>let</b> <a href="account.md#0x1_account">account</a> = <b>borrow_global_mut</b>&lt;<a href="storage.md#0x1_evm_storage_AccountStorage">AccountStorage</a>&gt;(move_address);
        <b>let</b> i = 0;
        <b>while</b>(i &lt; <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&keys)) {
            <a href="../../aptos-stdlib/doc/table.md#0x1_table_upsert">table::upsert</a>(&<b>mut</b> <a href="account.md#0x1_account">account</a>.storage, *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&keys, i), *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&values, i));
            i = i + 1;
        }
    }
}
</code></pre>



</details>

<a id="0x1_evm_storage_save_account_storage"></a>

## Function `save_account_storage`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="storage.md#0x1_evm_storage_save_account_storage">save_account_storage</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, balance: u256, <a href="code.md#0x1_code">code</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, nonce: u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="storage.md#0x1_evm_storage_save_account_storage">save_account_storage</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, balance: u256, <a href="code.md#0x1_code">code</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, nonce: u256) <b>acquires</b> <a href="storage.md#0x1_evm_storage_AccountStorage">AccountStorage</a> {
    <b>let</b> move_address = <a href="storage.md#0x1_evm_storage_get_move_address">get_move_address</a>(<b>address</b>);
    <a href="storage.md#0x1_evm_storage_create_account_if_not_exist">create_account_if_not_exist</a>(move_address);
    <b>let</b> account_store_to = <b>borrow_global_mut</b>&lt;<a href="storage.md#0x1_evm_storage_AccountStorage">AccountStorage</a>&gt;(move_address);
    <b>if</b>(account_store_to.nonce != nonce) {
        account_store_to.nonce = nonce;
    };

    <b>if</b>(account_store_to.balance != balance) {
        account_store_to.balance = balance;
    };

    <b>if</b>(account_store_to.<a href="code.md#0x1_code">code</a> != <a href="code.md#0x1_code">code</a>) {
        account_store_to.<a href="code.md#0x1_code">code</a> = <a href="code.md#0x1_code">code</a>;
    };
}
</code></pre>



</details>

<a id="0x1_evm_storage_load_account_storage"></a>

## Function `load_account_storage`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="storage.md#0x1_evm_storage_load_account_storage">load_account_storage</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): (u256, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="storage.md#0x1_evm_storage_load_account_storage">load_account_storage</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): (u256, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, u256) <b>acquires</b> <a href="storage.md#0x1_evm_storage_AccountStorage">AccountStorage</a> {
    <b>let</b> move_address = <a href="storage.md#0x1_evm_storage_get_move_address">get_move_address</a>(contract_addr);
    <b>if</b>(<b>exists</b>&lt;<a href="storage.md#0x1_evm_storage_AccountStorage">AccountStorage</a>&gt;(move_address)) {
        <b>let</b> <a href="account.md#0x1_account">account</a> = <b>borrow_global</b>&lt;<a href="storage.md#0x1_evm_storage_AccountStorage">AccountStorage</a>&gt;(<a href="storage.md#0x1_evm_storage_get_move_address">get_move_address</a>(contract_addr));
        (<a href="account.md#0x1_account">account</a>.balance, <a href="account.md#0x1_account">account</a>.<a href="code.md#0x1_code">code</a>, <a href="account.md#0x1_account">account</a>.nonce)
    } <b>else</b> {
        (0, x"", 0)
    }
}
</code></pre>



</details>

<a id="0x1_evm_storage_create_account_if_not_exist"></a>

## Function `create_account_if_not_exist`



<pre><code><b>fun</b> <a href="storage.md#0x1_evm_storage_create_account_if_not_exist">create_account_if_not_exist</a>(move_address: <b>address</b>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="storage.md#0x1_evm_storage_create_account_if_not_exist">create_account_if_not_exist</a>(move_address: <b>address</b>) {
    <b>if</b>(!<b>exists</b>&lt;<a href="storage.md#0x1_evm_storage_AccountStorage">AccountStorage</a>&gt;(move_address)) {
        <b>if</b>(!exists_at(move_address)) {
            create_account(move_address);
        };
        <b>move_to</b>(&<a href="create_signer.md#0x1_create_signer">create_signer</a>(move_address), <a href="storage.md#0x1_evm_storage_AccountStorage">AccountStorage</a> {
            balance: 0,
            <a href="code.md#0x1_code">code</a>: x"",
            nonce: 0,
            storage: <a href="../../aptos-stdlib/doc/table.md#0x1_table_new">table::new</a>()
        });
    }
}
</code></pre>



</details>

<a id="0x1_evm_storage_deposit_to"></a>

## Function `deposit_to`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="storage.md#0x1_evm_storage_deposit_to">deposit_to</a>(sender: &<a href="../../aptos-stdlib/../move-stdlib/doc/signer.md#0x1_signer">signer</a>, <b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, amount: u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="storage.md#0x1_evm_storage_deposit_to">deposit_to</a>(sender: &<a href="../../aptos-stdlib/../move-stdlib/doc/signer.md#0x1_signer">signer</a>, <b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, amount: u256) <b>acquires</b> <a href="storage.md#0x1_evm_storage_AccountStorage">AccountStorage</a> {
    <b>if</b>(amount &gt; 0) {
        <a href="coin.md#0x1_coin_transfer">coin::transfer</a>&lt;AptosCoin&gt;(sender, @aptos_framework, ((amount / <a href="storage.md#0x1_evm_storage_CONVERT_BASE">CONVERT_BASE</a>)  <b>as</b> u64));

        <b>let</b> move_address = <a href="storage.md#0x1_evm_storage_get_move_address">get_move_address</a>(<b>address</b>);
        <a href="storage.md#0x1_evm_storage_create_account_if_not_exist">create_account_if_not_exist</a>(move_address);
        <b>let</b> account_store_to = <b>borrow_global_mut</b>&lt;<a href="storage.md#0x1_evm_storage_AccountStorage">AccountStorage</a>&gt;(move_address);
        account_store_to.balance = account_store_to.balance + amount;
    }
}
</code></pre>



</details>

<a id="0x1_evm_storage_withdraw_from"></a>

## Function `withdraw_from`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="storage.md#0x1_evm_storage_withdraw_from">withdraw_from</a>(from: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="storage.md#0x1_evm_storage_withdraw_from">withdraw_from</a>(from: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;) <b>acquires</b> <a href="storage.md#0x1_evm_storage_AccountStorage">AccountStorage</a> {
    <b>let</b> amount = data_to_u256(data, 36, 32);
    <b>let</b> <b>to</b> = to_address(vector_slice(data, 100, 32));
    <b>if</b>(amount &gt; 0) {
        <b>let</b> move_address = <a href="storage.md#0x1_evm_storage_get_move_address">get_move_address</a>(from);
        <b>assert</b>!(<b>exists</b>&lt;<a href="storage.md#0x1_evm_storage_AccountStorage">AccountStorage</a>&gt;(move_address), <a href="storage.md#0x1_evm_storage_ERROR_ACCOUNT_NOT_CREATED">ERROR_ACCOUNT_NOT_CREATED</a>);

        <b>let</b> account_store_from = <b>borrow_global_mut</b>&lt;<a href="storage.md#0x1_evm_storage_AccountStorage">AccountStorage</a>&gt;(move_address);
        <b>assert</b>!(account_store_from.balance &gt;= amount, <a href="storage.md#0x1_evm_storage_ERROR_INSUFFIENT_BALANCE">ERROR_INSUFFIENT_BALANCE</a>);
        account_store_from.balance = account_store_from.balance - amount;

        <b>let</b> <a href="../../aptos-stdlib/../move-stdlib/doc/signer.md#0x1_signer">signer</a> = <a href="create_signer.md#0x1_create_signer">create_signer</a>(@aptos_framework);
        <a href="coin.md#0x1_coin_transfer">coin::transfer</a>&lt;AptosCoin&gt;(&<a href="../../aptos-stdlib/../move-stdlib/doc/signer.md#0x1_signer">signer</a>, <b>to</b>, ((amount / <a href="storage.md#0x1_evm_storage_CONVERT_BASE">CONVERT_BASE</a>)  <b>as</b> u64));
    }
}
</code></pre>



</details>


[move-book]: https://aptos.dev/move/book/SUMMARY

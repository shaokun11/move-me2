
<a id="0x1_evm_log"></a>

# Module `0x1::evm_log`



-  [Struct `Log`](#0x1_evm_log_Log)
-  [Struct `LogContext`](#0x1_evm_log_LogContext)
-  [Function `init_logs`](#0x1_evm_log_init_logs)
-  [Function `add_log`](#0x1_evm_log_add_log)
-  [Function `add_checkpoint`](#0x1_evm_log_add_checkpoint)
-  [Function `get_logs`](#0x1_evm_log_get_logs)
-  [Function `commit`](#0x1_evm_log_commit)
-  [Function `revert`](#0x1_evm_log_revert)


<pre><code><b>use</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">0x1::vector</a>;
</code></pre>



<a id="0x1_evm_log_Log"></a>

## Struct `Log`



<pre><code><b>struct</b> <a href="log.md#0x1_evm_log_Log">Log</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>topics: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0x1_evm_log_LogContext"></a>

## Struct `LogContext`



<pre><code><b>struct</b> <a href="log.md#0x1_evm_log_LogContext">LogContext</a> <b>has</b> drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>checkpoints: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="log.md#0x1_evm_log_Log">evm_log::Log</a>&gt;&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0x1_evm_log_init_logs"></a>

## Function `init_logs`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="log.md#0x1_evm_log_init_logs">init_logs</a>(): <a href="log.md#0x1_evm_log_LogContext">evm_log::LogContext</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="log.md#0x1_evm_log_init_logs">init_logs</a>(): <a href="log.md#0x1_evm_log_LogContext">LogContext</a> {
    <b>let</b> log_context = <a href="log.md#0x1_evm_log_LogContext">LogContext</a> {
        checkpoints: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_empty">vector::empty</a>()
    };
    <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(&<b>mut</b> log_context.checkpoints, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_empty">vector::empty</a>&lt;<a href="log.md#0x1_evm_log_Log">Log</a>&gt;());
    log_context
}
</code></pre>



</details>

<a id="0x1_evm_log_add_log"></a>

## Function `add_log`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="log.md#0x1_evm_log_add_log">add_log</a>(log_context: &<b>mut</b> <a href="log.md#0x1_evm_log_LogContext">evm_log::LogContext</a>, contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, topics: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="log.md#0x1_evm_log_add_log">add_log</a>(log_context: &<b>mut</b> <a href="log.md#0x1_evm_log_LogContext">LogContext</a>, contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, topics: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;) {
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&log_context.checkpoints);
    <b>let</b> checkpoint = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow_mut">vector::borrow_mut</a>(&<b>mut</b> log_context.checkpoints, len - 1);
    <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(checkpoint, <a href="log.md#0x1_evm_log_Log">Log</a> {
        contract,
        data,
        topics
    });
}
</code></pre>



</details>

<a id="0x1_evm_log_add_checkpoint"></a>

## Function `add_checkpoint`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="log.md#0x1_evm_log_add_checkpoint">add_checkpoint</a>(log_context: &<b>mut</b> <a href="log.md#0x1_evm_log_LogContext">evm_log::LogContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="log.md#0x1_evm_log_add_checkpoint">add_checkpoint</a>(log_context: &<b>mut</b> <a href="log.md#0x1_evm_log_LogContext">LogContext</a>) {
    <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(&<b>mut</b> log_context.checkpoints, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_empty">vector::empty</a>&lt;<a href="log.md#0x1_evm_log_Log">Log</a>&gt;());
}
</code></pre>



</details>

<a id="0x1_evm_log_get_logs"></a>

## Function `get_logs`



<pre><code><b>public</b> <b>fun</b> <a href="log.md#0x1_evm_log_get_logs">get_logs</a>(log_context: &<b>mut</b> <a href="log.md#0x1_evm_log_LogContext">evm_log::LogContext</a>): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="log.md#0x1_evm_log_Log">evm_log::Log</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="log.md#0x1_evm_log_get_logs">get_logs</a>(log_context: &<b>mut</b> <a href="log.md#0x1_evm_log_LogContext">LogContext</a>): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="log.md#0x1_evm_log_Log">Log</a>&gt; {
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&log_context.checkpoints);
    *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&<b>mut</b> log_context.checkpoints, len - 1)
}
</code></pre>



</details>

<a id="0x1_evm_log_commit"></a>

## Function `commit`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="log.md#0x1_evm_log_commit">commit</a>(log_context: &<b>mut</b> <a href="log.md#0x1_evm_log_LogContext">evm_log::LogContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="log.md#0x1_evm_log_commit">commit</a>(log_context: &<b>mut</b> <a href="log.md#0x1_evm_log_LogContext">LogContext</a>) {
    <b>let</b> data = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_pop_back">vector::pop_back</a>(&<b>mut</b> log_context.checkpoints);
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&log_context.checkpoints);
    <b>let</b> checkpoint = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow_mut">vector::borrow_mut</a>(&<b>mut</b> log_context.checkpoints, len - 1);
    for_each(data, |elem| <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(checkpoint, elem));
}
</code></pre>



</details>

<a id="0x1_evm_log_revert"></a>

## Function `revert`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="log.md#0x1_evm_log_revert">revert</a>(log_context: &<b>mut</b> <a href="log.md#0x1_evm_log_LogContext">evm_log::LogContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="log.md#0x1_evm_log_revert">revert</a>(log_context: &<b>mut</b> <a href="log.md#0x1_evm_log_LogContext">LogContext</a>) {
    <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_pop_back">vector::pop_back</a>(&<b>mut</b> log_context.checkpoints);
}
</code></pre>



</details>


[move-book]: https://aptos.dev/move/book/SUMMARY

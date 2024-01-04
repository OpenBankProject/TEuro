use aiken/hash.{Blake2b_224, Hash}
use aiken/list
use aiken/string
use aiken/transaction.{OutputReference, ScriptContext, Spend, TransactionId}
use aiken/transaction/credential.{VerificationKey}

type Datum {
  owner: Hash<Blake2b_224, VerificationKey>,
}

type Redeemer {
  msg: ByteArray,
}

validator {
  fn hello_world(
    datum: Datum,
    redeemer: Redeemer,
    context: ScriptContext,
  ) -> Bool {
    trace string.from_bytearray(redeemer.msg)
    {
      let must_say_hello = redeemer.msg == "Hello, World!"
      let must_be_signed =
        list.has(context.transaction.extra_signatories, datum.owner)
      must_say_hello? && must_be_signed?
    }
  }
}

test hello_world_example() {
  let datum =
    Datum { owner: #"00000000000000000000000000000000000000000000000000000000" }
  let redeemer = Redeemer { msg: "Aiken Rocks!" }
  let placeholder_utxo =
    OutputReference { transaction_id: TransactionId(""), output_index: 0 }
  let context =
    ScriptContext {
      purpose: Spend(placeholder_utxo),
      transaction: transaction.placeholder(),
    }
  hello_world(datum, redeemer, context)
}

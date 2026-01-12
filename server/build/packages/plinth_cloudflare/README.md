# Plinth Cloudflare

Run you Gleam programs on Cloudflare's "World Computer"/[ Developer Platform](https://developers.cloudflare.com/workers/)

[![Package Version](https://img.shields.io/hexpm/v/plinth_cloudflare)](https://hex.pm/packages/plinth_cloudflare)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/plinth_cloudflare/)

## 🚀 Get started

```sh
gleam add plinth_cloudflare@1
npm i --save-dev wrangler@4
```

src/my_app.gleam
```rs
pub fn fetch(request, env: dynamic.Dynamic, ctx: worker.Context) {
  let request = conversation.to_gleam_request(request)
  use response <- promise.map(do_fetch(request, env, ctx))
  conversation.to_js_response(response)
}

pub fn do_fetch(request, env, ctx) {
  response.new(200)
  |> response.set_body( "Hello Plinth!")
  |> promise.resolve
}
```

src/index.js
```js
import { fetch } from "./my_app.mjs";

export default {
  async fetch(request, env, ctx) {
    return fetch(request, env, ctx);
  },
};
```

wrangler.toml
```toml
name = "my_app"
main = "./build/dev/javascript/my_app/index.js"
compatibility_date = "2025-06-17"
```

Run locally with `npx wrangler dev`. Deploy with `npx wrangler deploy`

- Your applications entrypoint is the `fetch` function of your entrypoint worker.
  It is necessary to export a `fetch` function from your `index.js` file.
  Your gleam project doesn't have to use the name `fetch` but I often do for consistency

## 🔩 Accessing the platform

Why build on cloudflare? Because it has a variety of batteries included services.
These services are made available to your workers through bindings.
Bindings are configured in your `wrangler.toml` file.

The bound resources are available on the env passed to the fetch function.
You can access them using the `bindings` module.

For example, to access an R2 bucket:

```rs
import plinth/cloudflare/bindings
import plinth/cloudflare/r2

pub fn fetch(request, env)  {
  let assert Ok(bucket) = bindings.r2_bucket(env, "MY_BUCKET")
  use return <- promise.await(r2.get(bucket, key, r2.get_options()))
  case return {
    Ok(body) -> {
      use raw <- promise.await(r2.read_bytes(body))
      let assert Ok(body) = raw
      response.new(200)
      |> response.set_body(body)
      |> promise.resolve()
    }
    Error(_) ->
      response.new(404)
      |> response.set_body(<<"not found":utf8>>)
      |> promise.resolve()
  }
}
```

Plinth Cloudflare supports the following bindings:
- [D1](https://developers.cloudflare.com/d1/)
- [Durable Objects](https://developers.cloudflare.com/durable-objects/)
- [R2](https://developers.cloudflare.com/r2/)
- [Workflows](https://developers.cloudflare.com/workers/wrangler/workflows/)

Pull requests are welcome for the [remaining bindings](https://developers.cloudflare.com/workers/runtime-apis/bindings/). 

Further documentation can be found at <https://hexdocs.pm/plinth_cloudflare>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```

## Notes on the "world computer"

Cloudflare's platform is an interesting platform that abstracts away the physical hardware more than most.
For example if you build an actor on a durable object that will live for ever an be migrated for you potentially all around the world.

This is different to actors you might build on the BEAM.
The BEAM is very capable for building large distributed systems, however the core abstractions of processes and GenServers are bound to a machine.
If the machine running a process dies it the applications responsiblity to handle restart, data durability and consistency.

Should a permanent actor keep calls in the mailbox to callers who are transient?
Should any callers be transient. Client has session id that it uses to reconnect, include idempotency key

The following sections are some rough notes I have made build on cloudflare. I hope to turn them into more structured guidance with time.

### Maximum outbound connections

A single cloudflare worker can only have siz simultaneous outbound connections.
Additional connections will be queued.

### Reusing Id's

Getting an instance with the same Id will get access to the running flow, even if it has completed.
Workflows can be explicitly restarted.
Workflows do upgrade if restarted.

https://blog.cloudflare.com/workflows-ga-production-ready-durable-execution/


## Questions

### Do Gleam objects containing data types get serialized correctly?

They do not get serialized correctly.
The method for serialization is the [structured clone algorithm](https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API/Structured_clone_algorithm). The experiment with `postMessage` shows that an Ok type is not sent.
The [cloudflare version](https://developers.cloudflare.com/workers/runtime-apis/rpc/#structured-clonable-types-and-more) supports slightly more data types than the web version.
It supports application classes that extend `RpcTarget` but implementing this would require changes in the Gleam compiler.

User `Json` type to send data and potentially automatically decode for compound operations in `Flo`.
Plinth uses `Json` for postMessage, dagJson could allow sending binary to be easier.

TODO test if the classes are serialized when retrying but the workflow has not been restarted

```js
window.addEventListener('message', function(event) {
  console.log('Received message:', event.data);
  console.log('is Ok:', event.data.isOk && event.data.isOk());
  // This there is no isOk method on the data
});

window.postMessage('Hello, self!', '*');

class Ok {
  constructor(value) {
    // super();
    this[0] = value;
  }

  // @internal
  isOk() {
    return true;
  }
}

let value = new Ok(5)

console.log("before send", value.isOk())
// This returns true

window.postMessage(value, '*');
```

`isOk` is used in case so crucial that it is restored https://gleam.run/news/gleam-javascript-gets-30-percent-faster/

[The Ok definition](https://github.com/gleam-lang/gleam/blob/d3f4d9974b8a71002cb245c7317674643afc1fc5/compiler-core/templates/prelude.mjs#L1445)

### How are steps cached is it based on name, or name and position

TODO find a better example with looping

This blog post does a good job of showing what happens inside
https://blog.cloudflare.com/building-workflows-durable-execution-on-workers/#observability

TODO can I look with the same name

```js
let firstReturn = await step.do("same", async () => {
  console.log("first step")
  return "first step"
})
let secondReturn = await step.do("same", async () => {
  console.log("second step")
  if (x == 0) {
    x += 1
    throw "bad"
  }
  return "second step"
})
let final = Promise.all([firstReturn, secondReturn])
console.log("final", await final)
```

This runs correctly as long as the engine doesn't restart

### Do not rely on side effects of steps

The docs state [do note rely on STATE outside of a step]https://developers.cloudflare.com/workflows/build/rules-of-workflows/#do-not-rely-on-state-outside-of-a-step

I think that it's not so much "outside the step" but the steps side effects builds the list.

My best understanding is that calling `step.do` is implemented and runtime, No compiler tricks to find calls like in some meta frameworks.
When a step fails, but the engine is not restarted. That action for the failing step is restarted. 
If the engine is restarted then the script is run again, calls to `step.do` automatically return the previous output, and the script continues

```js
const x = await step.do("first step", async () => {
  const x = Math.random()
  return x
})

const y = Math.random()

const z = await step.do("second step", async () => {
  const z = Math.random()
  throw new Error("recoverable error")
})
```

So while the engine stays running the value of `y` is constant for each retry.
If the engine is restarted then `y` is recalculated.

If y was purely derived from x then it would be fine to calculate it outside of a step.


### Do steps that are not awaited on execute in parallel

The docs are not clear on this but do mention the use of promise await/all


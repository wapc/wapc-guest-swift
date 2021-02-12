# waPC Guest Library for Swift

This is the [Swift](https://swift.org/) implementation of the **waPC** standard
for WebAssembly guest modules. It allows any waPC-compliant WebAssembly host to
invoke to procedures inside a Swift compiled guest and similarly for the guest
to invoke procedures exposed by the host.

The Swift compiler provided by the [Swiftwasm](https://swiftwasm.org/) project
is required.

## Example

The following is a simple example of synchronous, bi-directional procedure calls
between a WebAssembly host runtime and the guest module.

```swift
import wapc

@_cdecl("__guest_call")
func __guest_call(operation_size: UInt, payload_size: UInt) -> Bool {
  return wapc.handleCall(operation_size: operation_size, payload_size: payload_size)
}

func hello(payload: String) -> String {
  // call the host from the Wasm module
  let hostMsg = wapc.hostCall(
    binding: "binding_name",
    namespace: "namespace_name",
    operation: "operation_name",
    payload: "that's the payload"
  )

  if hostMsg == nil {
    return "the validate function called the host but something went wrong"
  }
  return "the validate function called the host and received back: '\(hostMsg!)'"
}

// register the function
wapc.registerFunction(name: "hello", fn: hello)
```

The Wasm module **must** declare a `__guest_call` function and export it. The
linker must be instructed to export this function (see the
[official documentation](https://book.swiftwasm.org/examples/exporting-function.html)).

When using SwiftPM to manage a package, the linker can be instruted 
by adding few lines to the `Packages.swift` file:

```swift
.target(
    name: "demo",
    dependencies: ["wapc"],
    linkerSettings: [
        .unsafeFlags(
            [
                "-Xlinker",
                "--export=__guest_call",
            ]
        )
    ]
),
```

### Working example

[This GitHub repository](https://github.com/flavio/wapc-swift-demo) contains
a full working example.

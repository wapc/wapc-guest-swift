import wapc_ffi
import Foundation

public func handleCall(operation_size: UInt, payload_size: UInt) -> Bool {
    let operationBuf = UnsafeMutablePointer<Int8>.allocate(capacity: Int(operation_size) + 1)
    let payloadBuf = UnsafeMutablePointer<Int8>.allocate(capacity: Int(payload_size) + 1)
    defer {
        operationBuf.deinitialize(count: Int(operation_size) + 1)
        operationBuf.deallocate()

        payloadBuf.deinitialize(count: Int(payload_size) + 1)
        payloadBuf.deallocate()
    }

    __guest_request(operationBuf, payloadBuf)

    // Add NULL terminations
    let tailOperationBuf = operationBuf + Int(operation_size)
    tailOperationBuf.pointee = 0

    let tailPayloadBuf = payloadBuf + Int(payload_size)
    tailPayloadBuf.pointee = 0

    let operation = String(cString: operationBuf)
    let payload = String(cString: payloadBuf)

    let fn = wapcFunctions[operation]
    if fn != nil {
        let result = fn!(payload)

        result.withCString {
            __guest_response($0, result.utf8.count)
        }
        return true
    }

    let error = "Uknown function '\(operation)'"
    error.withCString {
        __guest_error($0, error.utf8.count);
    }
    return false
}

public func hostCall(
    binding: String,
    namespace: String,
    operation: String,
    payload: String) -> String? {
    let bindingBuf = binding.cString(using: String.Encoding.utf8)
    let namespaceBuf = namespace.cString(using: String.Encoding.utf8)
    let operationBuf = operation.cString(using: String.Encoding.utf8)
    let payloadBuf = payload.cString(using: String.Encoding.utf8)

    let result = __host_call(
        bindingBuf!, binding.utf8.count,
        namespaceBuf, namespace.utf8.count,
        operationBuf, operation.utf8.count,
        payloadBuf, payload.utf8.count)
    if (!result) {
        let errorLen = __host_error_len()
        let errorBuf = UnsafeMutablePointer<Int8>.allocate(capacity: Int(errorLen) + 1)
        defer {
            errorBuf.deinitialize(count: Int(errorLen) + 1)
            errorBuf.deallocate()
        }
        __host_error(errorBuf)

        // Add NULL terminations
        let tailErrorBuf = errorBuf + Int(errorLen)
        tailErrorBuf.pointee = 0

        let error = String(cString: errorBuf)

        consoleLog(msg: "Host error: \(error)")

        return nil
    }

    let responseLen = __host_response_len()
    let responseBuf = UnsafeMutablePointer<Int8>.allocate(capacity: Int(responseLen) + 1)
    defer {
        responseBuf.deinitialize(count: Int(responseLen) + 1)
        responseBuf.deallocate()
    }
    __host_response(responseBuf)

    // Add NULL terminations
    let tailResponseBuf = responseBuf + Int(responseLen)
    tailResponseBuf.pointee = 0

    return String(cString: responseBuf)
}

public func consoleLog(msg: String) {
    let msgBuf = msg.cString(using: String.Encoding.utf8)
    __console_log(msgBuf, msg.utf8.count)
}

public func registerFunction(name: String, fn: @escaping (String) -> String) {
    wapcFunctions[name] = fn
}

var wapcFunctions: Dictionary<String, (String) -> String> = [:]

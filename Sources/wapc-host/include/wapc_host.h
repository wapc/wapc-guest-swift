#ifndef __WAPC_HOST_H__
#define __WAPC_HOST_H__

#include <stdlib.h>
#include <stdbool.h>

__attribute__((__import_module__("wapc"), __import_name__("__guest_request"))) extern void
__guest_request(char *operation, char *payload);

__attribute__((__import_module__("wapc"), __import_name__("__guest_response"))) extern void
__guest_response(const char *payload, size_t len);

__attribute__((__import_module__("wapc"), __import_name__("__guest_error"))) extern void
__guest_error(const char *payload, size_t len);

__attribute__((__import_module__("wapc"), __import_name__("__host_call"))) extern bool
__host_call(
    const char *binding_payload, size_t binding_len,
    const char *namespace_payload, size_t namespace_len,
    const char *operation_payload, size_t operation_len,
    const char *payload, size_t payload_len);

__attribute__((__import_module__("wapc"), __import_name__("__host_response_len"))) extern size_t
__host_response_len(void);

__attribute__((__import_module__("wapc"), __import_name__("__host_response"))) extern void
__host_response(char *payload);

__attribute__((__import_module__("wapc"), __import_name__("__host_error_len"))) extern size_t
__host_error_len(void);

__attribute__((__import_module__("wapc"), __import_name__("__host_error"))) extern void
__host_error(char *payload);

__attribute__((__import_module__("wapc"), __import_name__("__console_log"))) extern void
__console_log(const char *payload, size_t payload_len);

#endif
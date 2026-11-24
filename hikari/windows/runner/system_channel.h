#ifndef RUNNER_SYSTEM_CHANNEL_H_
#define RUNNER_SYSTEM_CHANNEL_H_

#include <flutter/binary_messenger.h>

namespace hikari {

// Регистрирует MethodChannel('hikari/system') для установки обоев и темы.
void RegisterSystemChannel(flutter::BinaryMessenger* messenger);

}  // namespace hikari

#endif  // RUNNER_SYSTEM_CHANNEL_H_

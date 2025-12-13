/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <react/renderer/components/rive/EventEmitters.h>


namespace facebook {
namespace react {

void RiveReactNativeViewEventEmitter::onPlay(OnPlay $event) const {
  dispatchEvent("play", [$event=std::move($event)](jsi::Runtime &runtime) {
    auto $payload = jsi::Object(runtime);
    $payload.setProperty(runtime, "animationName", $event.animationName);
$payload.setProperty(runtime, "isStateMachine", $event.isStateMachine);
    return $payload;
  });
}


void RiveReactNativeViewEventEmitter::onPause(OnPause $event) const {
  dispatchEvent("pause", [$event=std::move($event)](jsi::Runtime &runtime) {
    auto $payload = jsi::Object(runtime);
    $payload.setProperty(runtime, "animationName", $event.animationName);
$payload.setProperty(runtime, "isStateMachine", $event.isStateMachine);
    return $payload;
  });
}


void RiveReactNativeViewEventEmitter::onStop(OnStop $event) const {
  dispatchEvent("stop", [$event=std::move($event)](jsi::Runtime &runtime) {
    auto $payload = jsi::Object(runtime);
    $payload.setProperty(runtime, "animationName", $event.animationName);
$payload.setProperty(runtime, "isStateMachine", $event.isStateMachine);
    return $payload;
  });
}


void RiveReactNativeViewEventEmitter::onStateChanged(OnStateChanged $event) const {
  dispatchEvent("stateChanged", [$event=std::move($event)](jsi::Runtime &runtime) {
    auto $payload = jsi::Object(runtime);
    $payload.setProperty(runtime, "stateMachineName", $event.stateMachineName);
$payload.setProperty(runtime, "stateName", $event.stateName);
    return $payload;
  });
}


void RiveReactNativeViewEventEmitter::onError(OnError $event) const {
  dispatchEvent("error", [$event=std::move($event)](jsi::Runtime &runtime) {
    auto $payload = jsi::Object(runtime);
    $payload.setProperty(runtime, "type", $event.type);
$payload.setProperty(runtime, "message", $event.message);
    return $payload;
  });
}

} // namespace react
} // namespace facebook

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

#pragma once

#include <react/renderer/components/view/ViewEventEmitter.h>


namespace facebook {
namespace react {
class RiveReactNativeViewEventEmitter : public ViewEventEmitter {
 public:
  using ViewEventEmitter::ViewEventEmitter;

  struct OnPlay {
      std::string animationName;
    bool isStateMachine;
    };

  struct OnPause {
      std::string animationName;
    bool isStateMachine;
    };

  struct OnStop {
      std::string animationName;
    bool isStateMachine;
    };

  struct OnStateChanged {
      std::string stateMachineName;
    std::string stateName;
    };

  struct OnError {
      std::string type;
    std::string message;
    };
  void onPlay(OnPlay value) const;

  void onPause(OnPause value) const;

  void onStop(OnStop value) const;

  void onStateChanged(OnStateChanged value) const;

  void onError(OnError value) const;
};
} // namespace react
} // namespace facebook

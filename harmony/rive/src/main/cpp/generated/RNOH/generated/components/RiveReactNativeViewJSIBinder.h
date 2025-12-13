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
#include "RNOHCorePackage/ComponentBinders/ViewComponentJSIBinder.h"

namespace rnoh {
class RiveReactNativeViewJSIBinder : public ViewComponentJSIBinder {
  protected:
    facebook::jsi::Object createNativeProps(facebook::jsi::Runtime &rt) override {
        auto object = ViewComponentJSIBinder::createNativeProps(rt);
        object.setProperty(rt, "isUserHandlingErrors", true);
        object.setProperty(rt, "autoplay", true);
        object.setProperty(rt, "fit", true);
        object.setProperty(rt, "layoutScaleFactor", true);
        object.setProperty(rt, "alignment", true);
        object.setProperty(rt, "artboardName", true);
        object.setProperty(rt, "animationName", true);
        object.setProperty(rt, "stateMachineName", true);
        object.setProperty(rt, "resourceName", true);
        object.setProperty(rt, "url", true);
        object.setProperty(rt, "testID", true);
        object.setProperty(rt, "dataBinding", true);
        object.setProperty(rt, "referencedAssets", true);
        return object;
    }

    facebook::jsi::Object createCommands(facebook::jsi::Runtime &rt) override {
        auto commands = ViewComponentJSIBinder::createCommands(rt);
        return commands;
    }

    facebook::jsi::Object createBubblingEventTypes(facebook::jsi::Runtime &rt) override {
        facebook::jsi::Object events(rt);
        events.setProperty(rt, "topPlay", createBubblingCapturedEvent(rt, "onPlay"));
        events.setProperty(rt, "topPause", createBubblingCapturedEvent(rt, "onPause"));
        events.setProperty(rt, "topStop", createBubblingCapturedEvent(rt, "onStop"));
        events.setProperty(rt, "topStateChanged", createBubblingCapturedEvent(rt, "onStateChanged"));
        events.setProperty(rt, "topError", createBubblingCapturedEvent(rt, "onError"));
        return events;
    }

    facebook::jsi::Object createDirectEventTypes(facebook::jsi::Runtime &rt) override {
        facebook::jsi::Object events(rt);
        return events;
    }
};
} // namespace rnoh

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

#include <react/renderer/components/rive/ComponentDescriptors.h>
#include "RNOH/Package.h"
#include "RNOH/ArkTSTurboModule.h"
#include "RNOH/generated/turbo_modules/RiveReactNativeModule.h"
#include "RNOH/generated/components/RiveReactNativeViewJSIBinder.h"

namespace rnoh {

class BaseRivePackageTurboModuleFactoryDelegate : public TurboModuleFactoryDelegate {
  public:
    SharedTurboModule createTurboModule(Context ctx, const std::string &name) const override {
        if (name == "RiveReactNativeModule") {
            return std::make_shared<RiveReactNativeModule>(ctx, name);
        }
        return nullptr;
    };
};



class BaseRivePackage : public Package {
  public:
    BaseRivePackage(Package::Context ctx) : Package(ctx){};

    std::unique_ptr<TurboModuleFactoryDelegate> createTurboModuleFactoryDelegate() override {
        return std::make_unique<BaseRivePackageTurboModuleFactoryDelegate>();
    }

    std::vector<facebook::react::ComponentDescriptorProvider> createComponentDescriptorProviders() override {
        return {
            facebook::react::concreteComponentDescriptorProvider<facebook::react::RiveReactNativeViewComponentDescriptor>(),
        };
    }

    ComponentJSIBinderByString createComponentJSIBinderByName() override {
        return {
            {"RiveReactNativeView", std::make_shared<RiveReactNativeViewJSIBinder>()},
        };
    };
    
};

} // namespace rnoh

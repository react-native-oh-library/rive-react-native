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

#include "RiveReactNativeModule.h"

namespace rnoh {
using namespace facebook;

RiveReactNativeModule::RiveReactNativeModule(const ArkTSTurboModule::Context ctx, const std::string name) : ArkTSTurboModule(ctx, name) {
    methodMap_ = {
        ARK_ASYNC_METHOD_METADATA(getBooleanState, 2),
        ARK_ASYNC_METHOD_METADATA(getNumberState, 2),
        ARK_ASYNC_METHOD_METADATA(getBooleanStateAtPath, 3),
        ARK_ASYNC_METHOD_METADATA(getNumberStateAtPath, 3),
    };
}

} // namespace rnoh

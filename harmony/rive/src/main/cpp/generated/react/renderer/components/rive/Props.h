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

#include <react/renderer/components/view/ViewProps.h>
#include <react/renderer/core/PropsParserContext.h>

namespace facebook {
namespace react {

class RiveReactNativeViewProps final : public ViewProps {
 public:
  RiveReactNativeViewProps() = default;
  RiveReactNativeViewProps(const PropsParserContext& context, const RiveReactNativeViewProps &sourceProps, const RawProps &rawProps);

#pragma mark - Props

};

} // namespace react
} // namespace facebook

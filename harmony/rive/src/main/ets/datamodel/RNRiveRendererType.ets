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
 
import { RendererType } from "rive_ohos";

export enum RNRiveRendererType {
  Rive = 'rive',
  Canvas = 'canvas'
}

const RNRiveRendererTypeValues = [
  RNRiveRendererType.Rive,
  RNRiveRendererType.Canvas
];

export class RNRiveRendererTypeUtil {

  static mapToRNRiveRendererType(rendererType: string): RNRiveRendererType {
    for (const type of RNRiveRendererTypeValues) {
      if (type === rendererType) {
        return type;
      }
    }
    throw new Error(`No enum constant for renderer type: ${rendererType}`);
  }

  static mapToRiveRendererType(rnRendererType: RNRiveRendererType): RendererType {
    switch (rnRendererType) {
      case RNRiveRendererType.Rive:
        return RendererType.Rive;
      case RNRiveRendererType.Canvas:
        return RendererType.Canvas;
      default:
        throw new Error(`Unsupported renderer type: ${rnRendererType}`);
    }
  }
}
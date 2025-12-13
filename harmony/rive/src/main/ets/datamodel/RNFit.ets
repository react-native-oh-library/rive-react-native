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

import {Fit} from 'rive_ohos'

export enum RNFit {
  Cover = 'cover',
  Contain = 'contain',
  Fill = 'fill',
  FitWidth = 'fitWidth',
  FitHeight = 'fitHeight',
  None = 'none',
  ScaleDown = 'scaleDown',
  Layout = 'layout',
}

export namespace RNFitUtils {
  /**
   * 将字符串转换为 RNFit 枚举
   * @param fit 适配模式字符串（如 "cover"、"fitWidth"）
   * @returns 对应的 RNFit 枚举值
   * @throws 当输入字符串不匹配任何枚举值时抛出错误
   */
  export function mapToRNFit(fit: string): RNFit {
    const enumValue = Object.values(RNFit).find(value => value === fit);

    if (!enumValue) {
      throw new Error(`Unsupported fit string: ${fit}. Valid values are: ${Object.values(RNFit).join(', ')}`);
    }

    return enumValue;
  }

  /**
   * 将 RNFit 枚举转换为 Rive 原生 Fit 类型
   * @param rnFit RNFit 枚举值
   * @returns 对应的 Rive 原生 Fit 类型
   * @throws 理论上不会触发（穷尽检查确保覆盖所有枚举值）
   */
  export function mapToRiveFit(rnFit: RNFit): Fit {
    switch (rnFit) {
      case RNFit.Cover:
        return Fit.COVER;
      case RNFit.Contain:
        return Fit.CONTAIN;
      case RNFit.Fill:
        return Fit.FILL;
      case RNFit.FitWidth:
        return Fit.FIT_WIDTH; // 对应 Rive 原生的 FIT_WIDTH（下划线命名规范）
      case RNFit.FitHeight:
        return Fit.FIT_HEIGHT;
      case RNFit.None:
        return Fit.NONE;
      case RNFit.ScaleDown:
        return Fit.SCALE_DOWN;
      case RNFit.Layout:
        return Fit.LAYOUT;
      default:
      // 穷尽检查：新增枚举值时 TS 编译报错，避免遗漏映射
        const _exhaustiveCheck: never = rnFit;
        throw new Error(`Unsupported Fit type: ${_exhaustiveCheck}`);
    }
  }
}
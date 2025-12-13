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

import {Alignment} from 'rive_ohos'

export enum RNAlignment {
  TopLeft = 'topLeft',
  TopCenter = 'topCenter',
  TopRight = 'topRight',
  CenterLeft = 'centerLeft',
  Center = 'center',
  CenterRight = 'centerRight',
  BottomLeft = 'bottomLeft',
  BottomCenter = 'bottomCenter',
  BottomRight = 'bottomRight',
}

export namespace RNAlignmentUtils {
  /**
   * 将字符串转换为 RNAlignment 枚举
   * @param alignment 对齐方式字符串（如 "topLeft"）
   * @returns 对应的 RNAlignment 枚举值
   * @throws 当字符串不匹配任何枚举值时抛出错误
   */
  export function mapToRNAlignment(alignment: string): RNAlignment {
    // 验证输入字符串是否存在于枚举值中
    const enumValue = Object.values(RNAlignment).find(
      (value) => value === alignment
    );

    if (!enumValue) {
      throw new Error(`Unsupported alignment string: ${alignment}`);
    }

    return enumValue;
  }

  /**
   * 将 RNAlignment 转换为 Rive 原生 Alignment 类型
   * @param v RNAlignment 枚举值
   * @returns 对应的 Rive Alignment 类型
   * @throws 当传入不支持的枚举值时抛出错误
   */
  export function mapToRiveAlignment(v: RNAlignment): Alignment {
    switch (v) {
      case RNAlignment.TopLeft:
        return Alignment.TOP_LEFT;
      case RNAlignment.TopCenter:
        return Alignment.TOP_CENTER;
      case RNAlignment.TopRight:
        return Alignment.TOP_RIGHT;
      case RNAlignment.CenterLeft:
        return Alignment.CENTER_LEFT;
      case RNAlignment.Center:
        return Alignment.CENTER;
      case RNAlignment.CenterRight:
        return Alignment.CENTER_RIGHT;
      case RNAlignment.BottomLeft:
        return Alignment.BOTTOM_LEFT;
      case RNAlignment.BottomCenter:
        return Alignment.BOTTOM_CENTER;
      case RNAlignment.BottomRight:
        return Alignment.BOTTOM_RIGHT;
      default:
      // 利用 TypeScript 穷尽检查，确保覆盖所有枚举值
        const _exhaustiveCheck: never = v;
        throw new Error(`Unsupported Alignment type: ${_exhaustiveCheck}`);
    }
  }
}

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

import {Direction} from 'rive_ohos'

export enum RNDirection {
  Backwards = 'backwards',
  Auto = 'auto',
  Forwards = 'forwards',
}

export namespace RNDirectionUtils {
  /**
   * 将字符串转换为 RNDirection 枚举
   * @param direction 方向字符串（如 "backwards"）
   * @returns 对应的 RNDirection 枚举值
   * @throws 当字符串不匹配任何枚举值时抛出错误
   */
  export function mapToRNDirection(direction: string): RNDirection {
    const enumValue = Object.values(RNDirection).find(
      (value) => value === direction
    );

    if (!enumValue) {
      throw new Error(`Unsupported direction string: ${direction}`);
    }

    return enumValue;
  }

  /**
   * 将 RNDirection 转换为 Rive 原生 Direction 类型
   * @param rnDirection RNDirection 枚举值
   * @returns 对应的 Rive Direction 类型
   * @throws 当传入不支持的枚举值时抛出错误（理论上不会触发，因有穷尽检查）
   */
  export function mapToRiveDirection(rnDirection: RNDirection): Direction {
    switch (rnDirection) {
      case RNDirection.Backwards:
        return Direction.BACKWARDS;
      case RNDirection.Auto:
        return Direction.AUTO;
      case RNDirection.Forwards:
        return Direction.FORWARDS;
      default:
      // 穷尽检查：确保所有枚举值都被覆盖，新增枚举时 TS 会编译报错
        const _exhaustiveCheck: never = rnDirection;
        throw new Error(`Unsupported Direction type: ${_exhaustiveCheck}`);
    }
  }
}

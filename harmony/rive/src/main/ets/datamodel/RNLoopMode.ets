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

import {Loop as RiveLoop} from 'rive_ohos'

export enum RNLoopMode {
  OneShot = 'oneShot',
  Loop = 'loop',
  PingPong = 'pingPong',
  Auto = 'auto',
}

export namespace RNLoopModeUtils {
  /**
   * 字符串 → RNLoopMode 枚举
   * @param loopMode 循环模式字符串（如 "oneShot"、"pingPong"）
   * @returns 对应的 RNLoopMode 枚举值
   * @throws 输入字符串不匹配时抛出错误（含合法值提示）
   */
  export function mapToRNLoopMode(loopMode: string): RNLoopMode;

  /**
   * Rive 原生 RiveLoop → RNLoopMode 枚举（双向映射重载）
   * @param riveLoopMode Rive 原生循环模式
   * @returns 对应的 RNLoopMode 枚举值
   * @throws 不支持的 RiveLoop 类型时抛出错误
   */
  export function mapToRNLoopMode(riveLoopMode: RiveLoop): RNLoopMode;

  // 实现重载逻辑
  export function mapToRNLoopMode(
    input: string | RiveLoop
  ): RNLoopMode {
    // 分支1：处理字符串输入
    if (typeof input === 'string') {
      const enumValue = Object.values(RNLoopMode).find(
        (value) => value === input
      );

      if (!enumValue) {
        throw new Error(
          `Unsupported loop mode string: ${input}. Valid values are: ${Object.values(RNLoopMode).join(', ')}`
        );
      }
      return enumValue;
    }

    // 分支2：处理 RiveLoop 输入（双向映射）
    switch (input) {
      case RiveLoop.ONESHOT:
        return RNLoopMode.OneShot;
      case RiveLoop.LOOP:
        return RNLoopMode.Loop;
      case RiveLoop.PINGPONG:
        return RNLoopMode.PingPong;
      case RiveLoop.AUTO:
        return RNLoopMode.Auto;
      default:
        const _exhaustiveCheck: never = input;
        throw new Error(`Unsupported RiveLoop type: ${_exhaustiveCheck}`);
    }
  }

  /**
   * RNLoopMode 枚举 → Rive 原生 RiveLoop 类型
   * @param rnLoopMode RNLoopMode 枚举值
   * @returns 对应的 Rive 原生循环模式
   * @throws 理论上不会触发（穷尽检查确保全覆盖）
   */
  export function mapToRiveLoop(rnLoopMode: RNLoopMode): RiveLoop {
    switch (rnLoopMode) {
      case RNLoopMode.OneShot:
        return RiveLoop.ONESHOT;
      case RNLoopMode.Loop:
        return RiveLoop.LOOP;
      case RNLoopMode.PingPong:
        return RiveLoop.PINGPONG;
      case RNLoopMode.Auto:
        return RiveLoop.AUTO;
      default:
        const _exhaustiveCheck: never = rnLoopMode;
        throw new Error(`Unsupported RNLoopMode type: ${_exhaustiveCheck}`);
    }
  }
}
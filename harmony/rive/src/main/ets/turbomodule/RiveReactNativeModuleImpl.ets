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

import { TurboModule } from '@rnoh/react-native-openharmony/ts';
import { RiveReactNativeModule } from '../generated/turboModules/RiveReactNativeModule';
import { RiveManager } from '../manager/RiveManager';
import { RiveNodeMapManager } from '../manager/RiveNodeMapManager';
import Logger from "../utils/Logger";


export class RiveReactNativeModuleImpl extends TurboModule implements RiveReactNativeModule.Spec {
  private TAG: string = "RiveReactNativeModuleImpl";

  getBooleanState(tag: number, inputName: string): Promise<boolean | null> {
    Logger.debug(this.TAG, "getBooleanState tag " + tag + " inputName " + inputName)
    const riveManager = RiveNodeMapManager.getInstance().riveNodeMap.get(tag);
    if (riveManager) {
      const obj = riveManager as RiveManager;
      return new Promise((resolve) => {
        resolve(obj.getBooleanState(inputName));
      });
    }
    return new Promise((resolve) => {
      resolve(false);
    });
  }

  getNumberState(tag: number, inputName: string): Promise<number | null> {
    Logger.debug(this.TAG, "getNumberState tag " + tag + " inputName " + inputName)
    const riveManager = RiveNodeMapManager.getInstance().riveNodeMap.get(tag);
    if (riveManager) {
      const obj = riveManager as RiveManager;
      return new Promise((resolve) => {
        resolve(obj.getNumberState(inputName));
      });
    }
    return new Promise((resolve) => {
      resolve(-1);
    });
  }

  getBooleanStateAtPath(tag: number, inputName: string, path: string): Promise<boolean | null> {
    Logger.debug(this.TAG, "getBooleanStateAtPath tag " + tag + " inputName " + inputName + " path " + path)
    const riveManager = RiveNodeMapManager.getInstance().riveNodeMap.get(tag);
    if (riveManager) {
      const obj = riveManager as RiveManager;
      return new Promise((resolve) => {
        resolve(obj.getBooleanStateAtPath(inputName, path));
      });
    }
    return new Promise((resolve) => {
      resolve(false);
    });
  }

  getNumberStateAtPath(tag: number, inputName: string, path: string): Promise<number | null> {
    Logger.debug(this.TAG, "getNumberStateAtPath tag " + tag + " inputName " + inputName + " path " + path)
    const riveManager = RiveNodeMapManager.getInstance().riveNodeMap.get(tag);
    if (riveManager) {
      const obj = riveManager as RiveManager;
      return new Promise((resolve) => {
        resolve(obj.getNumberStateAtPath(inputName, path));
      });
    }
    return new Promise((resolve) => {
      resolve(-1);
    });
  }
}
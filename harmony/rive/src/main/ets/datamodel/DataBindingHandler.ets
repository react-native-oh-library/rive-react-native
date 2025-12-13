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

import { RNOHContext } from '@rnoh/react-native-openharmony';
import {
  RiveAnimationView,
  ViewModel,
  ViewModelBooleanProperty,
  ViewModelColorProperty,
  ViewModelEnumProperty,
  ViewModelInstance,
  ViewModelNumberProperty,
  ViewModelStringProperty,
  ViewModelTriggerProperty
} from 'rive_ohos';
import { CommonManager } from '../manager/CommonManager';
import { DataBindingConfig } from './DataBindingConfig';
import { PropertyListener } from './PropertyListener';
import { RNPropertyType, RNPropertyTypeUtils } from './RNPropertyType';
import Logger from "../utils/Logger";

export class DataBindingHandler {
  private TAG: string = "DataBindingHandler"
  private shouldBeReloaded: boolean = false;
  private viewModel: ViewModel | undefined = undefined; // 假设 ViewModel 类型已定义
  private riveAnimationView: RiveAnimationView | undefined = undefined;
  private propertyListeners: Map<string, PropertyListener> | null = null;
  private ctx: RNOHContext | undefined = undefined;
  private viewTag: number = 0;

  constructor(ctx_: RNOHContext, viewModel_: ViewModel | undefined, riveAnimationView_: RiveAnimationView,
    propertyListeners_: Map<string, PropertyListener> | null, viewTag_: number) {
    this.ctx = ctx_;
    this.viewModel = viewModel_;
    this.riveAnimationView = riveAnimationView_;
    this.propertyListeners = propertyListeners_;
    this.viewTag = viewTag_;
  }


  removePropertyListener(key: string) {
    this.propertyListeners?.delete(key)
  }

  getViewModelInstance(): ViewModelInstance {
    return this.riveAnimationView?.controller?.activeArtboard?.viewModelInstance!!
  }


  registerPropertyListener(tag: number, path: string, propertyType: string) {
    Logger.debug(this.TAG, "registerPropertyListener tag " + tag + " path " + path + " propertyType " + propertyType);
    const key = propertyType + ":" + path + ":" + tag
    // Make sure to remove current listeners, as the same listener may have been registered but
    // on a new view model instance.
    // We play it safe and always remove the listener and re-add it
    this.removePropertyListener(key)

    const propertyTypeEnum = RNPropertyTypeUtils.mapToRNPropertyType(propertyType as string)

    try {
      const viewModelInstance = this.getViewModelInstance();
      let property: ViewModelStringProperty | ViewModelBooleanProperty | ViewModelNumberProperty | ViewModelTriggerProperty | ViewModelColorProperty | ViewModelEnumProperty;
      switch (propertyTypeEnum) {
        case RNPropertyType.String:
          property = viewModelInstance.getStringProperty(path)
      }
      switch (propertyTypeEnum) {
        case RNPropertyType.String:
          property = viewModelInstance.getStringProperty(path);
          break;
        case RNPropertyType.Boolean:
          property = viewModelInstance.getBooleanProperty(path);
          break;
        case RNPropertyType.Number:
          property = viewModelInstance.getNumberProperty(path);
          break;
        case RNPropertyType.Color:
          property = viewModelInstance.getColorProperty(path);
          break;
        case RNPropertyType.Enum:
          property = viewModelInstance.getEnumProperty(path);
          break;
        case RNPropertyType.Trigger:
          property = viewModelInstance.getTriggerProperty(path);
          break;
        default:
          console.warn(`未支持的属性类型：${propertyTypeEnum}`);
      }

      if (propertyTypeEnum == RNPropertyType.Trigger) {
        CommonManager.sendEvent(this.ctx!!, key, "");
      } else {
        Logger.debug(this.TAG, "sendEvent key " + key + " value " + property!!.valueFlow.value);
        CommonManager.sendEvent(this.ctx!!, key, { value: property!!.valueFlow.value });
      }
      this.propertyListeners?.set(key, new PropertyListener(viewModelInstance, path, propertyType))
    } catch (e) {
      Logger.error(this.TAG, "Error registerPropertyListener " + JSON.stringify(e))
    }
  }


  bindInstance(instance: ViewModelInstance) {
    const stateMachines = this.riveAnimationView?.controller?.stateMachines;
    stateMachines?.values().next().value && (stateMachines.values().next().value = instance)
    const activeArtboard = this.riveAnimationView?.controller?.activeArtboard;
    activeArtboard && (activeArtboard.viewModelInstance = instance)
    this.propertyListeners?.forEach((listener) => {
      if (listener.instance != instance) {
        this.registerPropertyListener(this.viewTag, listener.path, listener.propertyType)
      }
    })
  }

  handleDataBindingConfig(dataBindingConfig: DataBindingConfig | null): boolean {
    if (dataBindingConfig === null) {
      return false;
    }

    switch (dataBindingConfig.type) {
      case 'AutoBind': {
        // Auto binding is done within the view creation
        // The whole view needs to be reloaded
        this.shouldBeReloaded = true;
        break;
      }

      case 'Index': {
        this.bindInstance(this.viewModel!!.createInstanceFromIndex(dataBindingConfig.index));
        break;
      }

      case 'Name': {
        this.bindInstance(this.viewModel!!.createInstanceFromName(dataBindingConfig.name));
        break;
      }

      case 'Empty': {
        this.bindInstance(this.viewModel!!.createBlankInstance());
        break;
      }
    }
    return this.shouldBeReloaded;
  }
}
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
import {
  Descriptor as ComponentDescriptor,
  ViewBaseProps,
  ViewRawProps,
  ViewDescriptorWrapperBase,
  RNInstance,
  Tag,
  RNComponentCommandReceiver,
  ViewPropsSelector,
} from "@rnoh/react-native-openharmony/ts"


export namespace RiveViewSpec {
  export const NAME = "RiveReactNativeView" as const

  export type RiveAssetRequireSource = number;

  export interface RiveAssetUriSource {
    uri: string;
  }

  export interface RiveAssetPackagedSource {
    fileName: string;
    path?: string; // only needed for Android assets
  }

  export interface FileAssetSource {
    sourceUrl?: string;
    sourceAsset?: string;
    sourceAssetId?: string;
    path?: string;
  }

  export type RiveAssetPropType =
    | RiveAssetRequireSource
      | RiveAssetUriSource
      | RiveAssetPackagedSource;

  export interface FileHandlerOptions {
    source: RiveAssetPropType | FileAssetSource;
  }

  export interface FilesHandledMapping {
    [assetName: string]: FileHandlerOptions;
  }

  export type DataBindBy =
    | { type: 'autobind'; value: boolean }
      | { type: 'index'; value: number }
      | { type: 'name'; value: string }
      | { type: 'empty' };

  export interface DirectRawProps {
    isUserHandlingErrors?: boolean;
    autoplay?: boolean;
    fit?: 'cover' | 'contain' | 'fill' | 'fitWidth' | 'fitHeight' | 'none' | 'scaleDown' | 'layout';
    layoutScaleFactor?: number;
    alignment?: 'topLeft' | 'topCenter' | 'topRight' | 'centerLeft' | 'center' | 'centerRight' | 'bottomLeft' | 'bottomCenter' | 'bottomRight';
    artboardName?: string;
    referencedAssets?: FilesHandledMapping;
    dataBinding?: DataBindBy;
    animationName?: string;
    stateMachineName?: string;
    resourceName?: string;
    url?: string;
    style?: Object;
    testID?: string;
  }

  export interface Props extends ViewBaseProps {}

  export interface State {}

  export interface RawProps extends ViewRawProps, DirectRawProps {}

  export class PropsSelector extends ViewPropsSelector<Props, RawProps> {
  }

  export type Descriptor = ComponentDescriptor<typeof NAME,
  Props,
  State,
  RawProps>;

  export class DescriptorWrapper extends ViewDescriptorWrapperBase<typeof NAME,
  Props,
  State,
  RawProps,
  PropsSelector> {
    protected createPropsSelector() {
      return new PropsSelector(this.descriptor.props, this.descriptor.rawProps)
    }
  }

  export interface EventPayloadByName {
    "started": {}
    "stopped": {}
    "initialized": {}
    "error": { error: string }
  }

  export class EventEmitter {
    constructor(private rnInstance: RNInstance, private tag: Tag) {
    }

    emit<TEventName extends keyof EventPayloadByName>(eventName: TEventName, payload: EventPayloadByName[TEventName]) {
      this.rnInstance.emitComponentEvent(this.tag, eventName, payload)
    }
  }

  export enum ViewManagerMethod {
    play = 'play',
    pause = 'pause',
    stop = 'stop',
    reset = 'reset',
    fireState = 'fireState',
    setBooleanState = 'setBooleanState',
    getBooleanState = 'getBooleanState',
    getBooleanStateAtPath = 'getBooleanStateAtPath',
    setNumberState = 'setNumberState',
    getNumberState = 'getNumberState',
    getNumberStateAtPath = 'getNumberStateAtPath',
    fireStateAtPath = 'fireStateAtPath',
    setBooleanStateAtPath = 'setBooleanStateAtPath',
    setNumberStateAtPath = 'setNumberStateAtPath',
    touchBegan = 'touchBegan',
    touchEnded = 'touchEnded',
    setTextRunValue = 'setTextRunValue',
    setTextRunValueAtPath = 'setTextRunValueAtPath',
    setBooleanPropertyValue = 'setBooleanPropertyValue',
    setStringPropertyValue = 'setStringPropertyValue',
    setNumberPropertyValue = 'setNumberPropertyValue',
    setColorPropertyValue = 'setColorPropertyValue',
    setEnumPropertyValue = 'setEnumPropertyValue',
    fireTriggerProperty = 'fireTriggerProperty',
    registerPropertyListener = 'registerPropertyListener',
  }

  export interface CommandArgvByName {
    "play": []
    "pause": []
    "stop": []
    "reset": []
    "fireState": []
    "setBooleanState": []
    "getBooleanState": []
    "getBooleanStateAtPath": []
    "setNumberState": []
    "getNumberState": []
    "getNumberStateAtPath": []
    "fireStateAtPath": []
    "setBooleanStateAtPath": []
    "setNumberStateAtPath": []
    "touchBegan": []
    "touchEnded": []
    "setTextRunValue": []
    "setTextRunValueAtPath": []
    "setBooleanPropertyValue": []
    "setStringPropertyValue": []
    "setNumberPropertyValue": []
    "setColorPropertyValue": []
    "setEnumPropertyValue": []
    "fireTriggerProperty": []
  }

  export class CommandReceiver {
    private listenersByCommandName = new Map<string, Set<(...args: any[]) => void>>()
    private cleanUp: (() => void) | undefined = undefined

    constructor(private componentCommandReceiver: RNComponentCommandReceiver, private tag: Tag) {
    }

    subscribe<TCommandName extends keyof CommandArgvByName>(commandName: TCommandName,
      listener: (argv: CommandArgvByName[TCommandName]) => void) {
      if (!this.listenersByCommandName.has(commandName)) {
        this.listenersByCommandName.set(commandName, new Set())
      }
      this.listenersByCommandName.get(commandName)!.add(listener)
      const hasRegisteredCommandReceiver = !!this.cleanUp
      if (!hasRegisteredCommandReceiver) {
        this.cleanUp =
          this.componentCommandReceiver.registerCommandCallback(this.tag, (commandName: string, argv: any[]) => {
            if (this.listenersByCommandName.has(commandName)) {
              const listeners = this.listenersByCommandName.get(commandName)!
              listeners.forEach(listener => {
                listener(argv)
              })
            }
          })
      }

      return () => {
        this.listenersByCommandName.get(commandName)?.delete(listener)
        if (this.listenersByCommandName.get(commandName)?.size ?? 0 === 0) {
          this.listenersByCommandName.delete(commandName)
        }
        if (this.listenersByCommandName.size === 0) {
          this.cleanUp?.()
        }
      }
    }
  }

}
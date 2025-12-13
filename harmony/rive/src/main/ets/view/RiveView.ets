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

import { RNComponentContext, RNViewBase } from '@rnoh/react-native-openharmony';
import Logger from '../utils/Logger';
import { RiveViewSpec } from './props/RiveSpec';
import { RNLoopModeUtils } from '../datamodel/RNLoopMode';
import { RNDirectionUtils } from '../datamodel/RNDirection';
import { RiveManager } from '../manager/RiveManager';
import { initializeRive, Loop, RiveAnimationView } from 'rive_ohos';
import { RNFitUtils } from '../datamodel/RNFit';
import { RNAlignmentUtils } from '../datamodel/RNAlignment';
import { RiveNodeMapManager } from '../manager/RiveNodeMapManager';
import { FilesHandledMappingConverter, ReadableNativeMap } from '../datamodel/ReadableMap';


@Component
export struct RiveView {
  private TAG: string = 'RiveView'
  public static readonly NAME = RiveViewSpec.NAME
  public ctx!: RNComponentContext
  public tag: number = 0
  @State private descriptorWrapper: RiveViewSpec.DescriptorWrapper =
    {} as RiveViewSpec.DescriptorWrapper
  private cleanUpCallbacks: (() => void)[] = []
  private cleanCommandCallback?: () => void;
  private riveManager: RiveManager | undefined = undefined;
  private prevProps: RiveViewSpec.RawProps | undefined = undefined;
  private isUpdateProps: boolean = false;
  private currentProps: RiveViewSpec.RawProps | undefined = undefined;

  aboutToAppear() {
    Logger.debug(this.TAG, "RiveAnimationView aboutToAppear")
    initializeRive()
    this.onDescriptorWrapperChange(this.ctx.descriptorRegistry.findDescriptorWrapperByTag<RiveViewSpec.DescriptorWrapper>(this.tag)!)
    this.cleanUpCallbacks.push(this.ctx.descriptorRegistry.subscribeToDescriptorChanges(this.tag,
      (_descriptor, newDescriptorWrapper) => {
        this.onDescriptorWrapperChange(newDescriptorWrapper! as RiveViewSpec.DescriptorWrapper)
      }
    ))
    const descriptorBase = this.descriptorWrapper['descriptor'];
    const props = descriptorBase.rawProps;
    Logger.debug(this.TAG, " aboutToAppear props " + JSON.stringify(props));
    this.registerCommandCallback();
  }

  private onDescriptorWrapperChange(descriptorWrapper: RiveViewSpec.DescriptorWrapper) {
    this.descriptorWrapper = descriptorWrapper;
    const descriptorBase = descriptorWrapper['descriptor'];
    const props = descriptorBase.rawProps;
    this.currentProps = props;
    if (this.riveManager) {
      this.isUpdateProps = true;
      this.updateProps(props);
    }
  }

  async updateProps(props: RiveViewSpec.RawProps) {
    Logger.debug(this.TAG, "updateProps props " + JSON.stringify(props));
    if (props.resourceName !== undefined) {
      this.riveManager?.setResourceName(props.resourceName);
    }
    if (props.fit !== undefined) {
      this.riveManager?.setFit(RNFitUtils.mapToRNFit(props.fit));
    }
    if (props.layoutScaleFactor !== undefined) {
      this.riveManager?.setLayoutScaleFactor(props.layoutScaleFactor);
    }
    if (props.alignment !== undefined) {
      this.riveManager?.setAlignment(RNAlignmentUtils.mapToRNAlignment(props.alignment));
    }
    if (props.url !== undefined) {
      this.riveManager?.setUrl(props.url);
    }
    if (props.autoplay !== undefined) {
      this.riveManager?.setAutoplay(props.autoplay);
    }
    if (props.artboardName !== undefined) {
      this.riveManager?.setArtboardName(props.artboardName);
    }
    if (props.animationName !== undefined) {
      this.riveManager?.setAnimationName(props.animationName);
    }
    if (props.stateMachineName !== undefined) {
      this.riveManager?.setStateMachineName(props.stateMachineName);
    }
    if (props.referencedAssets !== undefined && this.prevProps?.referencedAssets !== props.referencedAssets) {
      const readableNativeMap = new ReadableNativeMap(FilesHandledMappingConverter.toRecord(props.referencedAssets));
      await this.riveManager?.setReferencedAssets(readableNativeMap);
    }
    if (props.isUserHandlingErrors) {
      this.riveManager?.setIsUserHandlingErrors(props.isUserHandlingErrors);
    }
    if (props.dataBinding !== undefined && this.prevProps?.dataBinding !== props.dataBinding) {
      this.riveManager?.setDataBinding(props.dataBinding)
    }
    this.riveManager?.reloadIfNeeded();
    this.prevProps = props;
  }

  private registerCommandCallback() {
    if (this.ctx) {
      this.cleanCommandCallback = this.ctx.componentCommandReceiver.registerCommandCallback(
        this.tag,
        async (command, args: (string | number | boolean | object)[]) => {
          Logger.debug(this.TAG, "registerCommandCallback command " + command + " args " + JSON.stringify(args));
          if (command === RiveViewSpec.ViewManagerMethod.play) {
            const animationName = args[0];
            const loopMode = args[1];
            const direction = args[2];
            const isStateMachine = args[3];
            const rnLoopMode = RNLoopModeUtils.mapToRNLoopMode(loopMode as Loop)
            const rnDirection = RNDirectionUtils.mapToRNDirection(direction as string)
            this.riveManager?.play(animationName as string, rnLoopMode, rnDirection, isStateMachine as boolean)
          }

          if (command === RiveViewSpec.ViewManagerMethod.pause) {
            this.riveManager?.pause();
          }

          if (command === RiveViewSpec.ViewManagerMethod.stop) {
            this.riveManager?.stop();
          }

          if (command === RiveViewSpec.ViewManagerMethod.reset) {
            this.riveManager?.reset();
          }

          if (command === RiveViewSpec.ViewManagerMethod.fireState) {
            const stateMachineName = args[0];
            const inputName = args[1];
            this.riveManager?.fireState(stateMachineName as string, inputName as string)
          }

          if (command === RiveViewSpec.ViewManagerMethod.setBooleanState) {
            const stateMachineName = args[0];
            const inputName = args[1];
            const value = args[2];
            this.riveManager?.setBooleanState(stateMachineName as string, inputName as string, value as boolean)
          }

          if (command === RiveViewSpec.ViewManagerMethod.setNumberState) {
            const stateMachineName = args[0];
            const inputName = args[1];
            const value = args[2];
            this.riveManager?.setNumberState(stateMachineName as string, inputName as string, value as number)
          }

          if (command === RiveViewSpec.ViewManagerMethod.fireStateAtPath) {
            const inputName = args[0];
            const path = args[1];
            this.riveManager?.fireStateAtPath(inputName as string, path as string)
          }

          if (command === RiveViewSpec.ViewManagerMethod.setBooleanStateAtPath) {
            const inputName = args[0];
            const value = args[1];
            const path = args[2];
            this.riveManager?.setBooleanStateAtPath(inputName as string, value as boolean, path as string);
          }

          if (command === RiveViewSpec.ViewManagerMethod.setNumberStateAtPath) {
            const inputName = args[0];
            const value = args[1];
            const path = args[2];
            this.riveManager?.setNumberStateAtPath(inputName as string, value as number, path as string);
          }

          if (command === RiveViewSpec.ViewManagerMethod.setBooleanPropertyValue) {
            const path = args[0];
            const value = args[1];
            this.riveManager?.setBooleanPropertyValue(path as string, value as boolean);
          }

          if (command === RiveViewSpec.ViewManagerMethod.setStringPropertyValue) {
            const path = args[0];
            const value = args[1];
            this.riveManager?.setStringPropertyValue(path as string, value as string);
          }

          if (command === RiveViewSpec.ViewManagerMethod.setNumberPropertyValue) {
            const path = args[0];
            const value = args[1];
            this.riveManager?.setNumberPropertyValue(path as string, value as number);
          }

          if (command === RiveViewSpec.ViewManagerMethod.setColorPropertyValue) {
            const path = args[0];
            const r = args[1];
            const g = args[2];
            const b = args[3];
            const a = args[4];
            this.riveManager?.setColorPropertyValue(path as string, r as number, g as number, b as number, a as number);
          }

          if (command === RiveViewSpec.ViewManagerMethod.setEnumPropertyValue) {
            const path = args[0];
            const value = args[1];
            this.riveManager?.setEnumPropertyValue(path as string, value as string);
          }


          if (command === RiveViewSpec.ViewManagerMethod.fireTriggerProperty) {
            const path = args[0];
            this.riveManager?.fireTriggerProperty(path as string);
          }


          if (command === RiveViewSpec.ViewManagerMethod.registerPropertyListener) {
            const path = args[0];
            const propertyType = args[1];
            const tag = args[2];
            this.riveManager?.registerPropertyListener(tag as number, path as string, propertyType as string);
          }

          if (command === RiveViewSpec.ViewManagerMethod.touchBegan) {
            const x = args[0];
            const y = args[1];
            this.riveManager?.touchBegan(x as number, y as number);
          }

          if (command === RiveViewSpec.ViewManagerMethod.touchEnded) {
            const x = args[0];
            const y = args[1];
            this.riveManager?.touchEnded(x as number, y as number);
          }

          if (command === RiveViewSpec.ViewManagerMethod.setTextRunValue) {
            const textRunName = args[0];
            const textValue = args[1];
            this.riveManager?.setTextRunValue(textRunName as string, textValue as string);
          }

          if (command === RiveViewSpec.ViewManagerMethod.setTextRunValueAtPath) {
            const textRunName = args[0];
            const textValue = args[1];
            const path = args[2];
            this.riveManager?.setTextRunValueAtPath(textRunName as string, textValue as string, path as string);
          }

        });
    }
  }

  build() {
    RNViewBase({
      ctx: this.ctx,
      tag: this.tag,
      controlsFocus: false
    }) {
      Stack({ alignContent: Alignment.Center }) {
        Column() {
          RiveAnimationView({
            onReady: (view) => {
              Logger.debug(this.TAG, "RiveAnimationView onReady success");
              if (!this.riveManager) {
                this.riveManager = new RiveManager(view, this.ctx, this.tag);
                RiveNodeMapManager.getInstance().riveNodeMap.set(this.tag, this.riveManager);
                if (!this.isUpdateProps && this.currentProps) {
                  this.isUpdateProps = true;
                  this.updateProps(this.currentProps);
                }
              }
            }
          })
        }
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .height('100%')
    }
  }

  aboutToDisappear(): void {
    Logger.debug(this.TAG, "RiveAnimationView aboutToDisappear")
    this.riveManager?.removeListeners();
  }
}
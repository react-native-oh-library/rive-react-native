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
import { RNAlignment, RNAlignmentUtils } from '../datamodel/RNAlignment';
import { RNDirection, RNDirectionUtils } from '../datamodel/RNDirection';
import { RNFit, RNFitUtils } from '../datamodel/RNFit';
import { RNLoopMode, RNLoopModeUtils } from '../datamodel/RNLoopMode';
import { RNRiveError, RNRiveErrorType } from '../datamodel/RNRiveError';
import {
  Alignment,
  AudioAsset,
  FileAsset,
  FontAsset,
  ImageAsset,
  Loop,
  PointerEvents,
  RiveAnimationView,
  RiveAudio,
  RiveEventListener,
  RiveException,
  RiveFileControllerListener,
  RiveFont,
  RiveRenderImage,
  SMIBoolean,
  SMINumber,
  ViewModel,
  ViewModelInstance
} from 'rive_ohos';
import { Fit } from 'rive_ohos/src/main/ets/runtime/core/Fit';
import LinearAnimationInstance from 'rive_ohos/src/main/ets/runtime/core/LinearAnimationInstance';
import Logger from '../utils/Logger';
import { PropertyListener } from '../datamodel/PropertyListener';
import { RiveFileControllerListenerImpl } from '../event/RiveFileControllerListenerImpl';
import { RiveEventListenerImpl } from '../event/RiveEventListenerImpl';
import { DataBindingConfig } from '../datamodel/DataBindingConfig';
import { DataBindingHandler } from '../datamodel/DataBindingHandler';
import { CommonManager } from './CommonManager';
import { RiveViewSpec } from '../view/props/RiveSpec';
import { RiveReactNativeAssetStore } from './RiveReactNativeAssetStore';
import { ReadableMap } from '../datamodel/ReadableMap';
import { FileUtils } from '../utils/FileUtils';
import { FileReadCallBack } from '../datamodel/FileReadCallBack';
import { RiveEvents } from '../event/RiveEvents';
import { LoadAssetCallBack } from '../datamodel/LoadAssetCallBack';
import { DownLoadNetUrlUtils } from '../utils/DownLoadNetUrlUtils';

export class RiveManager {
  private TAG: string = 'RiveManager'
  private riveAnimationView: RiveAnimationView | undefined = undefined;
  private url: string = "";
  private resourceName: string = ""
  private shouldBeReloaded: boolean = true
  private fit: Fit = Fit.COVER
  private alignment: Alignment = Alignment.CENTER
  private autoplay: boolean = true
  private isUserHandlingErrors: boolean = false
  private listener: RiveFileControllerListener | undefined = undefined
  private eventListener: RiveEventListener | undefined = undefined
  private dataBindingConfig: DataBindingConfig | null = null
  private artboardName: string | undefined = undefined
  private animationName: string | undefined = undefined
  private stateMachineName: string | undefined = undefined
  private referencedAssets: ReadableMap | undefined = undefined;
  private propertyListeners: Map<string, PropertyListener> | null = null;
  private ctx!: RNOHContext;
  private dataBindingHandler: DataBindingHandler | null = null;
  private viewTag: number = 0;
  private viewModel: ViewModel | undefined = undefined
  private assetStore: RiveReactNativeAssetStore | undefined = undefined
  private layoutScaleFactor: number = 0

  constructor(riveAnimationView_: RiveAnimationView, ctx_: RNOHContext, viewTag_: number) {
    this.riveAnimationView = riveAnimationView_;
    this.ctx = ctx_;
    this.viewTag = viewTag_;
    this.init();
  }


  init() {
    this.listener = new RiveFileControllerListenerImpl(this.ctx);
    this.eventListener = new RiveEventListenerImpl(this.ctx);
    this.addListeners()
    this.autoplay = false
  }


  play(animationName: string, rnLoopMode: RNLoopMode, rnDirection: RNDirection, isStateMachine: boolean) {
    const loop = RNLoopModeUtils.mapToRiveLoop(rnLoopMode)
    const direction = RNDirectionUtils.mapToRiveDirection(rnDirection)
    if (!animationName) {
      this.riveAnimationView?.play("", loop, direction)
    } else {
      try {
        this.riveAnimationView?.play(animationName, loop, direction, isStateMachine)
      } catch (ex) {
        this.handleRiveException(ex)
      }
    }
  }

  pause() {
    try {
      if (this.riveAnimationView?.getPlayingAnimations()?.size) {
        const animations = this.riveAnimationView?.getPlayingAnimations().values();
        const linear = animations.next().value as LinearAnimationInstance;
        this.riveAnimationView!!.pauseAnimation(linear.name)
      } else if (this.riveAnimationView?.getPlayingStateMachines()?.size) {
        const stateMachines = this.riveAnimationView?.getPlayingStateMachines().values();
        const linear = stateMachines.next().value as LinearAnimationInstance;
        this.riveAnimationView!!.pauseAnimation(linear.name, true)
      } else {
        this.riveAnimationView?.pause()
      }
    } catch (ex) {
      this.handleRiveException(ex)
    }
  }

  stop() {
    try {
      this.riveAnimationView?.stop()
    } catch (ex) {
      this.handleRiveException(ex)
    }
  }

  reset() {
    this.riveAnimationView?.reset();
  }

  touchBegan(x: number, y: number) {
    this.riveAnimationView?.controller?.pointerEvent(PointerEvents.POINTER_DOWN, 0, x, y)
  }


  touchEnded(x: number, y: number) {
    this.riveAnimationView?.controller?.pointerEvent(PointerEvents.POINTER_UP, 0, x, y)
  }

  setTextRunValue(textRunName: string, textValue: string) {
    try {
      this.riveAnimationView?.controller?.setTextRunValue(textRunName, textValue);
    } catch (ex) {
      this.handleRiveException(ex)
    }
  }

  setTextRunValueAtPath(textRunName: string, textValue: string, path: string) {
    try {
      this.riveAnimationView?.controller?.setTextRunValue(textRunName, textValue, path)
    } catch (ex) {
      this.handleRiveException(ex)
    }
  }


  getViewModelInstance(): ViewModelInstance {
    return this.riveAnimationView?.controller?.activeArtboard?.viewModelInstance!!
  }


  setBooleanPropertyValue(path: string, value: boolean) {
    try {
      const viewModelBooleanProperty = this.getViewModelInstance()?.getBooleanProperty(path);
      viewModelBooleanProperty.value = value;
      this.registerPropertyListener(this.viewTag, path, "boolean")
    } catch (ex) {
      this.handleRiveException(ex)
    }
  }

  setStringPropertyValue(path: string, value: string) {
    try {
      const viewModelStringProperty = this.getViewModelInstance()?.getStringProperty(path);
      viewModelStringProperty.value = value;
      this.registerPropertyListener(this.viewTag, path, "string")
    } catch (ex) {
      this.handleRiveException(ex)
    }
  }


  setNumberPropertyValue(path: string, value: number) {
    try {
      const viewModelNumberProperty = this.getViewModelInstance()?.getNumberProperty(path);
      viewModelNumberProperty.value = value;
      this.registerPropertyListener(this.viewTag, path, "number")
    } catch (ex) {
      this.handleRiveException(ex)
    }
  }

  setColorPropertyValue(path: string, r: number, g: number, b: number, a: number) {
    try {
      const color = ((a & 0xFF) << 24) | ((r & 0xFF) << 16) | ((g & 0xFF) << 8) | (b & 0xFF);
      const viewModelColorProperty = this.getViewModelInstance()?.getColorProperty(path);
      viewModelColorProperty.value = color;
      this.registerPropertyListener(this.viewTag, path, "color")
    } catch (ex) {
      this.handleRiveException(ex)
    }
  }

  setEnumPropertyValue(path: string, value: string) {
    try {
      const viewModelEnumProperty = this.getViewModelInstance()?.getEnumProperty(path);
      viewModelEnumProperty.value = value;
      this.registerPropertyListener(this.viewTag, path, "enum")
    } catch (ex) {
      this.handleRiveException(ex)
    }
  }

  fireTriggerProperty(path: string) {
    try {
      const viewModelTriggerProperty = this.getViewModelInstance()?.getTriggerProperty(path);
      viewModelTriggerProperty.trigger();
      this.registerPropertyListener(this.viewTag, path, "trigger")
    } catch (ex) {
      this.handleRiveException(ex)
    }
  }


  setResourceName(resourceName: string) {
    if (this.resourceName == resourceName) {
      return
    }
    this.resourceName = resourceName
    this.shouldBeReloaded = true
  }

  setFit(rnFit: RNFit) {
    const riveFit = RNFitUtils.mapToRiveFit(rnFit)
    if (this.fit == riveFit) {
      return
    }
    this.fit = riveFit
    this.riveAnimationView && (this.riveAnimationView.setFit(riveFit));
  }

  setLayoutScaleFactor(layoutScaleFactor: number) {
    this.layoutScaleFactor = layoutScaleFactor
    this.riveAnimationView && (this.riveAnimationView.setLayoutScaleFactor(layoutScaleFactor));
  }


  setAlignment(rnAlignment: RNAlignment) {
    const riveAlignment = RNAlignmentUtils.mapToRiveAlignment(rnAlignment)
    this.alignment = riveAlignment
    this.riveAnimationView && (this.riveAnimationView.setAlignment(riveAlignment));
  }

  setAutoplay(autoplay: boolean) {
    if (this.autoplay == autoplay) {
      return
    }
    this.autoplay = autoplay
    this.shouldBeReloaded = true;
  }

  setUrl(url: string) {
    if (this.url == url) {
      return
    }
    this.url = url
    this.shouldBeReloaded = true
  }

  setArtboardName(artboardName: string) {
    try {
      if (this.artboardName == artboardName) {
        return
      }
      this.artboardName = artboardName
      this.riveAnimationView && (this.riveAnimationView.setArtboardName(artboardName));
    } catch (ex) {
      this.handleRiveException(ex)
    }
  }

  setAnimationName(animationName: string) {
    if (this.animationName == animationName) {
      return
    }
    this.animationName = animationName
    this.shouldBeReloaded = true
  }


  private areSetsEqual<T>(set1: Set<T>, set2: Set<T>): boolean {
    if (set1.size !== set2.size) {
      return false;
    }
    for (const item of set1) {
      if (!set2.has(item)) {
        return false;
      }
    }
    return true;
  }

  setReferencedAssets(referencedAssets?: ReadableMap): void {
    if (this.referencedAssets?.toMap() == referencedAssets?.toMap()) {
      return;
    }
    const previousReferencedAssets = this.referencedAssets;
    this.referencedAssets = referencedAssets;
    if (previousReferencedAssets == null || referencedAssets == null) {
      this.shouldBeReloaded = true;
      return;
    }
    const previousKeys: string[] = previousReferencedAssets.importKeys();
    const newKeys: string[] = referencedAssets.importKeys();

    const previousKeysSet: Set<string> = new Set(previousKeys);
    const newKeysSet: Set<string> = new Set(newKeys);

    if (this.areSetsEqual(previousKeysSet, newKeysSet)) {
      this.shouldBeReloaded = true;
      return;
    }

    for (const key of newKeys) {
      const previousValue: ReadableMap | null = previousReferencedAssets.getMap(key);
      const newValue: ReadableMap | null = referencedAssets.getMap(key);
      if (previousValue?.toMap() != newValue?.toMap()) {
        const source = newValue?.getMap("source");
        const asset = this.assetStore?.cachedFileAssets?.get(key);
        if (source != null && asset != undefined) {
          this.loadAsset(source, asset);
        }
      }
    }
  }


  setDataBinding(dataBinding: RiveViewSpec.DataBindBy) {
    const oldDataBindingConfig = this.dataBindingConfig;
    if (dataBinding.type === "autobind") {
      this.dataBindingConfig = {
        type: 'AutoBind',
        autoBind: dataBinding.value
      };
    }
    if (dataBinding.type === "index") {
      this.dataBindingConfig = {
        type: 'Index',
        index: dataBinding.value
      };
    }
    if (dataBinding.type === "name") {
      this.dataBindingConfig = {
        type: 'Name',
        name: dataBinding.value
      };
    }
    if (dataBinding.type === "empty") {
      this.dataBindingConfig = {
        type: 'Empty'
      };
    }
    const newConfig = this.dataBindingConfig;
    if (newConfig !== oldDataBindingConfig) {
      this.dataBindingConfig = newConfig
      this.configureDataBinding();
    }
  }

  configureDataBinding() {
    try {
      Logger.debug(this.TAG, "configureDataBinding start")
      const file = this.riveAnimationView?.controller?.file
      if (!file) {
        Logger.error(this.TAG, "configureDataBinding file NULL")
        return;
      }
      const artboard = this.riveAnimationView?.controller?.activeArtboard
      if (!artboard) {
        Logger.error(this.TAG, "configureDataBinding artboard NULL")
        return;
      }
      this.viewModel = file?.defaultViewModelForArtboard(artboard)
      if (!this.viewModel) {
        Logger.error(this.TAG, "configureDataBinding viewModel NULL")
        return;
      }
      if (this.dataBindingConfig) {
        Logger.debug(this.TAG, "configureDataBinding running");
        this.dataBindingHandler =
          new DataBindingHandler(this.ctx, this.viewModel, this.riveAnimationView!!, this.propertyListeners,
            this.viewTag);
        this.dataBindingHandler.handleDataBindingConfig(this.dataBindingConfig);
        if (this.dataBindingConfig.type === 'AutoBind') {
          this.shouldBeReloaded = true;
        }
        Logger.debug(this.TAG, "configureDataBinding running dataBindingHandler " + this.dataBindingHandler);
      }
    } catch (ex) {
      this.handleRiveException(ex)
    }
  }

  registerPropertyListener(tag: number, path: string, propertyType: string) {
    Logger.debug(this.TAG, "registerPropertyListener path " + path + " propertyType " + propertyType + " tag " + tag +
      " dataBindingHandler " + this.dataBindingHandler + " viewModel " + this.viewModel);
    if (!this.viewModel) {
      setTimeout(() => {
        this.dataBindingHandler?.registerPropertyListener(tag, path, propertyType);
      }, 500);
      return;
    }
    this.dataBindingHandler?.registerPropertyListener(tag, path, propertyType);
  }

  setStateMachineName(stateMachineName: string) {
    if (this.stateMachineName == stateMachineName) {
      return
    }
    this.stateMachineName = stateMachineName
    this.shouldBeReloaded = true
  }

  setIsUserHandlingErrors(isUserHandlingErrors: boolean) {
    this.isUserHandlingErrors = isUserHandlingErrors
  }

  fireState(stateMachineName: string, inputName: string) {
    try {
      this.riveAnimationView?.fireState(stateMachineName, inputName)
    } catch (ex) {
      this.handleRiveException(ex)
    }
  }

  setBooleanState(stateMachineName: string, inputName: string, value: boolean) {
    try {
      this.riveAnimationView?.setBooleanState(stateMachineName, inputName, value)
    } catch (ex) {
      this.handleRiveException(ex)
    }
  }

  getBooleanState(inputName: string): boolean {
    try {
      const smi = this.riveAnimationView?.controller?.stateMachines[0];
      const smiInput = smi?.inputByName(inputName)
      if (smiInput instanceof SMIBoolean) {
        return smiInput.value
      }
    } catch (ex) {
      this.handleRiveException(ex)
    }
    return false;
  }

  setNumberState(stateMachineName: string, inputName: string, value: number) {
    try {
      this.riveAnimationView?.setNumberState(stateMachineName, inputName, value)
    } catch (ex) {
      this.handleRiveException(ex)
    }
  }

  getNumberState(inputName: string): number {
    try {
      const smi = this.riveAnimationView?.controller?.stateMachines[0]
      const smiInput = smi?.inputByName(inputName)
      if (smiInput instanceof SMINumber) {
        return smiInput.value
      }
    } catch (ex) {
      this.handleRiveException(ex)
    }
    return 0
  }

  fireStateAtPath(inputName: string, path: string) {
    try {
      this.riveAnimationView?.fireStateAtPath(inputName, path)
    } catch (ex) {
      this.handleRiveException(ex)
    }
  }

  setBooleanStateAtPath(inputName: string, value: boolean, path: string) {
    try {
      this.riveAnimationView?.setBooleanStateAtPath(inputName, value, path)
    } catch (ex) {
      this.handleRiveException(ex)
    }
  }

  getBooleanStateAtPath(inputName: string, path: string): boolean {
    try {
      const artboard = this.riveAnimationView?.controller?.activeArtboard
      const smiInput = artboard?.input(inputName, path)
      if (smiInput instanceof SMIBoolean) {
        return smiInput.value
      }
    } catch (ex) {
      this.handleRiveException(ex)
    }
    return false;
  }

  setNumberStateAtPath(inputName: string, value: number, path: string) {
    try {
      this.riveAnimationView?.setNumberStateAtPath(inputName, value, path)
    } catch (ex) {
      this.handleRiveException(ex)
    }
  }

  getNumberStateAtPath(inputName: string, path: string): number {
    try {
      const artboard = this.riveAnimationView?.controller?.activeArtboard
      const smiInput = artboard?.input(inputName, path)
      if (smiInput instanceof SMINumber
      ) {
        return smiInput.value
      }
    } catch (ex) {
      this.handleRiveException(ex)
    }
    return 0;
  }

  sendErrorToRN(error: RNRiveError) {
    CommonManager.sendEvent(this.ctx, RiveEvents.ERROR, {
      type: error.toString(),
      message: error.message
    })
  }

  handleRiveException(exception: RiveException
  ) {
    if (this.isUserHandlingErrors) {
      const rnRiveError = RNRiveError.mapToRNRiveError(exception);
      this.sendErrorToRN(rnRiveError!!);
    }
    Logger.error(this.TAG, "Error RiveException: " + exception.message);
  }

  addListeners() {
    this.riveAnimationView?.registerListener(this.listener)
    this.riveAnimationView?.addEventListener(this.eventListener)
  }

  removeListeners() {
    this.propertyListeners?.clear();
    this.riveAnimationView?.unregisterListener(this.listener)
    this.riveAnimationView?.removeEventListener(this.eventListener)
  }

  getAutoBind() {
    return this.dataBindingConfig?.type == "AutoBind" && this.dataBindingConfig.autoBind
  }

  handleInvalidUrlError(source: string) {
    if (this.isUserHandlingErrors) {
      this.sendErrorToRN(new RNRiveError(RNRiveErrorType.IncorrectRiveFileUrl, "Unable to download Rive file from:" + source))
    } else {
      Logger.error(this.TAG, "Invalid URL: " + source);
    }
  }

  async downloadUrlAsset(url: string, callback: FileReadCallBack) {
    Logger.debug(this.TAG, "downloadUrlAsset url " + url);
    const result = await FileUtils.isFileExist(this.ctx.uiAbilityContext, url);
    if (result && callback) {
      Logger.debug(this.TAG, "isFileExist success");
      const buffer = await FileUtils.readFileToBuffer(this.ctx.uiAbilityContext, url);
      callback.onCallBack(buffer);
    } else {
      if (!url.includes("http")) {
        this.handleInvalidUrlError(url);
        return;
      }
      DownLoadNetUrlUtils.requestNetUrl(this.ctx.uiAbilityContext, url, callback);
    }
  }

  handleSourceUrl(source: string, asset: FileAsset) {
    Logger.debug(this.TAG, "handleSourceUrl url " + source);
    const this_ = this;
    const callBack: FileReadCallBack = {
      onCallBack(bytes: ArrayBuffer) {
        this_.processAssetBytes(bytes, asset);
      }
    }
    this.downloadUrlAsset(source, callBack);
  }

  processAssetBytes(bytes: ArrayBuffer, asset: FileAsset) {
    if (asset instanceof FontAsset) {
      Logger.debug(this.TAG, "processAssetBytes FontAsset " + bytes.byteLength)
      asset.font = RiveFont.make(new Uint8Array(bytes))
    }
    if (asset instanceof ImageAsset) {
      Logger.debug(this.TAG, "processAssetBytes ImageAsset " + bytes.byteLength)
      asset.image = RiveRenderImage.make(new Uint8Array(bytes));
      this.riveAnimationView?.setArtboardName(this.artboardName);
    }
    if (asset instanceof AudioAsset) {
      Logger.debug(this.TAG, "processAssetBytes AudioAsset " + bytes.byteLength)
      //TODO audio有问题
      asset.audio = RiveAudio.make(new Uint8Array(bytes))
    }
  }

  handleSourceAssetId(source: string, asset: FileAsset) {
    if (source.includes("http")) {
      Logger.debug(this.TAG, "handleSourceAssetId source " + source);
      this.handleSourceUrl(source, asset);
      return;
    }
    const resourceMgr = this.ctx.uiAbilityContext.resourceManager;
    if (source.includes("asset://")) {
      source = source.replace("asset://", "assets/");
    }
    Logger.debug(this.TAG, "handleSourceAssetId assert source " + source);
    try {
      const bytes = resourceMgr.getRawFileContentSync(source);
      Logger.debug(this.TAG, "handleSourceAssetId assert source GO " + source);
      this.processAssetBytes(bytes.buffer as ArrayBuffer, asset);
    } catch (e) {
      this.sendErrorToRN(e);
      Logger.error(this.TAG, "Error handleSourceAssetId " + JSON.stringify(e));
    }
  }

  constructFilePath(filename: string, path: string): String {
    if (path.endsWith("/")) {
      return path + "" + filename
    } else {
      return path + "/" + filename
    }
  }


  async handleSourceAsset(fileName: string, path: string | null, asset: FileAsset): Promise<void> {
    const fullPath: string = path === null ? fileName : String(this.constructFilePath(fileName, path));
    const result = await FileUtils.isFileExist(this.ctx.uiAbilityContext, fullPath);
    if (result) {
      const assetBytes = await FileUtils.readFileToBuffer(this.ctx.uiAbilityContext, fullPath);
      this.processAssetBytes(assetBytes!!, asset);
    }
  }

  async loadAsset(source: ReadableMap, asset: FileAsset) {
    const sourceAssetId = source.getString("sourceAssetId")
    const sourceUrl = source.getString("sourceUrl")
    const sourceAsset = source.getString("sourceAsset")
    Logger.debug(this.TAG,
      "loadAsset sourceAssetId " + sourceAssetId + " sourceUrl " + sourceUrl + " sourceAsset " + sourceAsset)
    if (sourceAssetId) {
      await this.handleSourceAssetId(sourceAssetId, asset);
    }
    if (sourceUrl) {
      Logger.debug(this.TAG, "sourceUrl " + sourceUrl)
      await this.handleSourceUrl(sourceUrl, asset);
    }
    if (sourceAsset) {
      await this.handleSourceAsset(sourceAsset, source.getString("path"), asset)
    }
  }


  async reloadIfNeeded() {
    Logger.debug(this.TAG,
      "reloadIfNeeded shouldBeReloaded " + this.shouldBeReloaded + " url " + this.url + " resourceName " +
      this.resourceName + " artboardName " + this.artboardName + " animationName " + this.animationName +
        " stateMachineName " + this.stateMachineName + " autoplay " + this.autoplay + " fit " + this.fit +
        " alignment " + this.alignment + " getAutoBind " + this.getAutoBind());
    if (this.shouldBeReloaded) {
      if (this.referencedAssets) {
        this.assetStore?.dispos();
        const this_ = this;
        const onCallLoadAssetCallBack: LoadAssetCallBack = {
          onCall: (source: ReadableMap, asset: FileAsset): void => {
            Logger.debug(this.TAG, "onCallLoadAssetCallBack");
            this_.loadAsset(source, asset);
          }
        }
        this.assetStore = new RiveReactNativeAssetStore(this.referencedAssets, onCallLoadAssetCallBack)
        if (this.assetStore && this.riveAnimationView) {
          this.riveAnimationView.setAssetLoader(this.assetStore);
        }
      }
      if (this.url) {
        if (!this.url.includes("http")) {
          this.handleInvalidUrlError(this.url);
          return;
        }
        const this_ = this;
        const callBack: FileReadCallBack = {
          onCallBack(bytes: ArrayBuffer) {
            this_.riveAnimationView?.setRiveBytes(
              bytes,
              this_.artboardName,
              this_.animationName,
              this_.stateMachineName,
              this_.autoplay,
              this_.getAutoBind(),
              this_.fit,
              this_.alignment,
              Loop.AUTO
            )
          }
        }
        DownLoadNetUrlUtils.requestNetUrl(this.ctx.uiAbilityContext, this.url, callBack);
      } else {
        try {
          let resName = "@rawfile/" + this.resourceName + ".riv"
          if (this.resourceName.includes("asset://")) {
            this.resourceName = this.resourceName.replace("asset://", "assets/")
            resName = resName = "@rawfile/" + this.resourceName
          }
          this.riveAnimationView?.setRiveResource(
            resName,
            this.artboardName,
            this.animationName,
            this.stateMachineName,
            this.autoplay,
            this.getAutoBind(),
            this.fit,
            this.alignment,
            Loop.AUTO
          )
          setTimeout(() => {
            this.configureDataBinding()
            Logger.debug(this.TAG, "getStateMachines " + this.riveAnimationView?.getStateMachines().length)
          }, 500)
          CommonManager.sendEvent(this.ctx, "RiveReactNativeLoaded:" + this.viewTag, "")
          this.url = ""
        } catch (ex) {
          this.handleRiveException(ex)
        }
      }
      this.shouldBeReloaded = false
    }
  }
}




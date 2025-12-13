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

import { FileAsset, FileAssetLoader } from "rive_ohos";
import { LoadAssetCallBack } from "../datamodel/LoadAssetCallBack";
import { ReadableMap } from "../datamodel/ReadableMap";
import Logger from "../utils/Logger";

export class RiveReactNativeAssetStore extends FileAssetLoader {
  private TAG: string = "RiveReactNativeAssetStore"
  public referencedAssets: ReadableMap | undefined = undefined;
  public loadAssetHandler: LoadAssetCallBack | undefined = undefined;
  public cachedFileAssets: Map<string, FileAsset> = new Map();

  constructor(referencedAssets: ReadableMap, loadAssetHandler: LoadAssetCallBack) {
    super();
    this.referencedAssets = referencedAssets;
    this.loadAssetHandler = loadAssetHandler;
  }

  substringBeforeLast(str: string, separator: string): string {
    const lastIndex = str.lastIndexOf(separator);
    return lastIndex === -1 ? str : str.substring(0, lastIndex);
  }

  loadContents(asset: FileAsset, inBandBytes: Uint8Array): boolean {
    Logger.debug(this.TAG,"loadContents")
    let key = this.substringBeforeLast(asset.uniqueFilename, '.');
    let assetData = this.referencedAssets?.getMap(key);
    if (!assetData) {
      key = asset.name;
      assetData = this.referencedAssets?.getMap(asset.name);
    }
    const source = assetData?.getMap("source");
    if (!source) {
      return false;
    }
    try {
      this.loadAssetHandler?.onCall(source, asset);
    } catch (e) {
      Logger.error(this.TAG, "Error loadContents " + JSON.stringify(e));
    }
    this.cachedFileAssets.set(key, asset);
    return true;
  }

  dispos() {
    this.cachedFileAssets.clear()
  }
}
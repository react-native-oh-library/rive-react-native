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

import fs from '@ohos.file.fs';
import { buffer } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import axios, { AxiosProgressEvent, AxiosResponse, AxiosError } from '@ohos/axios';
import Logger from './Logger';
import { FileReadCallBack } from '../datamodel/FileReadCallBack';

export class DownLoadNetUrlUtils {
  static TAG: string = "DownLoadNetUrlUtils";

  static requestNetUrl(context: Context, url: string, callBack: FileReadCallBack) {
    let cacheRiveFilePath = context.cacheDir + '/' + new Date().getTime() + ".riv"
    try {
      fs.accessSync(cacheRiveFilePath);
      fs.unlinkSync(cacheRiveFilePath);
    } catch (err) {
      Logger.error(DownLoadNetUrlUtils.TAG, "Error accessSync " + JSON.stringify(err));
    }
    axios({
      url: url,
      method: 'get',
      filePath: cacheRiveFilePath,
      onDownloadProgress: (progressEvent: AxiosProgressEvent): void => {
        Logger.debug(DownLoadNetUrlUtils.TAG, "download progress " + progressEvent.rate);
      }
    }).then((res: AxiosResponse<string>) => {
      Logger.debug(DownLoadNetUrlUtils.TAG, "download success result");
      let file = fs.openSync(cacheRiveFilePath, fs.OpenMode.READ_WRITE);
      let stat = fs.statSync(cacheRiveFilePath);
      let arrayBuffer = new ArrayBuffer(stat.size);
      fs.read(file.fd, arrayBuffer).then((readLen: number) => {
        Logger.debug(DownLoadNetUrlUtils.TAG, "read file data succeed");
        callBack?.onCallBack(buffer.from(arrayBuffer, 0, readLen).buffer)
      }).catch((err: BusinessError) => {
        Logger.error(DownLoadNetUrlUtils.TAG,
          "Error read file data failed with error message: " + err.message + ", error code: " + err.code);
      }).finally(() => {
        fs.closeSync(file);
      });
    }).catch((err: AxiosError) => {
      Logger.error(DownLoadNetUrlUtils.TAG, "Error download " + JSON.stringify(err))
    })
  }
}
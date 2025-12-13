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

import fileio from '@ohos.fileio';
import { BusinessError } from '@ohos.base';
import Logger from "../utils/Logger";
import { Context } from '@kit.AbilityKit';

export class FileUtils {
  static TAG: string = "FileUtils";

  static async isFileExist(context: Context, filePath: string): Promise<boolean> {
    Logger.debug(this.TAG,"isFileExist filePath "+filePath)
    if (filePath.includes("asset://")) {
      const path = filePath.replace("asset://", "assets/");
      try {
        context.resourceManager.getRawFdSync(path);
        return true;
      } catch (e) {
        Logger.error(this.TAG, `Error isFileExist asset ` + filePath);
        return false;
      }
    }
    try {
      await fileio.access(filePath);
      return true;
    } catch (error) {
      const err = error as BusinessError;
      // 错误码201=文件不存在，202=权限不足，其他错误按需处理
      if (err.code === 201 || err.code === 202) {
        Logger.error(this.TAG, `Error isFileExist failed ：` + err.code);
        return false;
      }
      Logger.error(this.TAG, `Error isFileExist failed ：${err.message}`);
      return false;
    }
  }


  static async readFileToBuffer(context: Context, filePath: string): Promise<ArrayBuffer | null> {
    Logger.debug(this.TAG,"readFileToBuffer filePath "+filePath)
    if (filePath.includes("asset://")) {
      const path = filePath.replace("asset://", "assets/");
      try {
        return context.resourceManager.getRawFileContentSync(path).buffer;
      } catch (e) {
        Logger.error(this.TAG, `Error readFileToBuffer asset ` + filePath);
        return null;
      }
    }
    let fd: number | null = null;
    try {
      fd = await fileio.open(filePath, 0o000000);
      const stat = await fileio.fstat(fd);
      const buffer = new ArrayBuffer(stat.size);
      await fileio.read(fd, new Uint8Array(buffer), { offset: 0, length: stat.size });
      // return new Uint8Array(buffer);
      return buffer
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(this.TAG, `Error readFileToBuffer failed ：${err.message}`);
      return null;
    } finally {
      if (fd !== null) {
        await fileio.close(fd);
      }
    }
  }
}
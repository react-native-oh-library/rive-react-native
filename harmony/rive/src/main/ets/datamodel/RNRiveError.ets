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
  AnimationException,
  ArtboardException,
  MalformedFileException,
  RiveException, StateMachineException, StateMachineInputException,
  TextValueRunException,
  UnsupportedRuntimeVersionException,
  ViewModelException
} from 'rive_ohos'

export enum RNRiveErrorType {
  FileNotFound = 'FileNotFound',
  UnsupportedRuntimeVersion = 'UnsupportedRuntimeVersion',
  IncorrectRiveFileUrl = 'IncorrectRiveFileUrl',
  IncorrectAnimationName = 'IncorrectAnimationName',
  MalformedFile = 'MalformedFile',
  IncorrectArtboardName = 'IncorrectArtboardName',
  IncorrectStateMachineName = 'IncorrectStateMachineName',
  IncorrectStateMachineInput = 'IncorrectStateMachineInput',
  TextRunNotFoundError = 'TextRunNotFoundError',
  DataBindingError = 'DataBindingError',
  UnusedReferencedAssetError = 'UnusedReferencedAssetError'
}

export class RNRiveError {
  readonly type: RNRiveErrorType;
  message: string;

  constructor(type: RNRiveErrorType, message: string = 'Default message') {
    this.type = type;
    this.message = message;
  }

  toString(): string {
    return this.type;
  }

  static mapToRNRiveError(ex: RiveException): RNRiveError | null {
    if (ex instanceof ArtboardException) {
      return new RNRiveError(RNRiveErrorType.IncorrectArtboardName, ex.message || '');
    } else if (ex instanceof UnsupportedRuntimeVersionException) {
      return new RNRiveError(RNRiveErrorType.UnsupportedRuntimeVersion, ex.message || '');
    } else if (ex instanceof MalformedFileException) {
      return new RNRiveError(RNRiveErrorType.MalformedFile, ex.message || '');
    } else if (ex instanceof AnimationException) {
      return new RNRiveError(RNRiveErrorType.IncorrectAnimationName, ex.message || '');
    } else if (ex instanceof StateMachineException) {
      return new RNRiveError(RNRiveErrorType.IncorrectStateMachineName, ex.message || '');
    } else if (ex instanceof StateMachineInputException) {
      return new RNRiveError(RNRiveErrorType.IncorrectStateMachineInput, ex.message || '');
    } else if (ex instanceof TextValueRunException) {
      return new RNRiveError(RNRiveErrorType.TextRunNotFoundError, ex.message || '');
    } else if (ex instanceof ViewModelException) {
      return new RNRiveError(RNRiveErrorType.DataBindingError, ex.message || '');
    } else {
      return null;
    }
  }

  static create(type: RNRiveErrorType, message: string = 'Default message'): RNRiveError {
    return new RNRiveError(type, message);
  }
}
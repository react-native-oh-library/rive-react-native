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
import { RiveFileControllerListener, StateMachineInstance } from 'rive_ohos';
import { PlayableInstance } from 'rive_ohos/src/main/ets/runtime/core/PlayableInstance';
import { RiveEvents } from './RiveEvents';
import { RNLoopMode, RNLoopModeUtils } from '../datamodel/RNLoopMode';
import Logger from '../utils/Logger';
import LinearAnimationInstance from 'rive_ohos/src/main/ets/runtime/core/LinearAnimationInstance';
import { CommonManager } from '../manager/CommonManager';

export class RiveFileControllerListenerImpl implements RiveFileControllerListener {
  private ctx: RNOHContext | undefined;
  private TAG: string = "RiveFileControllerListenerImpl"

  constructor(ctx_: RNOHContext) {
    this.ctx = ctx_;
  }

  notifyPlay(animation: PlayableInstance): void {
    Logger.debug(this.TAG, this.TAG, 'notifyPlay ' + animation.name);
    if (animation instanceof LinearAnimationInstance) {
      this.onPlay(animation.name);
    }
    if (animation instanceof StateMachineInstance) {
      this.onPlay(animation.name, true);
    }
  }

  notifyPause(animation: PlayableInstance): void {
    Logger.debug(this.TAG, 'notifyPause ' + animation.name);
    if (animation instanceof LinearAnimationInstance) {
      this.onPause(animation.name);
    }
    if (animation instanceof StateMachineInstance) {
      this.onPause(animation.name, true);
    }
  }

  notifyStop(animation: PlayableInstance): void {
    Logger.debug(this.TAG, 'notifyStop ' + animation.name);
    if (animation instanceof LinearAnimationInstance) {
      this.onStop(animation.name);
    }
    if (animation instanceof StateMachineInstance) {
      this.onStop(animation.name, true);
    }
  }

  notifyLoop(animation: PlayableInstance): void {
    Logger.debug(this.TAG, 'notifyLoop ' + animation.name);
    if (animation instanceof LinearAnimationInstance) {
      this.onLoopEnd(animation.name, RNLoopModeUtils.mapToRNLoopMode(animation.getloop()))
    } else {
      throw new Error("Only animation can be passed as an argument")
    }
  }

  notifyStateChanged(stateMachineName: string, stateName: string): void {
    Logger.debug(this.TAG, 'notifyStateChanged stateMachineName ' + stateMachineName + " stateName " + stateName);
    this.onStateChanged(stateMachineName, stateName);
  }

  notifyAdvance(elapsed: number): void {
  }


  onPlay(animationName: string, isStateMachine: boolean = false) {
    CommonManager.sendEvent(this.ctx!!, RiveEvents.PLAY, {
      animationName: animationName,
      isStateMachine: isStateMachine
    });
  }

  onPause(animationName: string, isStateMachine: boolean = false) {
    CommonManager.sendEvent(this.ctx!!, RiveEvents.PAUSE, {
      animationName: animationName,
      isStateMachine: isStateMachine
    });
  }

  onStop(animationName: string, isStateMachine: boolean = false) {
    CommonManager.sendEvent(this.ctx!!, RiveEvents.STOP, {
      animationName: animationName,
      isStateMachine: isStateMachine
    });
  }


  onLoopEnd(animationName: string, loopMode: RNLoopMode) {
    CommonManager.sendEvent(this.ctx!!, RiveEvents.LOOP_END, {
      animationName: animationName,
      loopMode: loopMode.toString()
    });
  }

  onStateChanged(stateMachineName: string, stateName: string) {
    CommonManager.sendEvent(this.ctx!!, RiveEvents.STATE_CHANGED, {
      stateMachineName: stateMachineName,
      stateName: stateName
    });
  }
}
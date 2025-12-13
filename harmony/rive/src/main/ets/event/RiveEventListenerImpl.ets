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

import { RNOHContext } from "@rnoh/react-native-openharmony";
import { RiveEvent, RiveEventListener, RiveGeneralEvent, RiveOpenURLEvent } from "rive_ohos";
import { RiveEvents } from "./RiveEvents";
import { CommonManager } from "../manager/CommonManager";
import Logger from "../utils/Logger";

export class RiveEventListenerImpl implements RiveEventListener {
  private ctx: RNOHContext | undefined;
  private TAG: string = "RiveEventListenerImpl"

  constructor(ctx_: RNOHContext) {
    this.ctx = ctx_;
  }

  notifyEvent(event: RiveEvent): void {
    Logger.debug(this.TAG, "notifyEvent  name " + event.name+" properties "+event.properties)
    if (event instanceof RiveGeneralEvent) {
      Logger.debug(this.TAG, 'RiveGeneralEvent '+ event);
      this.onRiveEventReceived(event)
    } else if (event instanceof RiveOpenURLEvent) {
      Logger.debug(this.TAG, 'RiveOpenURLEvent');
      this.onRiveEventReceived(event)
    }
  }

  onRiveEventReceived(event: RiveEvent) {
    if (event instanceof RiveOpenURLEvent) {
      CommonManager.sendEvent(this.ctx!!, RiveEvents.RIVE_EVENT, {
        name: event.name,
        delay: event.delay,
        properties: event.properties,
        url: event,
        target: event.target,
      });
    } else {
      CommonManager.sendEvent(this.ctx!!, RiveEvents.RIVE_EVENT, {
        name: event.name,
        delay: event.delay,
        properties: event.properties
      });
    }
  }
}
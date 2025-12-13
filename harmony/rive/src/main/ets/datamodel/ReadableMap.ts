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

import { RiveViewSpec } from "../view/props/RiveSpec";

export interface ReadableMap {
  hasKey(name: string): boolean;

  isNull(name: string): boolean;

  getBoolean(name: string): boolean;

  getDouble(name: string): number;

  getInt(name: string): number;

  getString(name: string): string | null;

  getArray(name: string): ReadableArray | null;

  getMap(name: string): ReadableMap | null;

  getDynamic(name: string): Dynamic;

  getType(name: string): ReadableType;

  keySetIterator(): ReadableMapKeySetIterator;

  getNullableBoolean(name: string): boolean | null;

  getNullableInt(name: string): number | null;

  importKeys(): string[];

  importValues(): any[];

  toMap(): Record<string, any>;
}

// ReadableType.ets
export enum ReadableType {
  NULL,
  BOOLEAN,
  NUMBER,
  STRING,
  ARRAY,
  MAP
}


export class ReadableNativeMap implements ReadableMap {
  private data: Record<string, any> = {};

  constructor(mapData?: Record<string, any>) {
    if (mapData) {
      this.data = mapData;
    }
  }

  hasKey(name: string): boolean {
    return name in this.data;
  }

  isNull(name: string): boolean {
    return this.data[name] === null || this.data[name] === undefined;
  }

  getBoolean(name: string): boolean {
    const value = this.data[name];
    if (typeof value === 'boolean') {
      return value;
    }
    if (typeof value === 'string') {
      return value.toLowerCase() === 'true';
    }
    throw new Error(`Value for key "${name}" is not a boolean`);
  }

  getDouble(name: string): number {
    const value = this.data[name];
    if (typeof value === 'number') {
      return value;
    }
    if (typeof value === 'string') {
      const num = parseFloat(value);
      if (!isNaN(num)) {
        return num;
      }
    }
    throw new Error(`Value for key "${name}" is not a number`);
  }

  getInt(name: string): number {
    const value = this.data[name];
    if (typeof value === 'number') {
      return Math.floor(value);
    }
    if (typeof value === 'string') {
      const num = parseInt(value, 10);
      if (!isNaN(num)) {
        return num;
      }
    }
    throw new Error(`Value for key "${name}" is not an integer`);
  }

  getString(name: string): string | null {
    const value = this.data[name];
    if (value === null || value === undefined) {
      return null;
    }
    if (typeof value === 'string') {
      return value;
    }
    return String(value);
  }

  getArray(name: string): ReadableArray | null {
    const value = this.data[name];
    if (value === null || value === undefined) {
      return null;
    }
    if (Array.isArray(value)) {
      return new ReadableNativeArray(value);
    }
    throw new Error(`Value for key "${name}" is not an array`);
  }

  getMap(name: string): ReadableMap | null {
    const value = this.data[name];
    if (value === null || value === undefined) {
      return null;
    }
    if (typeof value === 'object' && !Array.isArray(value)) {
      return new ReadableNativeMap(value);
    }
    throw new Error(`Value for key "${name}" is not a map`);
  }

  getDynamic(name: string): Dynamic {
    return Dynamic.fromObject(this.data[name]);
  }

  getType(name: string): ReadableType {
    const value = this.data[name];

    if (value === null || value === undefined) {
      return ReadableType.NULL;
    }
    if (typeof value === 'boolean') {
      return ReadableType.BOOLEAN;
    }
    if (typeof value === 'number') {
      return ReadableType.NUMBER;
    }
    if (typeof value === 'string') {
      return ReadableType.STRING;
    }
    if (Array.isArray(value)) {
      return ReadableType.ARRAY;
    }
    if (typeof value === 'object') {
      return ReadableType.MAP;
    }

    return ReadableType.NULL;
  }

  getNullableBoolean(name: string): boolean | null {
    const value = this.data[name];
    if (value === null || value === undefined) {
      return null;
    }
    return this.getBoolean(name);
  }

  getNullableInt(name: string): number | null {
    const value = this.data[name];
    if (value === null || value === undefined) {
      return null;
    }
    return this.getInt(name);
  }

  keySetIterator(): ReadableMapKeySetIterator {
    return new ReadableNativeMapKeySetIterator(this);
  }

  // 获取所有键
  importKeys(): string[] {
    return Object.keys(this.data);
  }

  // 获取所有值
  importValues(): any[] {
    return Object.values(this.data);
  }

  toMap(): Record<string, any> {
    const result: Record<string, any> = {};
    const keys: string[] = this.importKeys();

    for (const key of keys) {
      const type: ReadableType = this.getType(key);

      switch (type) {
        case ReadableType.NULL:
          result[key] = null;
          break;
        case ReadableType.BOOLEAN:
          result[key] = this.getBoolean(key);
          break;
        case ReadableType.NUMBER:
          result[key] = this.getDouble(key);
          break;
        case ReadableType.STRING:
          result[key] = this.getString(key);
          break;
        case ReadableType.ARRAY:
          const array = this.getArray(key);
          if (array instanceof ReadableNativeArray) {
            result[key] = array.toArray();
          } else {
            result[key] = null;
          }
          break;
        case ReadableType.MAP:
          const map = this.getMap(key);
          if (map instanceof ReadableNativeMap) {
            result[key] = map.toMap();
          } else {
            result[key] = null;
          }
          break;
      }
    }

    return result;
  }
}

// ReadableArray.ets
export interface ReadableArray {
  size(): number;

  isNull(index: number): boolean;

  getBoolean(index: number): boolean;

  getDouble(index: number): number;

  getInt(index: number): number;

  getString(index: number): string | null;

  getArray(index: number): ReadableArray | null;

  getMap(index: number): ReadableMap | null;

  getType(index: number): ReadableType;
}

export class ReadableNativeArray implements ReadableArray {
  private data: any[] = [];

  constructor(arrayData?: any[]) {
    if (arrayData) {
      this.data = arrayData;
    }
  }

  size(): number {
    return this.data.length;
  }

  isNull(index: number): boolean {
    return this.data[index] === null || this.data[index] === undefined;
  }

  getBoolean(index: number): boolean {
    const value = this.data[index];
    if (typeof value === 'boolean') {
      return value;
    }
    throw new Error(`Value at index ${index} is not a boolean`);
  }

  getDouble(index: number): number {
    const value = this.data[index];
    if (typeof value === 'number') {
      return value;
    }
    throw new Error(`Value at index ${index} is not a number`);
  }

  getInt(index: number): number {
    const value = this.data[index];
    if (typeof value === 'number') {
      return Math.floor(value);
    }
    throw new Error(`Value at index ${index} is not an integer`);
  }

  getString(index: number): string | null {
    const value = this.data[index];
    if (value === null || value === undefined) {
      return null;
    }
    return String(value);
  }

  getArray(index: number): ReadableArray | null {
    const value = this.data[index];
    if (value === null || value === undefined) {
      return null;
    }
    if (Array.isArray(value)) {
      return new ReadableNativeArray(value);
    }
    throw new Error(`Value at index ${index} is not an array`);
  }

  getMap(index: number): ReadableMap | null {
    const value = this.data[index];
    if (value === null || value === undefined) {
      return null;
    }
    if (typeof value === 'object' && !Array.isArray(value)) {
      return new ReadableNativeMap(value);
    }
    throw new Error(`Value at index ${index} is not a map`);
  }

  getType(index: number): ReadableType {
    const value = this.data[index];

    if (value === null || value === undefined) {
      return ReadableType.NULL;
    }
    if (typeof value === 'boolean') {
      return ReadableType.BOOLEAN;
    }
    if (typeof value === 'number') {
      return ReadableType.NUMBER;
    }
    if (typeof value === 'string') {
      return ReadableType.STRING;
    }
    if (Array.isArray(value)) {
      return ReadableType.ARRAY;
    }
    if (typeof value === 'object') {
      return ReadableType.MAP;
    }

    return ReadableType.NULL;
  }

  toArray(): any[] {
    const result: any[] = [];

    for (let i = 0; i < this.size(); i++) {
      const type: ReadableType = this.getType(i);

      switch (type) {
        case ReadableType.NULL:
          result.push(null);
          break;
        case ReadableType.BOOLEAN:
          result.push(this.getBoolean(i));
          break;
        case ReadableType.NUMBER:
          result.push(this.getDouble(i));
          break;
        case ReadableType.STRING:
          result.push(this.getString(i));
          break;
        case ReadableType.ARRAY:
          const array = this.getArray(i);
          if (array instanceof ReadableNativeArray) {
            result.push(array.toArray());
          } else {
            result.push(null);
          }
          break;
        case ReadableType.MAP:
          const map = this.getMap(i);
          if (map instanceof ReadableNativeMap) {
            result.push(map.toMap());
          } else {
            result.push(null);
          }
          break;
      }
    }

    return result;
  }
}

// ReadableMapKeySetIterator.ets
export interface ReadableMapKeySetIterator {
  hasNextKey(): boolean;

  nextKey(): string;
}

export class ReadableNativeMapKeySetIterator implements ReadableMapKeySetIterator {
  private map: ReadableNativeMap;
  private keys: string[];
  private index: number = 0;

  constructor(map: ReadableNativeMap) {
    this.map = map;
    this.keys = map.importKeys();
  }

  hasNextKey(): boolean {
    return this.index < this.keys.length;
  }

  nextKey(): string {
    if (!this.hasNextKey()) {
      throw new Error('No more keys available');
    }
    return this.keys[this.index++];
  }
}

export class Dynamic {
  private value: any | null;
  private type: ReadableType;

  private constructor(value: any | null, type: ReadableType) {
    this.value = value;
    this.type = type;
  }

  static fromObject(value: any): Dynamic {
    if (value === null || value === undefined) {
      return new Dynamic(null, ReadableType.NULL);
    }
    if (typeof value === 'boolean') {
      return new Dynamic(value, ReadableType.BOOLEAN);
    }
    if (typeof value === 'number') {
      return new Dynamic(value, ReadableType.NUMBER);
    }
    if (typeof value === 'string') {
      return new Dynamic(value, ReadableType.STRING);
    }
    if (value instanceof ReadableNativeMap) {
      return new Dynamic(value, ReadableType.MAP);
    }
    if (value instanceof ReadableNativeArray) {
      return new Dynamic(value, ReadableType.ARRAY);
    }
    if (typeof value === 'object' && !Array.isArray(value)) {
      return new Dynamic(new ReadableNativeMap(value), ReadableType.MAP);
    }
    if (Array.isArray(value)) {
      return new Dynamic(new ReadableNativeArray(value), ReadableType.ARRAY);
    }

    throw new Error(`Unsupported type for Dynamic: ${typeof value}`);
  }

  getValue(): any | null {
    return this.value;
  }

  getType(): ReadableType {
    return this.type;
  }

  asBoolean(): boolean {
    if (this.type !== ReadableType.BOOLEAN) {
      throw new Error(`Dynamic value is not a boolean: ${this.type}`);
    }
    return this.value as boolean;
  }

  asNumber(): number {
    if (this.type !== ReadableType.NUMBER) {
      throw new Error(`Dynamic value is not a number: ${this.type}`);
    }
    return this.value as number;
  }

  asString(): string {
    if (this.type !== ReadableType.STRING) {
      throw new Error(`Dynamic value is not a string: ${this.type}`);
    }
    return this.value as string;
  }

  asArray(): ReadableNativeArray {
    if (this.type !== ReadableType.ARRAY) {
      throw new Error(`Dynamic value is not an array: ${this.type}`);
    }
    return this.value as ReadableNativeArray;
  }

  asMap(): ReadableNativeMap {
    if (this.type !== ReadableType.MAP) {
      throw new Error(`Dynamic value is not a map: ${this.type}`);
    }
    return this.value as ReadableNativeMap;
  }
}

export class FilesHandledMappingConverter {
  /**
   * 将 FilesHandledMapping 转换为 Record<string, any>
   * 这是最简单的转换方式
   */
  static toRecord(mapping: RiveViewSpec.FilesHandledMapping): Record<string, any> {
    // 直接返回即可，FilesHandledMapping 本身就是 Record<string, FileHandlerOptions>
    // FileHandlerOptions 也是 Record<string, any>
    return mapping as Record<string, any>;
  }
}
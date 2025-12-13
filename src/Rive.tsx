import React, {
  useCallback,
  useEffect,
  useImperativeHandle,
  useMemo,
  useRef,
  useState,
} from 'react';
import resolveAssetSource from 'react-native/Libraries/Image/resolveAssetSource';
import {
  ViewStyle,
  StyleSheet,
  View,
  StyleProp,
  Platform,
  findNodeHandle,
  UIManager,
  DeviceEventEmitter
} from 'react-native';

import NativeRiveReactNativeView from './NativeRiveReactNativeView'

import {
  RiveRef,
  Direction,
  LoopMode,
  RNRiveError,
  ViewManagerMethod,
  RiveGeneralEvent,
  RiveOpenUrlEvent,
  FilesHandledMapping,
  RiveAssetPropType,
  RiveRGBA,
  PropertyType,
  DataBindBy,
  AutoBind,
} from './types';
import { convertErrorFromNativeToRN, XOR } from './helpers';
import { Alignment, Fit } from './types';
import {
  getPropertyTypeString,
  intToRiveRGBA,
  parseColor,
  parsePossibleSources,
} from './utils';

import { RiveModule } from './RiveTurboModules';


export type PropertyCallback = (value: any) => void;
export class RiveNativeEventEmitter {
  constructor(
    public riveRef: React.MutableRefObject<any>
  ) { }

  private nativeSubscriptions: { [key: string]: any } = {};
  private callbacks: { [key: string]: PropertyCallback[] } = {};

  addListener<T>(
    path: string,
    propertyType: PropertyType,
    reactTag: number | null,
    callback: (value: T) => void
  ) {
    if (!reactTag) {
      console.warn('[Rive] RiveRef viewTag is null. Cannot register property listener.');
      return;
    }
    const key = this.generatePropertyKey(path, propertyType, reactTag);
    if (!this.callbacks[key]) {
      this.callbacks[key] = [callback];
    } else if (!this.callbacks[key].includes(callback)) {
      this.callbacks[key].push(callback);
    }

    if (!this.nativeSubscriptions[key]) {
    let subscription = DeviceEventEmitter.addListener(key, ({value }) => {
      this.callbacks[key]?.forEach((storedCallback) => storedCallback(value))
    });
      UIManager.dispatchViewManagerCommand(
        reactTag,
        'registerPropertyListener' as any,
        [path, getPropertyTypeString(propertyType), reactTag]
      );
      this.nativeSubscriptions[key] = subscription;
    }
  }

  generatePropertyKey(
    path: string,
    propertyType: PropertyType,
    reactTag: number
  ): string {
    return `${getPropertyTypeString(propertyType)}:${path}:${reactTag}`;
  }

  removeListener<T>(
    path: string,
    propertyType: PropertyType,
    reactTag: number | null,
    callback: (value: T) => void
  ) {
    if (!reactTag) {
      console.warn('[Rive] RiveRef viewTag is null. Cannot unregister property listener.');
      return;
    }
    const key = this.generatePropertyKey(path, propertyType, reactTag);
    if (this.callbacks[key]) {
      this.callbacks[key] = this.callbacks[key].filter(
        (storedCallback) => storedCallback !== callback
      );
      if (this.callbacks[key].length === 0) {
        this.nativeSubscriptions[key]?.remove();
        delete this.nativeSubscriptions[key];
        delete this.callbacks[key];
      }
    }
  }
}

const useRiveCommands = (riveRef: React.RefObject<any>) => {
  const dispatchCommand = useCallback(
    (command: ViewManagerMethod, args: any[] = []) => {
      const tag = findNodeHandle(riveRef.current);
      if (tag) {
        UIManager.dispatchViewManagerCommand(tag, command as any, args);
      }
    },
    [riveRef]
  );

  return { dispatchCommand };
};

const useRiveResource = (props: {
  resourceName?: string;
  url?: string;
  source?: number | { uri: string };
}) => {
  return useMemo(() => {
    const { resourceName, url, source } = props;

    if (resourceName) return { resourceName };
    if (url) return { url };

    const assetID = typeof source === 'number' ? source : null;
    const sourceURI = typeof source === 'object' ? source.uri : null;
    const assetURI = assetID ? resolveAssetSource(assetID)?.uri : sourceURI;

    if (!assetURI) {
      throw new Error('Invalid Rive resource. Please provide a valid resource.');
    }

    if (assetURI.match(/^https?:\/\//)) {
      return { url: assetURI };
    }

    if (assetURI.match(/^file:\/\//)) {
      const strippedName = assetURI.match(/.*\.app\/(.*)\.riv/)?.[1];
      if (strippedName) {
        return { resourceName: strippedName };
      }
      return { url: assetURI };
    }

    return { resourceName: assetURI };
  }, [props.resourceName, props.url, props.source]);
};

const useRiveErrorHandler = (onError?: (rnRiveError: RNRiveError) => void) => {
  const handleError = useCallback((event: { nativeEvent: { type: string; message: string } }) => {
    const { type, message } = event.nativeEvent;
    const rnRiveError = convertErrorFromNativeToRN({ type, message });

    if (rnRiveError !== null) {
      onError?.(rnRiveError);
    } else {
      console.warn('[Rive] Unknown error type received from native: ', type);
    }
  }, [onError]);

  return handleError;
};

export function useRive(): [(node: RiveRef) => void, RiveRef | null] {
  const [ref, setRef] = useState<RiveRef | null>(null);

  const setRiveRef = useCallback<(node: RiveRef) => void>((node) => {
    if (!node || !node.internalNativeEmitter) return;
    let viewTag = node.viewTag();
    if (viewTag === null) {
      console.warn('[Rive] RiveRef viewTag is null.');
      return;
    }
    let subscription = DeviceEventEmitter.addListener(`RiveReactNativeLoaded:${viewTag}`, () => {
      setRef(node);
      subscription.remove();
    });

  }, []);

  return [setRiveRef, ref];
}

export function useRiveBoolean(
  riveRef: RiveRef | null,
  path: string
): [boolean | undefined, (value: boolean) => void] {
  return useRivePropertyListener<boolean>(riveRef, path, PropertyType.Boolean);
}

export function useRiveString(
  riveRef: RiveRef | null,
  path: string
): [string | undefined, (value: string) => void] {
  return useRivePropertyListener<string>(riveRef, path, PropertyType.String);
}

export function useRiveNumber(
  riveRef: RiveRef | null,
  path: string
): [number | undefined, (value: number) => void] {
  return useRivePropertyListener<number>(riveRef, path, PropertyType.Number);
}

export function useRiveEnum(
  riveRef: RiveRef | null,
  path: string
): [string | undefined, (value: string) => void] {
  return useRivePropertyListener<string>(riveRef, path, PropertyType.Enum);
}

export function useRiveColor(
  riveRef: RiveRef | null,
  path: string
): [RiveRGBA | undefined, (value: RiveRGBA | string) => void] {
  return useRivePropertyListener<RiveRGBA>(riveRef, path, PropertyType.Color);
}

export function useRiveTrigger(
  riveRef: RiveRef | null,
  path: string,
  onTrigger?: () => void
): (() => void) | undefined {
  const triggerCallback = useCallback(() => {
    onTrigger?.();
  }, [onTrigger]);

  useEffect(() => {
    const listener = riveRef?.internalNativeEmitter?.();
    if (!listener) return () => { };
    const reactTag = riveRef?.viewTag() || findNodeHandle(riveRef as any);
    if (!reactTag) return () => { };

    listener.addListener<void>(
      path,
      PropertyType.Trigger,
      reactTag,
      triggerCallback
    );

    return () => {
      listener.removeListener<void>(
        path,
        PropertyType.Trigger,
        reactTag,
        triggerCallback
      );
    };
  }, [riveRef, path, triggerCallback]);

  const trigger = useCallback(() => {
    if (!riveRef) {
      if (__DEV__) {
        console.warn(`[Rive] Tried to trigger "${path}" before riveRef was available.`);
      }
      return;
    }
    riveRef.trigger(path);
  }, [riveRef, path]);

  return riveRef ? trigger : undefined;
}

function useRivePropertyListener<T>(
  riveRef: RiveRef | null,
  path: string,
  propertyType: PropertyType
): [T | undefined, (value: T) => void] {
  const [value, setValue] = useState<T | undefined>(undefined);
  const listenerCallback = useCallback((newValue: T) => {
    setValue(newValue);
  }, []);

  const listenerCallbackWithColor = useCallback((newValue: number) => {
    const rgbaValue = intToRiveRGBA(newValue);
    setValue(rgbaValue as T);
  }, []);

  useEffect(() => {
    const listener = riveRef?.internalNativeEmitter?.();
    if (!listener) return () => { };
    const reactTag = riveRef?.viewTag() || findNodeHandle(riveRef as any);
    if (propertyType === PropertyType.Color) {
      listener.addListener<number>(
        path,
        propertyType,
        reactTag,
        listenerCallbackWithColor
      );
      return () => {
        listener.removeListener<number>(
          path,
          propertyType,
          reactTag,
          listenerCallbackWithColor
        );
      };
    } else {
      listener.addListener<T>(path, propertyType, reactTag, listenerCallback);
      return () => {
        listener.removeListener<T>(
          path,
          propertyType,
          reactTag,
          listenerCallback
        );
      };
    }
  }, [riveRef, path, propertyType, listenerCallback, listenerCallbackWithColor]);

  const setPropertyValue = useCallback(
    (newValue: T) => {
      if (!riveRef) {
        if (__DEV__) {
          console.warn(`[Rive] Tried to set property "${path}" before riveRef was available.`);
        }
        return;
      }
      switch (propertyType) {
        case PropertyType.Number:
          riveRef.setNumber(path, newValue as number);
          break;
        case PropertyType.Boolean:
          riveRef.setBoolean(path, newValue as boolean);
          break;
        case PropertyType.String:
          riveRef.setString(path, newValue as string);
          break;
        case PropertyType.Enum:
          riveRef.setEnum(path, newValue as string);
          break;
        case PropertyType.Color:
          const parsedColor = typeof newValue === 'string' ? parseColor(newValue) : newValue;
          riveRef.setColor(path, parsedColor as RiveRGBA);
          break;
        default:
          if (__DEV__) {
            console.warn(`[Rive] Unsupported property type: ${propertyType}`);
          }
      }
    },
    [riveRef, path, propertyType]
  );

  return [value, setPropertyValue];
}

type Props = {
  onPlay?: (animationName: string, isStateMachine: boolean) => void;
  onPause?: (animationName: string, isStateMachine: boolean) => void;
  onStop?: (animationName: string, isStateMachine: boolean) => void;
  onLoopEnd?: (animationName: string, loopMode: LoopMode) => void;
  onStateChanged?: (stateMachineName: string, stateName: string) => void;
  onRiveEventReceived?: (event: { name: string; delay: number; properties: any; url: string; target: string }) => void;
  onError?: (rnRiveError: RNRiveError) => void;
  fit?: Fit;
  layoutScaleFactor?: number;
  style?: ViewStyle;
  testID?: string;
  alignment?: Alignment;
  artboardName?: string;
  referencedAssets?: FilesHandledMapping;
  dataBinding?: DataBindBy;
  animationName?: string;
  stateMachineName?: string;
  autoplay?: boolean;
  children?: React.ReactNode;
} & XOR<
  XOR<{ resourceName: string }, { url: string }>,
  { source: number | { uri: string } }
>;

const RiveContainer = React.forwardRef<RiveRef, Props>(function RiveContainer(props, ref) {
  const {
    children,
    onPlay,
    onPause,
    onStop,
    onLoopEnd,
    onStateChanged,
    onRiveEventReceived,
    onError,
    style,
    autoplay = true,
    resourceName: resourceNameProp,
    url: urlProp,
    alignment = Alignment.Center,
    fit = Fit.Contain,
    layoutScaleFactor,
    artboardName,
    referencedAssets,
    dataBinding = AutoBind(false),
    animationName,
    source,
    stateMachineName,
    testID,
  } = props;

  const riveRef = useRef<any>(null);
  const { dispatchCommand } = useRiveCommands(riveRef);
  const resource = useRiveResource({ resourceName: resourceNameProp, url: urlProp, source });
  const onErrorHandler = useRiveErrorHandler(onError);
  const isUserHandlingErrors = onError !== undefined;

  const onPlayHandler = useCallback((event: { nativeEvent: { animationName: string; isStateMachine: boolean } }) => {
    const { animationName: eventAnimationName, isStateMachine } = event.nativeEvent;
    onPlay?.(eventAnimationName, isStateMachine);
  }, [onPlay]);

  const onPauseHandler = useCallback((event: { nativeEvent: { animationName: string; isStateMachine: boolean } }) => {
    const { animationName: eventAnimationName, isStateMachine } = event.nativeEvent;
    onPause?.(eventAnimationName, isStateMachine);
  }, [onPause]);

  const onStopHandler = useCallback((event: { nativeEvent: { animationName: string; isStateMachine: boolean } }) => {
    const { animationName: eventAnimationName, isStateMachine } = event.nativeEvent;
    onStop?.(eventAnimationName, isStateMachine);
  }, [onStop]);

  const onLoopEndHandler = useCallback((event: { nativeEvent: { animationName: string; loopMode: LoopMode } }) => {
    const { animationName: eventAnimationName, loopMode } = event.nativeEvent;
    onLoopEnd?.(eventAnimationName, loopMode);
  }, [onLoopEnd]);

  const onStateChangedHandler = useCallback((event: { nativeEvent: { stateMachineName: string; stateName: string } }) => {
    const { stateMachineName: eventStateMachineName, stateName } = event.nativeEvent;
    onStateChanged?.(eventStateMachineName, stateName);
  }, [onStateChanged]);

  const onRiveEventReceivedHandler = useCallback((event: { nativeEvent: { name: string; delay: number; properties: any; url: string; target: string } }) => {
    const { name, delay, properties, url, target } = event.nativeEvent;
    onRiveEventReceived?.({ name, delay, properties, url, target });
  }, [onRiveEventReceived]);


  useEffect(() => {
    const onPlayListener = DeviceEventEmitter.addListener('onPlay', ({ animationName, isStateMachine }) => {
      onPlay?.(animationName, isStateMachine);
    });
    const onPauseListener = DeviceEventEmitter.addListener('onPause', ({ animationName, isStateMachine }) => {
      onPause?.(animationName, isStateMachine);
    });
    const onStoppedListener = DeviceEventEmitter.addListener('onStop', ({ animationName, isStateMachine }) => {
      onStop?.(animationName, isStateMachine);
    });
    const onLoopEndListener = DeviceEventEmitter.addListener('onLoopEnd', ({ animationName, loopMode }) => {
      onLoopEnd?.(animationName, loopMode);
    });
    const onStateChangedListener = DeviceEventEmitter.addListener('onStateChanged', ({ stateMachineName, stateName }) => {
      onStateChanged?.(stateMachineName, stateName);
    });
    const onRiveEventReceivedListener = DeviceEventEmitter.addListener('onRiveEventReceived', ({ name, delay, properties, url, target }) => {
      onRiveEventReceived?.({ name, delay, properties, url, target });
    });

    const onErrorListener = DeviceEventEmitter.addListener('onError', ({type , message}) => {
      onError?.({ type, message });
    });
    return () => {
      onPlayListener.remove();
      onPauseListener.remove();
      onStoppedListener.remove();
      onLoopEndListener.remove();
      onStateChangedListener.remove();
      onRiveEventReceivedListener.remove();
      onErrorListener.remove();
    }
  })

  const play = useCallback<RiveRef[ViewManagerMethod.play]>(
    (animationName = '', loop = LoopMode.Auto, direction = Direction.Auto, isStateMachine = false) => {
      dispatchCommand(ViewManagerMethod.play, [animationName, loop, direction, isStateMachine]);
    },
    [dispatchCommand]
  );

  const pause = useCallback<RiveRef[ViewManagerMethod.pause]>(() => {
    dispatchCommand(ViewManagerMethod.pause);
  }, [dispatchCommand]);

  const stop = useCallback<RiveRef[ViewManagerMethod.stop]>(() => {
    dispatchCommand(ViewManagerMethod.stop);
  }, [dispatchCommand]);

  const reset = useCallback(() => {
    dispatchCommand(ViewManagerMethod.reset);
  }, [dispatchCommand]);

  const fireState = useCallback<RiveRef[ViewManagerMethod.fireState]>(
    (triggerStateMachineName, inputName) => {
      dispatchCommand(ViewManagerMethod.fireState, [triggerStateMachineName, inputName]);
    },
    [dispatchCommand]
  );

  const setInputState = useCallback<RiveRef['setInputState']>(
    (triggerStateMachineName, inputName, value) => {
      if (typeof value === 'boolean') {
        dispatchCommand(ViewManagerMethod.setBooleanState, [triggerStateMachineName, inputName, value]);
      } else if (typeof value === 'number') {
        dispatchCommand(ViewManagerMethod.setNumberState, [triggerStateMachineName, inputName, value]);
      }
    },
    [dispatchCommand]
  );

  const getBooleanState = useCallback<RiveRef['getBooleanState']>(
    async (inputName): Promise<boolean | null> => {
      try {
        const tag = findNodeHandle(riveRef.current);
        if (!tag || !RiveModule) return null;
        return await RiveModule.getBooleanState(tag, inputName);
      } catch (error) {
        console.error(`Error getting boolean state for input: ${inputName}`, error);
        return null;
      }
    },
    []
  );

  const getNumberState = useCallback<RiveRef['getNumberState']>(
    async (inputName): Promise<number | null> => {
      try {
        const tag = findNodeHandle(riveRef.current);
        if (!tag || !RiveModule) return null;
        return await RiveModule.getNumberState(tag, inputName);
      } catch (error) {
        console.error(`Error getting number state for input: ${inputName}`, error);
        return null;
      }
    },
    []
  );

  const getBooleanStateAtPath = useCallback<RiveRef['getBooleanStateAtPath']>(
    async (inputName, path): Promise<boolean | null> => {
      try {
        const tag = findNodeHandle(riveRef.current);
        if (!tag || !RiveModule) return null;
        return await RiveModule.getBooleanStateAtPath(tag, inputName, path);
      } catch (error) {
        console.error(`Error getting boolean state for input: ${inputName} at path: ${path}`, error);
        return null;
      }
    },
    []
  );

  const getNumberStateAtPath = useCallback<RiveRef['getNumberStateAtPath']>(
    async (inputName, path): Promise<number | null> => {
      try {
        const tag = findNodeHandle(riveRef.current);
        if (!tag || !RiveModule) return null;
        return await RiveModule.getNumberStateAtPath(tag, inputName, path);
      } catch (error) {
        console.error(`Error getting number state for input: ${inputName} at path: ${path}`, error);
        return null;
      }
    },
    []
  );

  const fireStateAtPath = useCallback<RiveRef[ViewManagerMethod.fireStateAtPath]>(
    (inputName, path) => {
      dispatchCommand(ViewManagerMethod.fireStateAtPath, [inputName, path]);
    },
    [dispatchCommand]
  );

  const setInputStateAtPath = useCallback<RiveRef['setInputStateAtPath']>(
    (inputName, value, path) => {
      if (typeof value === 'boolean') {
        dispatchCommand(ViewManagerMethod.setBooleanStateAtPath, [inputName, value, path]);
      } else if (typeof value === 'number') {
        dispatchCommand(ViewManagerMethod.setNumberStateAtPath, [inputName, value, path]);
      }
    },
    [dispatchCommand]
  );

  const touchBegan = useCallback<RiveRef[ViewManagerMethod.touchBegan]>(
    (x: number, y: number) => {
      if (!isNaN(x) && !isNaN(y)) {
        dispatchCommand(ViewManagerMethod.touchBegan, [x, y]);
      }
    },
    [dispatchCommand]
  );

  const touchEnded = useCallback<RiveRef[ViewManagerMethod.touchEnded]>(
    (x: number, y: number) => {
      if (!isNaN(x) && !isNaN(y)) {
        dispatchCommand(ViewManagerMethod.touchEnded, [x, y]);
      }
    },
    [dispatchCommand]
  );

  const setTextRunValue = useCallback<RiveRef[ViewManagerMethod.setTextRunValue]>(
    (textRunName: string, textValue: string) => {
      if (textRunName) {
        dispatchCommand(ViewManagerMethod.setTextRunValue, [textRunName, textValue]);
      }
    },
    [dispatchCommand]
  );

  const setTextRunValueAtPath = useCallback<RiveRef[ViewManagerMethod.setTextRunValueAtPath]>(
    (textRunName: string, textValue: string, path: string) => {
      if (textRunName) {
        dispatchCommand(ViewManagerMethod.setTextRunValueAtPath, [textRunName, textValue, path]);
      }
    },
    [dispatchCommand]
  );

  const setBoolean = useCallback<RiveRef['setBoolean']>(
    (path: string, value: boolean) => {
      dispatchCommand(ViewManagerMethod.setBooleanPropertyValue, [path, value]);
    },
    [dispatchCommand]
  );

  const setString = useCallback<RiveRef['setString']>(
    (path: string, value: string) => {
      dispatchCommand(ViewManagerMethod.setStringPropertyValue, [path, value]);
    },
    [dispatchCommand]
  );

  const setNumber = useCallback<RiveRef['setNumber']>(
    (path: string, value: number) => {
      dispatchCommand(ViewManagerMethod.setNumberPropertyValue, [path, value]);
    },
    [dispatchCommand]
  );

  const setColor = useCallback<RiveRef['setColor']>(
    (path: string, color: RiveRGBA | string) => {
      const parsedColor = typeof color === 'string' ? parseColor(color) : color;
      dispatchCommand(ViewManagerMethod.setColorPropertyValue, [
        path,
        parsedColor.r,
        parsedColor.g,
        parsedColor.b,
        parsedColor.a
      ]);
    },
    [dispatchCommand]
  );

  const setEnum = useCallback<RiveRef['setEnum']>(
    (path: string, value: string) => {
      dispatchCommand(ViewManagerMethod.setEnumPropertyValue, [path, value]);
    },
    [dispatchCommand]
  );

  const trigger = useCallback<RiveRef['trigger']>((path: string) => {
    dispatchCommand(ViewManagerMethod.fireTriggerProperty, [path]);
  }, [dispatchCommand]);

  const internalNativeEmitter = useCallback<RiveRef['internalNativeEmitter']>(() => {
    if (!riveRef.current?._propertyEmitter) {
      riveRef.current._propertyEmitter = new RiveNativeEventEmitter(
        riveRef
      );
    }
    return riveRef.current._propertyEmitter;
  }, [riveRef]);

  const viewTag = useCallback<RiveRef['viewTag']>(() => {
    return findNodeHandle(riveRef.current);
  }, [riveRef]);

  useImperativeHandle(
    ref,
    () => ({
      setInputState,
      getBooleanState,
      getBooleanStateAtPath,
      getNumberState,
      getNumberStateAtPath,
      setInputStateAtPath,
      fireState,
      fireStateAtPath,
      play,
      pause,
      stop,
      reset,
      touchBegan,
      touchEnded,
      setTextRunValue,
      setTextRunValueAtPath,
      setBoolean,
      setString,
      setNumber,
      setColor,
      setEnum,
      trigger,
      internalNativeEmitter,
      viewTag,
    }),
    [
      play,
      pause,
      stop,
      reset,
      setInputState,
      getBooleanState,
      getBooleanStateAtPath,
      getNumberState,
      getNumberStateAtPath,
      setInputStateAtPath,
      fireState,
      fireStateAtPath,
      touchBegan,
      touchEnded,
      setTextRunValue,
      setTextRunValueAtPath,
      setBoolean,
      setString,
      setNumber,
      setColor,
      setEnum,
      trigger,
      internalNativeEmitter,
      viewTag,
    ]
  );

  const convertedAssetHandledSources = useMemo(() => {
    if (!referencedAssets) return undefined;

    const transformedMapping: FilesHandledMapping = {};
    Object.keys(referencedAssets).forEach((key) => {
      const option = referencedAssets[key];
      transformedMapping[key] = {
        ...option,
        source: parsePossibleSources(option.source as RiveAssetPropType),
      };
    });
    return transformedMapping;
  }, [referencedAssets]);

  return (
    <View style={[styles.container, style]} testID={testID}>
      <View style={styles.children}>{children}</View>
      <NativeRiveReactNativeView
        ref={riveRef}
        resourceName={resource.resourceName}
        url={resource.url}
        isUserHandlingErrors={isUserHandlingErrors}
        autoplay={autoplay}
        fit={fit}
        layoutScaleFactor={layoutScaleFactor}
        style={styles.animation}
        onPlay={onPlayHandler}
        onPause={onPauseHandler}
        onStop={onStopHandler}
        onLoopEnd={onLoopEndHandler}
        onStateChanged={onStateChangedHandler}
        onRiveEventReceived={onRiveEventReceivedHandler}
        onError={onErrorHandler}
        alignment={alignment}
        artboardName={artboardName}
        referencedAssets={convertedAssetHandledSources}
        dataBinding={dataBinding}
        animationName={animationName}
        stateMachineName={stateMachineName}
      />
    </View>
  );
});

const styles = StyleSheet.create({
  children: {
    position: 'absolute',
    width: '100%',
    height: '100%',
  },
  container: {
    flexGrow: 1,
  },
  animation: {
    flex: 1,
  },
});

export default RiveContainer;
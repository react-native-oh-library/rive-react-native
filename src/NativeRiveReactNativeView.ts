import type { HostComponent, ViewProps } from 'react-native';
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import { BubblingEventHandler, Int32, WithDefault } from "react-native/Libraries/Types/CodegenTypes";

export interface NativeRiveProps extends ViewProps {
  onPlay?: BubblingEventHandler<{ animationName: string; isStateMachine: boolean }>;
  onPause?: BubblingEventHandler<{ animationName: string; isStateMachine: boolean }>;
  onStop?: BubblingEventHandler<{ animationName: string; isStateMachine: boolean }>;
  onLoopEnd?: BubblingEventHandler<{ animationName: string; loopMode: 'oneShot' | 'loop' | 'pingPong'| 'auto'}>;
  onStateChanged?: BubblingEventHandler<{ stateMachineName: string; stateName: string }>;
  onRiveEventReceived?: BubblingEventHandler<{ name: string; delay: Int32; properties: {}; url: string; target: string }>;
  onError?: BubblingEventHandler<{ type: string; message: string }>;
  isUserHandlingErrors?: WithDefault<boolean, false>;
  autoplay?: WithDefault<boolean, false>;
  fit?: WithDefault<'cover' | 'contain'| 'fill' | 'fitWidth' | 'fitHeight' | 'none' | 'scaleDown' | 'layout', 'cover'>;
  layoutScaleFactor?: Int32;
  alignment?:  WithDefault<'topLeft' | 'topCenter' | 'topRight' | 'centerLeft' | 'center' | 'centerRight' | 'bottomLeft' | 'bottomCenter' | 'bottomRight', 'center'>;
  artboardName?: string;
  referencedAssets?: {};
  dataBinding?: {};
  animationName?: string;
  stateMachineName?: string;
  resourceName?: string;
  url?: string;
  style?: {};
  testID?: string;
}

export default codegenNativeComponent<NativeRiveProps>('RiveReactNativeView') as HostComponent<NativeRiveProps>;

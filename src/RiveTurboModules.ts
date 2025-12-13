import { TurboModuleRegistry } from 'react-native';
import type { Spec as RiveTurboModule } from './RiveModule';

export const RiveModule = TurboModuleRegistry.get<RiveTurboModule>('RiveReactNativeModule');

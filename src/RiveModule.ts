import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  getBooleanState: (tag: number, inputName: string) => Promise<boolean | null>;
  getNumberState: (tag: number, inputName: string) => Promise<number | null>;
  getBooleanStateAtPath: (tag: number, inputName: string, path: string) => Promise<boolean | null>;
  getNumberStateAtPath: (tag: number, inputName: string, path: string) => Promise<number | null>;
}

export default TurboModuleRegistry.get<Spec>('RiveReactNativeModule');

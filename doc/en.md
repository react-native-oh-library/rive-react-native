> Template version: v0.4.0

<p align="center">
  <h1 align="center"> <code>rive-react-native</code> </h1>
</p>

This project is based on [rive-react-native](https://github.com/rive-app/rive-react-native).

Please check the corresponding version information in the Releases section of the third-party library's repository:
| Name | Version | Release Information | Supported RN Version | Supported Autolink | Compile API Version | Community Baseline Version | npm Address     |
| ------------ | ------------ | ------------------------------ | ------------- | ------------- |------------------------ | ------------- | ------------- |
| @react-native-ohos/rive-react-native |  ~9.9.0   | [GitHub Releases](https://github.com/react-native-oh-library/rive-react-native/releases) | 0.82 | Yes | API12+ | 9.7.0 | [Npm Address](https://www.npmjs.com/package/@react-native-ohos/rive-react-native) |
| @react-native-ohos/rive-react-native |  ~9.8.0   | [GitHub Releases](https://github.com/react-native-oh-library/rive-react-native/releases) | 0.72/0.77 | No | API12+ | 9.7.0 | [Npm Address](https://www.npmjs.com/package/@react-native-ohos/rive-react-native) |

## 1. Installation and Usage

Go to the project directory and execute the following instruction:

#### **npm**

```bash
npm install @react-native-ohos/rive-react-native
```

#### **yarn**

```bash
yarn add @react-native-ohos/rive-react-native
```

The following code shows the basic use scenario of the repository:

> [!WARNING] The name of the imported repository remains unchanged.

```tsx
import { SafeAreaView, StyleSheet, ScrollView } from 'react-native';
import Rive from 'rive-react-native';
const url =
  'https://public.rive.app/community/runtime-files/2195-4346-avatar-pack-use-case.riv';
export default function UrlTest() {
  return (
    <ScrollView>
            <SafeAreaView style={styles.safeAreaViewContainer}>
              <ScrollView contentContainerStyle={styles.container}>
                <Rive
                  url={url}
                  artboardName={'Avatar 3'}
                  stateMachineName={'avatar3'}
                  style={styles.animation}
                  autoplay={true}
                />
              </ScrollView>
            </SafeAreaView>
    </ScrollView>
  );
}
const styles = StyleSheet.create({
  safeAreaViewContainer: {
    flex: 1,
  },
  container: {
    flexGrow: 1,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 150,
  },
  animation: {
    width: '100%',
    height: 400,
    marginVertical: 20,
  },
});
```

## 2. Link

|                                      | Supported Autolink | Supported RN Version |
|--------------------------------------|--------------|--------|
| ~9.9.0                               |  Yes              |  0.82     |
| ~9.8.0                               |  No              |  0.72/0.77     |

Projects using AutoLink need to be configured according to this document, AutoLink framework guide.：https://gitcode.com/openharmony-sig/ohos_react_native/blob/master/docs/zh-cn/Autolinking.md

If the version you are using supports Autolink and the project has integrated Autolink, you can skip the ManualLink configuration.

<details>
  <summary>ManualLink: This step provides guidance for manually configuring native dependencies.</summary>

Open the `harmony` directory of the HarmonyOS project in DevEco Studio.

### 2.1. Overrides RN SDK

To ensure the project depends on the same version of the RN SDK, you need to add an `overrides` field in the `harmony/oh-package.json5` file at the project's root directory. This field should point to the RN SDK version required by the project. The version can be a specific version number, a fuzzy version, a local HAR package, or a source code directory.

For more information about this field, please refer to the [official documentation](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/ide-oh-package-json5-V5#zh-cn_topic_0000001792256137_overrides).

```json
{
  "overrides": {
    "@rnoh/react-native-openharmony" : "./react_native_openharmony.har" // Path to local har package
    // "@rnoh/react-native-openharmony" : "./react_native_openharmony" // Point to source code path
  }
}
```

### 2.2. Importing Native Code
- By importing HAR packages;
- By directly linking the source code.

Method 1: Importing via HAR package (Recommended)

> [!TIP]
> The HAR package is located in the `harmony` folder of the third-party library's installation path.

Open `entry/oh-package.json5` and add the following dependency:

```json
"dependencies": {
    "@react-native-ohos/rive-react-native": "file:../../node_modules/@react-native-ohos/rive-react-native/harmony/rive.har"
  }
```

Click the `sync` button in the upper right corner.

Alternatively, run the following instruction on the terminal:

```bash
cd entry
ohpm install
```

Method 2: Directly linking the source code

> [!TIP]
> To link the source code directly, please refer to the [instructions for linking source code directly](./link-source-code.md).

### 2.3.Configure CMakeLists and Import RivePackage

Open `entry/src/main/cpp/CMakeLists.txt` and add the following:

```diff
+ set(OH_MODULES "${CMAKE_CURRENT_SOURCE_DIR}/../../../oh_modules")

# RNOH_BEGIN: manual_package_linking_1
+ add_subdirectory("${OH_MODULES}/@react-native-ohos/rive-react-native/src/main/cpp" ./rive)
# RNOH_END: manual_package_linking_1

# RNOH_BEGIN: manual_package_linking_2
+ target_link_libraries(rnoh_app PUBLIC rnoh_rive)
# RNOH_END: manual_package_linking_2
```

Open `entry/src/main/cpp/PackageProvider.cpp` and add the following:

```diff
#include "RNOH/PackageProvider.h"
#include "SamplePackage.h"
+ #include "RivePackage.h"

using namespace rnoh;

std::vector<std::shared_ptr<Package>> PackageProvider::getPackages(Package::Context ctx) {
    return {
      std::make_shared<SamplePackage>(ctx),
+     std::make_shared<RivePackage>(ctx),
    };
}
```

### 2.4.Introduce RiveView component to ArkTs

Find `function buildCustomRNComponent()`, Generally located in `entry/src/main/ets/pages/index.ets ` or `entry/src/main/ets/rn/LoadBundle.ets`, add:

```diff
  ...
+ import { RiveView } from "@react-native-ohos/rive-react-native";

@Builder
export function buildCustomRNComponent(ctx: ComponentBuilderContext) {
  ...
+ if (ctx.componentName === RiveView.NAME) {
+   RiveView({
+     ctx: ctx.rnComponentContext,
+     tag: ctx.tag,
+   })
+ }
...
}
...
```
In `entry/src/main/ets/pages/index.ets`, if the `arkTsComponentNames` array (new in later versions) exists in the current file, add the following:`RiveView.NAME`;

```ts
  ...
 const arkTsComponentNames: Array<string> = [..., RiveView.NAME]; 
  ...
```



### 2.5.Introducing RiveModulePackage to ArkTS

Open the `entry/src/main/ets/RNPackagesFactory.ets` file and add the following code:

```diff
  ... 
+ import { RiveModulePackage } from '@react-native-ohos/rive-react-native/ts';

export function createRNPackages(ctx: RNPackageContext): RNPackage[] {
  return [
    new SamplePackage(ctx),
+   new RiveModulePackage(ctx),
  ];
}
```
</details>

### 2.6.Run

Click the `sync` button in the upper right corner.

Alternatively, run the following instruction on the terminal:

```bash
cd entry
ohpm install
```

Then build and run the code.

## 3.  Constraints

### 3.1. Compatibility

To use this repository, you need to use the correct React-Native and RNOH versions. In addition, you need to use DevEco Studio and the ROM on your phone.

Verified in the following versions.

1. RNOH: 0.72.96; SDK: HarmonyOS 6.0.0 Release SDK; IDE: DevEco Studio 6.0.0.858; ROM: 6.0.0.112;
2. RNOH: 0.72.33; SDK: HarmonyOS NEXT B1; IDE: DevEco Studio: 5.0.3.900; ROM: Next.0.0.71;
3. RNOH: 0.77.18; SDK: HarmonyOS 6.0.0 Release SDK; IDE: DevEco Studio 6.0.0.858; ROM: 6.0.0.112;


### 3.2. Permission Requirements

- If the resource uses a network URL, the application needs to apply for network permissions

Open `entry/src/main/module.json5` and add the following information:

```json
requestPermissions: [
  {
    name: "ohos.permission.INTERNET",
  },
],
```

- If the resourceName attribute is used, the resource file needs to be placed in the corresponding path under the rawfile of the HarmonyOS project

rawfile path：`entry/src/main/resources/rawfile`


## 4.Properties

> [!tip] The **Platform** column indicates the platform where the properties are supported in the original third-party library.

> [!tip] If the value of **HarmonyOS Support** is **yes**, it means that the HarmonyOS platform supports this property; **no** means the opposite; **partially** means some capabilities of this property are supported. The usage method is the same on different platforms and the effect is the same as that of iOS or Android.

| Name                                     | Description                                                                                                                                                                                                                                                         | Type                           | Required | Platform     | HarmonyOS Support          |
| ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------ | -------- | ------------ | -------------------------- |
| children                              | Allow custom UI elements to be layered above Rive animations                                                                                                                                                                                                                       | ReactNode                         | no       | ios，android | yes                        |
| onPlay                              | Trigger event response when animation starts playing                                                                                                                                                                                                                       | animationName: string, isStateMachine: boolean                         | no       | ios，android | yes                        |
| onPause                              | Trigger event response when animation pauses                                                                                                                                                                                                                       | animationName: string, isStateMachine: boolean                         | no       | ios，android | yes                        |
| onStop                              | Trigger event response when animation stops                                                                                                                                                                                                                       | animationName: string, isStateMachine: boolean                         | no       | ios，android | yes                        |
| onLoopEnd                              | Trigger event response when animation completes loop                                                                                                                                                                                                                       | animationName: string, loopMode: LoopMode                         | no       | ios，android | yes                        |
| onStateChanged                              | Trigger event response when animation state machine switches states                                                                                                                                                                                                                       | stateMachineName: string, stateName: string                        | no       | ios，android | yes                        |
| onRiveEventReceived                              | Respond to callbacks when triggering custom events for animations                                                                                                                                                                                                                       | name: string; delay: number; properties: any; url: string; target: string                        | no       | ios，android | yes                        |
| onError                              | Trigger event response when an error occurs                                                                                                                                                                                                                       | rnRiveError: RNRiveError                      | no       | ios，android | yes                        |
| style                              | Container style                                                                                                                                                                                                                      | StyleProp<ViewStyle>                      | no       | ios，android | yes                        |
| autoplay                              | Whether to automatically play animations                                                                                                                                                                                                                      | boolean                     | no       | ios，android | yes                        |
| resourceName                              | Local resource name (must match the .riv file name)                                                                                                                                                                                                                      | string                     | no       | ios，android | yes                        |
| url                              | . riv file network resource URL                                                                                                                                                                                                                      | string                     | no       | ios，android | yes                        |
| alignment                              | Alignment of animations within containers                                                                                                                                                                                                                      | 'topLeft' 、'topCenter' 、 'topRight' 、 'centerLeft' 、 'center' 、 'centerRight' 、 'bottomLeft' 、 'bottomCenter' 、 'bottomRight'                     | no       | ios，android | yes                        |
| fit                              | Zoom mode | 'cover' 、 'contain'、 'fill' 、 'fitWidth' 、 'fitHeight' 、 'none' 、 'scaleDown' 、 'layout'                     | no       | ios，android | yes                        |
| layoutScaleFactor         | Custom layout scaling factor | number                     | no       | ios，android | yes                        |
| artboardName         | Specify a specific drawing board to load from the file | string                     | no       | ios，android | yes                        |
| animationName         | Play an animation with the specified name | string                     | no       | ios，android | yes                        |
| stateMachineName         | Enable state machine with specified name | string                     | no       | ios，android | yes                        |  
| referencedAssets         | External incoming resource references | {}                     | no       | ios，android | yes                        |
| dataBinding         | Bind dynamic data source | {}                     | no       | ios，android | yes                        |
| testID         | Used for testing framework positioning components | string                     | no       | ios，android | yes                        |
| fireState         | Trigger specific named events in the state machine | stateMachineName: string, inputName: string                     | no       | ios，android | yes                        |
| setInputState         | Set the numerical values (Boolean/numeric) of the input parameters for the state machine | stateMachineName: string,inputName:string,value: boolean/ number                     | no       | ios，android | yes                        |
| getBooleanState         | Get the current value of Boolean type | inputName:string                     | no       | ios，android | yes                        |
| getNumberState         | Get the current value of the numeric type | inputName:string                     | no       | ios，android | yes                        |
| getBooleanStateAtPath         | Retrieve the current value of a Boolean type in the specified path| inputName:string, path:string                     | no       | ios，android | yes                        |
| getNumberStateAtPath         | Get the current value of the numeric type in the specified path|inputName:string, path:string| no       | ios，android | yes                        |
| fireStateAtPath         | Trigger events in the specified path| inputName:string, path:string|no       | ios，android | yes                        |
| setInputStateAtPath         | Set the values of parameters in the specified path| inputName:string,value: boolean/number,path: string|no       | ios，android | yes                        |
| play         |Play animation|animationName?: string,loop?: LoopMode,direction?: Direction,isStateMachine?:boolean|no       | ios，android | yes                        |
| pause         |Pause current playback|No|no       | ios，android | yes                        |
| stop         |Stop playback|No|no       | ios，android | yes                        |
| reset         |Reset animation|No|no       | ios，android | yes                        |
| touchBegan         |Trigger touch start event at specified coordinates|x: number, y: number|no       | ios，android | yes                        |
| touchEnded         |Trigger touch end event at specified coordinates|x: number, y: number|no       | ios，android | yes                        |
| setTextRunValue         |Dynamically modify text content|textRunName: string, value: string|no       | ios，android | yes                        |
| setTextRunValueAtPath         |Modify the text content in the specified path|textRunName: string, value: string,path: string|no       | ios，android | yes                        |
| setBoolean         |Modify Boolean type in the specified path|path: string, value: boolean|no       | ios，android | no                        |
| setString         |Modify the string in the specified path|path: string, value: string|no       | ios，android | yes                        |
| setNumber         |Modify the number in the specified path|path: string, value: number|no       | ios，android | yes                        |
| setColor         |Modify the color attribute under the specified path|path: string, color: RiveRGBA/string|no       | ios，android | yes                        |
| setEnum         |Modify the enumeration type in the specified path|path: string, value: string|no       | ios，android | yes                        |
| trigger         |triggering events|path: string|no       | ios，android | yes                        |
| internalNativeEmitter         |Get native event emitter|No|no       | ios，android | yes                        |
| viewTag         |Get associated view labels|No|no       | ios，android | yes                        |

## 5.Known Issues

## 6.Others

## 7.License

This project is licensed under [The MIT License (MIT)](https://github.com/rive-app/rive-react-native/blob/main/LICENSE).

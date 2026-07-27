> 模板版本：v0.4.0

<p align="center">
  <h1 align="center"> <code>rive-react-native</code> </h1>
</p>

本项目基于 [rive-react-native](https://github.com/rive-app/rive-react-native) 开发。

该第三方库的仓库已迁移至 Gitcode，且支持直接从 npm 下载，新的包名为：`@react-native-ohos/rive-react-native` 版本所属关系如下：
| 三方库名称    | 三方库版本    | 发布信息     | 支持RN版本    | Autolink     | 编译API版本     | 社区基线版本    | npm地址                |
| ------------ | ------------ | ------------------------------ | ------------- | ------------- |------------------------ | ------------- | ------------- |
| @react-native-ohos/rive-react-native |  ~9.9.0   | [GitHub Releases](https://github.com/react-native-oh-library/rive-react-native/releases) | 0.82 | 是 | API12+ | 9.7.0 | [Npm Address](https://www.npmjs.com/package/@react-native-ohos/rive-react-native) |
| @react-native-ohos/rive-react-native |  ~9.8.0   | [GitHub Releases](https://github.com/react-native-oh-library/rive-react-native/releases) | 0.72/0.77 | 否 | API12+ | 9.7.0 | [Npm Address](https://www.npmjs.com/package/@react-native-ohos/rive-react-native) |

## 1. 安装与使用

进入到工程目录并输入以下命令：

#### **npm**

```bash
npm install @react-native-ohos/rive-react-native
```

#### **yarn**

```bash
yarn add @react-native-ohos/rive-react-native
```

下面的代码展示了这个库的基本使用场景：

> [!WARNING] 使用时 import 的库名不变。

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

|                                      | 是否支持autolink | RN框架版本 |
|--------------------------------------|-----------------|------------|
| ~9.9.0                               |  Yes              |  0.82     |
| ~9.8.0                               |  No              |  0.72/0.77     |

使用AutoLink的工程需要根据该文档配置，Autolink框架指导文档：https://gitcode.com/openharmony-sig/ohos_react_native/blob/master/docs/zh-cn/Autolinking.md

如您使用的版本支持 Autolink，并且工程已接入 Autolink，可跳过ManualLink配置。
<details>
  <summary>ManualLink: 此步骤为手动配置原生依赖项的指导</summary>

首先需要使用 DevEco Studio 打开项目里的 HarmonyOS 工程 `harmony`

### 2.1. Overrides RN SDK

为了让工程依赖同一个版本的 RN SDK，需要在工程根目录的 `oh-package.json5` 添加 overrides 字段，指向工程需要使用的 RN SDK 版本。替换的版本既可以是一个具体的版本号，也可以是一个模糊版本，还可以是本地存在的 HAR 包或源码目录。

关于该字段的作用请阅读[官方说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V5/ide-oh-package-json5-V5#zh-cn_topic_0000001792256137_overrides)：

```json
{
  "overrides": {
    "@rnoh/react-native-openharmony" : "./react_native_openharmony.har" // Path to local har package
    // "@rnoh/react-native-openharmony" : "./react_native_openharmony" // Point to source code path
  }
}
```

### 2.2 引入原生端代码

目前有两种方法：

1. 通过 har 包引入（在 IDE 完善相关功能后该方法会被遗弃，目前首选此方法）；
2. 直接链接源码。

方法一：通过 har 包引入

> [!TIP] har 包位于三方库安装路径的 `harmony` 文件夹下。

打开 `entry/oh-package.json5`，添加以下依赖

```json
"dependencies": {
    "@react-native-ohos/rive-react-native": "file:../../node_modules/@react-native-ohos/rive-react-native/harmony/rive.har"
  }
```

点击右上角的 `sync` 按钮

或者在终端执行：

```bash
cd entry
ohpm install
```

方法二：直接链接源码

> [!TIP] 如需使用直接链接源码，请参考[直接链接源码说明](./link-source-code.md)

### 2.3.配置 CMakeLists 和引入 RivePackage

打开 `entry/src/main/cpp/CMakeLists.txt`，添加：

```diff
project(rnapp)
cmake_minimum_required(VERSION 3.4.1)
set(CMAKE_SKIP_BUILD_RPATH TRUE)
set(RNOH_APP_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
set(NODE_MODULES "${CMAKE_CURRENT_SOURCE_DIR}/../../../../../node_modules")
+ set(OH_MODULES "${CMAKE_CURRENT_SOURCE_DIR}/../../../oh_modules")
set(RNOH_CPP_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../../../../react-native-harmony/harmony/cpp")
set(LOG_VERBOSITY_LEVEL 1)
set(CMAKE_ASM_FLAGS "-Wno-error=unused-command-line-argument -Qunused-arguments")
set(CMAKE_CXX_FLAGS "-fstack-protector-strong -Wl,-z,relro,-z,now,-z,noexecstack -s -fPIE -pie")
set(WITH_HITRACE_SYSTRACE 1) # for other CMakeLists.txt files to use
add_compile_definitions(WITH_HITRACE_SYSTRACE)

add_subdirectory("${RNOH_CPP_DIR}" ./rn)

# RNOH_BEGIN: manual_package_linking_1
add_subdirectory("../../../../sample_package/src/main/cpp" ./sample-package)
+ add_subdirectory("${OH_MODULES}/@react-native-ohos/rive-react-native/src/main/cpp" ./rive)
# RNOH_END: manual_package_linking_1

file(GLOB GENERATED_CPP_FILES "./generated/*.cpp")

add_library(rnoh_app SHARED
    ${GENERATED_CPP_FILES}
    "./PackageProvider.cpp"
    "${RNOH_CPP_DIR}/RNOHAppNapiBridge.cpp"
)
target_link_libraries(rnoh_app PUBLIC rnoh)

# RNOH_BEGIN: manual_package_linking_2
target_link_libraries(rnoh_app PUBLIC rnoh_sample_package)
+ target_link_libraries(rnoh_app PUBLIC rnoh_rive)
# RNOH_END: manual_package_linking_2
```

打开 `entry/src/main/cpp/PackageProvider.cpp`，添加：

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

### 2.4.在 ArkTs 侧引入 RiveView 组件

找到 `function buildCustomRNComponent()`，一般位于 `entry/src/main/ets/pages/index.ets` 或 `entry/src/main/ets/rn/LoadBundle.ets`，添加：

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
在`entry/src/main/ets/pages/index.ets`中，如果当前文件中存在`arkTsComponentNames`数组(后续版本新增内容)，则需要在其中追加：`RiveView.NAME`;

```ts
  ...
 const arkTsComponentNames: Array<string> = [..., RiveView.NAME]; 
  ...
```



### 2.5.在 ArkTs 侧引入 RiveModulePackage

打开 `entry/src/main/ets/RNPackagesFactory.ets`，添加：

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

### 2.6.运行

点击右上角的 `sync` 按钮

或者在终端执行：

```bash
cd entry
ohpm install
```

然后编译、运行即可。

## 3.  约束与限制

### 3.1.兼容性

本文档内容基于以下环境验证通过：
1. RNOH:0.72.96; SDK: HarmonyOS 6.0.0 Release SDK; IDE: DevEco Studio  6.0.0.868; ROM: 6.0.0.112;
2. RNOH:0.77.18; SDK: HarmonyOS 6.0.0 Release SDK; IDE: DevEco Studio  6.0.0.868; ROM: 6.0.0.112;
3. RNOH:0.82.1; SDK: HarmonyOS 6.0.1 Release SDK; IDE: DevEco Studio 6.0.1 Release; ROM:6.0.0.120 SP7;


### 3.2.权限要求

- 如果资源使用网络 url 应用需要申请网络权限

  在`entry/src/main/module.json5`中添加

```json
requestPermissions: [
  {
    name: "ohos.permission.INTERNET",
  },
],
```

- 如果使用的 resourceName 属性，需要将资源文件放置到 HarmonyOS 工程 rawfile 下对应的路径中

rawfile 路径：`entry/src/main/resources/rawfile`


## 4.属性

> [!TIP] "Platform"列表示该属性在原三方库上支持的平台。

> [!TIP] "HarmonyOS Support"列为 yes 表示 HarmonyOS 平台支持该属性；no 则表示不支持；partially 表示部分支持。使用方法跨平台一致，效果对标 iOS 或 Android 的效果。

| Name                                     | Description                                                                                                                                                                                                                                                         | Type                           | Required | Platform     | HarmonyOS Support          |
| ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------ | -------- | ------------ | -------------------------- |
| children                              | 允许自定义UI元素叠加在Rive动画之上                                                                                                                                                                                                          | ReactNode                         | no       | ios，android | yes                        |
| onPlay                              | 当动画开始播放时触发事件响应                                                                                                                                                                                                                       | animationName: string, isStateMachine: boolean                         | no       | ios，android | yes                        |
| onPause                              | 当动画暂停播放时触发事件响应                                                                                                                                                                                                                       | animationName: string, isStateMachine: boolean                         | no       | ios，android | yes                        |
| onStop                              | 当动画停止时触发事件响应                                                                                                                                                                                                                       | animationName: string, isStateMachine: boolean                         | no       | ios，android | yes                        |
| onLoopEnd                              | 当动画完成循环播放时触发事件响应                                                                                                                                                                                                                       | animationName: string, loopMode: LoopMode                         | no       | ios，android | yes                        |
| onStateChanged                              | 当动画状态机状态切换时触发事件响应                                                                                                                                                                                                                       | stateMachineName: string, stateName: string                        | no       | ios，android | yes                        |
| onRiveEventReceived                              | 在触发动画自定义事件时响应回调                                                                                                                                                                                                                       | name: string; delay: number; properties: any; url: string; target: string                        | no       | ios，android | yes                        |
| onError                              | 发生错误时触发事件响应                                                                                                                                                                                                                       | rnRiveError: RNRiveError                      | no       | ios，android | yes                        |
| style                              | 样式                                                                                                                                                                                                                      | StyleProp<ViewStyle>                      | no       | ios，android | yes                        |
| autoplay                              | 是否自动播放动画                                                                                                                                                                                                                      | boolean                     | no       | ios，android | yes                        |
| resourceName                              | 本地资源名称（必须与.riv文件名匹配）                                                                                                                                                                                                                      | string                     | no       | ios，android | yes                        |
| url                              | .riv文件网络资源URL                                                                                                                                                                                                                      | string                     | no       | ios，android | yes                        |
| alignment                              | 容器内动画的对齐方式                                                                                                                                                                                                                      | 'topLeft' 、'topCenter' 、 'topRight' 、 'centerLeft' 、 'center' 、 'centerRight' 、 'bottomLeft' 、 'bottomCenter' 、 'bottomRight'                     | no       | ios，android | yes                        |
| fit                              | 缩放模式 | 'cover' 、 'contain'、 'fill' 、 'fitWidth' 、 'fitHeight' 、 'none' 、 'scaleDown' 、 'layout'                     | no       | ios，android | yes                        |
| layoutScaleFactor         | 自定义布局缩放系数 | number                     | no       | ios，android | yes                        |
| artboardName         | 指定要从文件加载的特定画板 | string                     | no       | ios，android | yes                        |
| animationName         | 播放具有指定名称的动画 | string                     | no       | ios，android | yes                        |
| stateMachineName         | 启用指定名称的状态机 | string                     | no       | ios，android | yes                        |  
| referencedAssets         | 外部传入的资源引用 | {}                     | no       | ios，android | yes                        |
| dataBinding         | 绑定动态数据源 | {}                     | no       | ios，android | yes                        |
| testID         | 用于测试框架定位组件 | string                     | no       | ios，android | yes                        |
| fireState         | 在状态机中触发特定命名事件 | stateMachineName: string, inputName: string                     | no       | ios，android | yes                        |
| setInputState   | 设置状态机输入参数的数值（布尔值/数值）| stateMachineName: string,inputName:string,value: boolean/ number  | no       | ios，android | no                        |
| getBooleanState         | 获取布尔类型的当前值| inputName:string                     | no       | ios，android | yes                        |
| getNumberState         | 获取数值类型的当前值| inputName:string | no       | ios，android | yes                        |
| getBooleanStateAtPath         | 获取指定路径下布尔类型的当前值| inputName:string, path:string                     | no       | ios，android | yes                        |
| getNumberStateAtPath         | 获取指定路径下数值类型的当前值|inputName:string, path:string| no       | ios，android | yes                        |
| fireStateAtPath         | 触发指定路径下的事件| inputName:string, path:string|no       | ios，android | yes                        |
| setInputStateAtPath         | 设置指定路径下参数的数值| inputName:string,value: boolean/number,path: string|no       | ios，android | yes                        |
| play         |播放动画|animationName?: string,loop?: LoopMode,direction?: Direction,isStateMachine?:boolean|no       | ios，android | yes                        |
| pause         |暂停当前播放|无|no       | ios，android | yes                        |
| stop         |停止播放|无|no       | ios，android | yes                        |
| reset         |重置动画|无|no       | ios，android | yes                        |
| touchBegan         |在指定坐标触发触摸开始事件|x: number, y: number|no       | ios，android | yes                        |
| touchEnded         |在指定坐标触发触摸结束事件|x: number, y: number|no       | ios，android | yes                        |
| setTextRunValue         |动态修改文本内容|textRunName: string, value: string|no       | ios，android | yes                        |
| setTextRunValueAtPath         |修改指定路径下的文本内容|textRunName: string, value: string,path: string|no       | ios，android | yes                        |
| setBoolean         |修改指定路径中的布尔类型|path: string, value: boolean|no       | ios，android | yes                        |
| setString         |修改指定路径下的字符串|path: string, value: string|no       | ios，android | yes                        |
| setNumber         |修改指定路径下数值|path: string, value: number|no       | ios，android | yes                        |
| setColor         |修改指定路径下的颜色属性|path: string, color: RiveRGBA/string|no       | ios，android | yes                        |
| setEnum         |修改指定路径下的枚举类型|path: string, value: string|no       | ios，android | yes                        |
| trigger         |触发事件|path: string|no       | ios，android | yes                        |
| internalNativeEmitter         |获取原生事件发射器|无|no       | ios，android | yes                        |
| viewTag         |获取关联的视图标签|无|no       | ios，android | yes                        |

## 5.遗留问题

## 6.其他

## 7.开源协议

本项目基于 [The MIT License (MIT)](https://github.com/rive-app/rive-react-native/blob/main/LICENSE) ，请自由地享受和参与开源。

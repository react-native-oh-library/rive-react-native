import { RendererType } from "rive_ohos";

export enum RNRiveRendererType {
  Rive = 'rive',
  Canvas = 'canvas'
}

const RNRiveRendererTypeValues = [
  RNRiveRendererType.Rive,
  RNRiveRendererType.Canvas
];

export class RNRiveRendererTypeUtil {

  static mapToRNRiveRendererType(rendererType: string): RNRiveRendererType {
    for (const type of RNRiveRendererTypeValues) {
      if (type === rendererType) {
        return type;
      }
    }
    throw new Error(`No enum constant for renderer type: ${rendererType}`);
  }

  static mapToRiveRendererType(rnRendererType: RNRiveRendererType): RendererType {
    switch (rnRendererType) {
      case RNRiveRendererType.Rive:
        return RendererType.Rive;
      case RNRiveRendererType.Canvas:
        return RendererType.Canvas;
      default:
        throw new Error(`Unsupported renderer type: ${rnRendererType}`);
    }
  }
}
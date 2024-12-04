using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public struct CameraBufferSettings {

    public const float renderScaleMin = 0.1f, renderScaleMax = 2f;

    public bool allowHDR;

    public bool copyColor, copyColorReflection, copyDepth, copyDepthReflection;

    [Range(renderScaleMin, renderScaleMax)]
    public float renderScale;

    public enum BicubicRescalingMode { Off, UpOnly, UpAndDown }

    public BicubicRescalingMode bicubicRescaling;
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using UnityEngine.Rendering;

[Serializable]
public class CameraSettings {

    public const float renderScaleMin = 0.1f, renderScaleMax = 2f;

    [Serializable]
    public struct FinalBlendMode {

        public BlendMode source, destination;
    }

    public FinalBlendMode finalBlendMode = new FinalBlendMode {
        source = BlendMode.One,
        destination = BlendMode.Zero
    };

    public bool overridePostFX = false;

    public PostFXSettings postFXSettings = default;

    [RenderingLayerMaskField]
    public int renderingLayerMask = -1;

    public bool maskLights = false;

    public bool copyColor = true, copyDepth = true;

    public enum RenderScaleMode { Inherit, Multiply, Override }

    public RenderScaleMode renderScaleMode = RenderScaleMode.Inherit;

    [Range(renderScaleMin, renderScaleMax)]
    public float renderScale = 1f;

    public float GetRenderScale (float scale) {
        return
            renderScaleMode == RenderScaleMode.Inherit ? scale :
            renderScaleMode == RenderScaleMode.Override ? renderScale :
            scale * renderScale;
    }

}

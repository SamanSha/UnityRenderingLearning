using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

partial class CustomRenderPipelineAsset : RenderPipelineAsset {

#if UNITY_EDITOR

    static string[] renderingLayerNames;

    static CustomRenderPipelineAsset () {
        renderingLayerNames = new string[31];
        for (int i = 0; i < renderingLayerNames.Length; i++) {
            renderingLayerNames[i] = "Layer " + (i + 1);
        }
    }

    public override string[] renderingLayerMaskNames => renderingLayerNames;

#endif
}

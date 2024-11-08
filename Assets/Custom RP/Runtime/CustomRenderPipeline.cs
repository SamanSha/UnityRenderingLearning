using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public partial class CustomRenderPipeline : RenderPipeline {

    bool allowHDR;

    CameraRender renderer = new CameraRender();

    bool useDynamicBatching, useGPUInstancing, useLightsPerObject;

    ShadowSettings shadowSettings;

    PostFXSettings postFXSettings;

    public CustomRenderPipeline (
        bool allowHDR, 
        bool useDynamicBatching, bool useGPUInstancing, bool useSRPBatcher,
        bool useLightsPerObject, ShadowSettings shadowSettings, 
        PostFXSettings postFXSettings
    ) {
        this.allowHDR = allowHDR;
        this.postFXSettings = postFXSettings;
        this.shadowSettings = shadowSettings;
        this.useDynamicBatching = useDynamicBatching;
        this.useGPUInstancing = useGPUInstancing;
        this.useLightsPerObject = useLightsPerObject;
        GraphicsSettings.useScriptableRenderPipelineBatching = useSRPBatcher;
        GraphicsSettings.lightsUseLinearIntensity = true;
        InitializeForEditor();
    }

    protected override void Render (
        ScriptableRenderContext context, Camera[] cameras    
    ) {

    }

    protected override void Render (
        ScriptableRenderContext context, List<Camera> cameras
    ) {
        for (int i = 0; i < cameras.Count; i++) {
            renderer.Render(
                context, cameras[i], allowHDR, 
                useDynamicBatching, useGPUInstancing, useLightsPerObject, 
                shadowSettings, postFXSettings
            );
        }
    }
}

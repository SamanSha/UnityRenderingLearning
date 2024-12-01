using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public struct CameraBufferSettings {

    public bool allowHDR;

    public bool copyColor, copyColorReflection, copyDepth, copyDepthReflection;
}
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShadowProjector : MonoBehaviour
{
    public Projector shadowProjector;

    public Camera lightCamera;

    public RenderTexture depthTexture;

    public Shader depthShader;

    void Start()
    {
        shadowProjector = this.gameObject.GetComponent<Projector>();
        lightCamera = this.gameObject.AddComponent<Camera>();

        shadowProjector.orthographic = lightCamera.orthographic = true;
        shadowProjector.orthographicSize = lightCamera.orthographicSize = 5;
        shadowProjector.farClipPlane = lightCamera.farClipPlane;
        shadowProjector.nearClipPlane = lightCamera.nearClipPlane;
        shadowProjector.fieldOfView = lightCamera.fieldOfView;

        lightCamera.cullingMask = shadowProjector.ignoreLayers;

        lightCamera.clearFlags = CameraClearFlags.SolidColor;
        lightCamera.backgroundColor = new Color(0, 0, 0, 1);

        lightCamera.transform.SetPositionAndRotation(transform.position, transform.rotation);

        lightCamera.targetTexture = depthTexture;
        depthShader = Shader.Find("DepthBuffer");
        lightCamera.SetReplacementShader(depthShader, "RenderType");
    }

    void Update()
    {
        if (depthTexture == null)
        {
            depthTexture = new RenderTexture(256, 256, 0, RenderTextureFormat.ARGB32);
            depthTexture.wrapMode = TextureWrapMode.Clamp;
        }

        lightCamera.targetTexture = depthTexture;
        shadowProjector.material.SetTexture("_ShadowMapDepthTex", depthTexture);
    }
}

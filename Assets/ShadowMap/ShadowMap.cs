using System.Collections;
using System.Collections.Generic;
using UnityEngine;
 
public class ShadowMap : MonoBehaviour
{
    public Camera lightCamera;

    public RenderTexture depthTexture;

	void Start ()
    {
        lightCamera = this.gameObject.AddComponent<Camera>();
        lightCamera.orthographic = true;
        lightCamera.orthographicSize = 10;
        lightCamera.clearFlags = CameraClearFlags.SolidColor;
        lightCamera.backgroundColor = new Color(1, 1, 1, 0);

        lightCamera.aspect = 1.0f;
        lightCamera.transform.SetPositionAndRotation(transform.position, transform.rotation);

        depthTexture = new RenderTexture(1024, 1024, 0);
        depthTexture.wrapMode = TextureWrapMode.Clamp;

        lightCamera.targetTexture = depthTexture;
        lightCamera.SetReplacementShader(Shader.Find("DepthBuffer"), "RenderType");
	}
	
	void Update ()
    {
        //lightCamera.Render();
        Matrix4x4 mt = GL.GetGPUProjectionMatrix(lightCamera.projectionMatrix, false) * lightCamera.worldToCameraMatrix;

        Shader.SetGlobalMatrix("_ShadowMapLightProjectView", mt);
        Shader.SetGlobalTexture("_ShadowMapDepthTex", depthTexture);
	}
}

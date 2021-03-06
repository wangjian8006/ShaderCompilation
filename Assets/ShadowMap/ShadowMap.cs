﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
 
public class ShadowMap : MonoBehaviour
{
    public Camera lightCamera;

    public RenderTexture depthTexture;

    public Shader depthShader;

	void Start ()
    {
        lightCamera = this.gameObject.AddComponent<Camera>();
        lightCamera.orthographic = true;
        lightCamera.orthographicSize = 5;
        lightCamera.clearFlags = CameraClearFlags.SolidColor;
        lightCamera.aspect = Camera.main.aspect;
        lightCamera.backgroundColor = new Color(0, 0, 0, 1);

        lightCamera.transform.SetPositionAndRotation(transform.position, transform.rotation);
        
        lightCamera.targetTexture = depthTexture;
        depthShader = Shader.Find("DepthBuffer");
        lightCamera.SetReplacementShader(depthShader, "RenderType");
	}
	
	void Update ()
    {
        if (depthTexture == null)
        {
            depthTexture = new RenderTexture(256, 256, 0, RenderTextureFormat.ARGB32);
            depthTexture.wrapMode = TextureWrapMode.Clamp;
        }

        lightCamera.targetTexture = depthTexture;

        Matrix4x4 mt = GL.GetGPUProjectionMatrix(lightCamera.projectionMatrix, false) * lightCamera.worldToCameraMatrix;
        Shader.SetGlobalMatrix("_ShadowMapLightProjectView", mt);
        Shader.SetGlobalTexture("_ShadowMapDepthTex", depthTexture);
        Shader.SetGlobalFloat("_ShadowMapDepthTexWidth", depthTexture.width);
        Shader.SetGlobalFloat("_ShadowMapDepthTexHeight", depthTexture.height);

        //lightCamera.RenderWithShader(depthShader, "RenderType");
	}
}

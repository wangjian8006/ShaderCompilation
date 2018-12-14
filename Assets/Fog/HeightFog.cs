using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HeightFog : MonoBehaviour
{
    public Color fogColor = Color.white;

    public float fogIntensity = 1.0f;

    public float fogStart = 0.0f;

    public float fogEnd = 2.0f;

    public Vector3 noiseValue = Vector3.zero;

    public Texture noiseTexture;

    private Camera m_camera;

    Camera camera
    {
        get
        {
            if (m_camera == null)
            {
                m_camera = Camera.main;
                cameraTransform = camera.transform;
            }
            return m_camera;
        }
    }

    Transform cameraTransform;

    Material material;

	void Start ()
    {
        material = new Material(Shader.Find("HeightFogFogShader"));
	}

    void OnEnable()
    {
        camera.depthTextureMode |= DepthTextureMode.Depth;
    }
	
	void OnRenderImage (RenderTexture src, RenderTexture dest)
    {
        Matrix4x4 frustumCorners = Matrix4x4.identity;
        float fov = camera.fieldOfView;
        float near = camera.nearClipPlane;
        float aspect = camera.aspect;

        float halfHeight = near * Mathf.Tan(fov * 0.5f * Mathf.Deg2Rad);
        Vector3 toTop = cameraTransform.up * halfHeight;
        Vector3 toRight = cameraTransform.right * halfHeight * aspect;

        Vector3 TL = cameraTransform.forward * near + toTop - toRight;
        Vector3 TR = cameraTransform.forward * near + toTop + toRight;
        Vector3 BL = cameraTransform.forward * near - toTop - toRight;
        Vector3 BR = cameraTransform.forward * near - toTop + toRight;

        float scale = TL.magnitude / near;

        TL = TL.normalized * scale;
        TR = TR.normalized * scale;
        BL = BL.normalized * scale;
        BR = BR.normalized * scale;

        frustumCorners.SetRow(0, TL);
        frustumCorners.SetRow(1, TR);
        frustumCorners.SetRow(2, BL);
        frustumCorners.SetRow(3, BR);

        material.SetMatrix("_FrustumCorners", frustumCorners);
        material.SetFloat("_FogIntensity", fogIntensity);
        material.SetColor("_FogColor", fogColor);
        material.SetFloat("_FogStart", fogStart);
        material.SetFloat("_FogEnd", fogEnd);
        material.SetVector("_NoiseValue", noiseValue);
        material.SetTexture("_NoiseTex", noiseTexture);

        Graphics.Blit(src, dest, material);
	}
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionVelocityBlur : MonoBehaviour
{
    [Range(0.0f, 0.9f)]
    public float m_blurAmount = 0.1f;

    private Material mat;

    private Matrix4x4 preViewProjectionMatrix = Matrix4x4.identity;

    public bool clear = false;

	void Start ()
    {
        mat = new Material(Shader.Find("MotionVelocityBlur"));
        mat.hideFlags = HideFlags.DontSave;

        preViewProjectionMatrix = Camera.main.projectionMatrix * Camera.main.worldToCameraMatrix;
	}

    void OnEnable()
    {
        Camera.main.depthTextureMode |= DepthTextureMode.Depth;
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        mat.SetFloat("_BlurAmount", m_blurAmount);
        mat.SetMatrix("_PreViewProjectionMatrix", preViewProjectionMatrix);

        Matrix4x4 currentViewProjectionMatrix = Camera.main.projectionMatrix * Camera.main.worldToCameraMatrix;
        Matrix4x4 currentViewProjectionInvMatrix = currentViewProjectionMatrix.inverse;

        mat.SetMatrix("_CurrentViewProjectionInvMatrix", currentViewProjectionInvMatrix);
        preViewProjectionMatrix = currentViewProjectionMatrix;

        Graphics.Blit(src, dest, mat);
    }
}

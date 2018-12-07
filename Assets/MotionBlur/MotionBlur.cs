using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlur : MonoBehaviour
{
    [Range(0.0f, 0.9f)]
    public float m_blurAmount = 0.1f;

    private RenderTexture preMotionTexture = null;

    private Material mat;

    public bool clear = false;

    void Start ()
    {
        mat = new Material(Shader.Find("MotionBlur"));
        mat.hideFlags = HideFlags.DontSave;
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (preMotionTexture == null || 
            preMotionTexture.width != src.width || 
            preMotionTexture.height != src.height)
        {
            DestroyImmediate(preMotionTexture);
            preMotionTexture = new RenderTexture(src.width, src.height, 0);
            Graphics.Blit(src, preMotionTexture);
        }
        if (clear == true)
        {
            Graphics.Blit(src, preMotionTexture);
            clear = false;
        }
        preMotionTexture.MarkRestoreExpected();

        mat.SetFloat("_BlurAmount", m_blurAmount);

        Graphics.Blit(src, preMotionTexture, mat);
        Graphics.Blit(preMotionTexture, dest);
    }
    void OnDisable()
    {
        DestroyImmediate(this.preMotionTexture);
        this.preMotionTexture = null;
    }
}
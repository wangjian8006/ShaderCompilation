using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RobertsEdgeDetection : MonoBehaviour
{
    public float edgeWidth = 0.0f;

    public Color edgeColor = Color.black;

    public Color backgroundColor = Color.white;

    public float sampleDistance = 1.0f;

    public float sensitivityDepth = 1.0f;

    public float sensitivityNormals = 1.0f;

    private Material material;

    void Start()
    {
        material = new Material(Shader.Find("RobertsEdgeDetection"));
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        material.SetFloat("_EdgeWidth", edgeWidth);
        material.SetColor("_EdgeColor", edgeColor);
        material.SetColor("_BackgroundColor", backgroundColor);
        material.SetFloat("_SampleDistance", sampleDistance);
        material.SetVector("_Sensitivity", new Vector2(sensitivityNormals, sensitivityDepth));

        Graphics.Blit(src, dest, material);
    }
}

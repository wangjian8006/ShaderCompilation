using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SolbelEdgeDetection : MonoBehaviour
{
    public float edgeWidth = 0.0f;

    public Color edgeColor = Color.black;

    public Color backgroundColor = Color.white;

    private Material material;

	void Start ()
    {
        material = new Material(Shader.Find("SolbeEdgeDetection"));
	}
	
	void OnRenderImage (RenderTexture src, RenderTexture dest)
    {
        material.SetFloat("_EdgeWidth", edgeWidth);
        material.SetColor("_EdgeColor", edgeColor);
        material.SetColor("_BackgroundColor", backgroundColor);

        Graphics.Blit(src, dest, material);
	}
}

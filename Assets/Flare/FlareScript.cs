using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlareScript : MonoBehaviour
{
    public Transform Sun;

    public float flareSize = 1.0f;

    public float flareDistance = 0;

    public float flareIntensity;

    public Texture2D gradientTex;

    public Texture2D flareTex;

    private Camera camera;

    private Material material;

	void Start ()
    {
        camera = Camera.main;
        material = new Material(Shader.Find("FlareShader"));
	}
	
	void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (Sun == null)
        {
            Graphics.Blit(src, dest);
        }
        else
        {
            Vector2 pos = camera.WorldToScreenPoint(Sun.transform.position);

            if (pos.x <= 0 || pos.x >= (camera.pixelWidth + Sun.transform.localScale.x) || pos.y <= 0 || pos.y >= (camera.pixelHeight + Sun.transform.localScale.z))
            {
                Graphics.Blit(src, dest);
            }
            else
            {
                Vector2 t = (pos - new Vector2(camera.pixelWidth * 0.5f, 0)).normalized;
                t.x = t.x * flareDistance / camera.pixelWidth;
                t.y = t.y * flareDistance / camera.pixelHeight;

                pos.x = pos.x / camera.pixelWidth;
                pos.y = pos.y / camera.pixelHeight;

                material.SetVector("_SunPosition", pos);
                material.SetVector("_SunDirection", t);
                material.SetFloat("_FlareSize", flareSize);
                material.SetTexture("_FlareTex", flareTex);
                material.SetTexture("_GradientTex", gradientTex);
                material.SetFloat("_FlareIntensity", flareIntensity);
                Graphics.Blit(src, dest, material);
            }
        }
	}
}
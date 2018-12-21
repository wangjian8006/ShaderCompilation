using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Water : MonoBehaviour
{
    [Range(1, 100)]
    public int WaterWidth = 1;

    [Range(1, 100)]
    public int WaterHeight = 1;

    public Vector4 Waves = Vector4.one;     //频率

    public Vector4 Amplitude = Vector4.one;     //振幅

    public Vector4 Phase = Vector4.one;      //相位

    public Vector4 Sharps = Vector4.one;     //锐度

    public Vector4 DirectionX = Vector4.one;     //方向AB

    public Vector4 DirectionY = Vector4.one;     //方向CD

    public Vector4 BumpDirection = Vector4.one;

    public Vector4 BumpTiling = Vector4.one;

    public Color MainColor;

    public Texture2D BumpTex;

    public float Smoothness;

    public Cubemap Reflection;

    public float Fresnel;

    protected MeshFilter m_meshFilter;

    protected MeshRenderer m_meshRender;

    protected Material WaterMaterial;

    protected int GetIndexByPos(int x, int y)
    {
        return y * WaterHeight + x;
    }

    protected Mesh GenarateMesh()
    {
        Vector2 vMidPosition = new Vector2((float)WaterWidth / 2.0f, (float)WaterHeight / 2.0f);

        Mesh mesh = new Mesh();
        List<Vector3> vertexs = new List<Vector3>();
        List<Vector2> uvs = new List<Vector2>();
        List<Vector3> normals = new List<Vector3>();
        for (int i = 0; i < WaterHeight; ++i)
        {
            for (int j = 0; j < WaterWidth; ++j)
            {
                vertexs.Add(new Vector3(i + 1 - vMidPosition.y, 0, j + 1 - vMidPosition.x));
                normals.Add(new Vector3(0, 1, 0));
                uvs.Add(new Vector2((float)j / (float)(WaterWidth - 1), (float)i / (float)(WaterHeight - 1)));
            }
        }

        List<int> triangles = new List<int>();

        for (int i = 1; i < WaterHeight; ++i)
        {
            for (int j = 1; j < WaterWidth; ++j)
            {
                triangles.Add(GetIndexByPos(j - 1, i - 1));
                triangles.Add(GetIndexByPos(j, i - 1));
                triangles.Add(GetIndexByPos(j, i));

                triangles.Add(GetIndexByPos(j - 1, i - 1));
                triangles.Add(GetIndexByPos(j, i));
                triangles.Add(GetIndexByPos(j - 1, i));
            }
        }

        mesh.vertices = vertexs.ToArray();
        mesh.uv = uvs.ToArray();
        mesh.normals = normals.ToArray();
        mesh.triangles = triangles.ToArray();
        return mesh;
    }

    void Start()
    {
        m_meshFilter = this.gameObject.GetComponent<MeshFilter>();
        if (m_meshFilter == null) m_meshFilter = this.gameObject.AddComponent<MeshFilter>();

        m_meshRender = this.gameObject.GetComponent<MeshRenderer>();
        if (m_meshRender == null) m_meshRender = this.gameObject.AddComponent<MeshRenderer>();

        WaterMaterial = new Material(Shader.Find("Water_GeometricWaves"));

        m_meshRender.material = WaterMaterial;
        m_meshFilter.sharedMesh = GenarateMesh();
    }

    Vector4 GetVector4ByVector2(Vector2 v1, Vector2 v2)
    {
        return new Vector4(v1.x, v1.y, v2.x, v2.y);
    }

    void Update()
    {
        if (WaterMaterial == null) return;

        WaterMaterial.SetVector("_WavesLengths", Waves);
        WaterMaterial.SetVector("_Amplitudes", Amplitude);
        WaterMaterial.SetVector("_Phases", Phase);
        WaterMaterial.SetColor("_Color", MainColor);
        WaterMaterial.SetTexture("_BumpTex", BumpTex);
        WaterMaterial.SetVector("_Sharps", Sharps);
        WaterMaterial.SetFloat("_Smoothness", Smoothness);
        WaterMaterial.SetVector("_BumpDirection", BumpDirection);
        WaterMaterial.SetVector("_BumpTiling", BumpTiling);
        WaterMaterial.SetTexture("_Reflection", Reflection);
        WaterMaterial.SetFloat("_Fresnel", Fresnel);
        

        WaterMaterial.SetVector("_DirectionX", DirectionX);
        WaterMaterial.SetVector("_DirectionY", DirectionY);
    }
}

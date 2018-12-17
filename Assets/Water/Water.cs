using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Water : MonoBehaviour
{
    [Range(1, 100)]
    public int WaterWidth = 1;

    [Range(1, 100)]
    public int WaterHeight = 1;

    public bool useSinWave = false;

    public float[] Waves;     //频率

    public float[] Amplitude;     //振幅

    public float[] Phase;      //相位

    public Vector2[] Direction;     //方向

    public float[] Sharps;     //方向

    public Color MainColor;

    public Texture2D MainTex;

    public Texture2D BumpTex;

    public float Smoothness;

    public float Fresnel;

    public Cubemap ReflectCube;

    public float SpeedTime;

    public Vector2 TextureSpeed = Vector2.one;

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

        if (useSinWave == false) WaterMaterial = new Material(Shader.Find("Water_GeometricWaves"));
        else WaterMaterial = new Material(Shader.Find("Water_SinWaves"));

        m_meshRender.material = WaterMaterial;
        m_meshFilter.sharedMesh = GenarateMesh();
    }

    void Update()
    {
        if (WaterMaterial == null) return;

        if (Mathf.Abs(SpeedTime) < 0.0001f) WaterMaterial.SetFloat("_SpeedTime", Time.time);
        else WaterMaterial.SetFloat("_SpeedTime", SpeedTime);

        WaterMaterial.SetFloatArray("_WavesLengths", Waves);
        WaterMaterial.SetFloatArray("_Amplitudes", Amplitude);
        WaterMaterial.SetFloatArray("_Phases", Phase);
        WaterMaterial.SetColor("_Color", MainColor);
        WaterMaterial.SetTexture("_MainTex", MainTex);
        WaterMaterial.SetTexture("_BumpTex", BumpTex);
        WaterMaterial.SetFloat("_Smoothness", Smoothness);
        WaterMaterial.SetFloat("_Fresnel", Fresnel);
        WaterMaterial.SetTexture("_Reflect", ReflectCube);
        WaterMaterial.SetFloatArray("_Sharps", Sharps);
        WaterMaterial.SetVector("_TextureSpeed", TextureSpeed);

        List<float> _DirectionXs = new List<float>();
        List<float> _DirectionYs = new List<float>();
        for (int i = 0; i < Direction.Length; ++i)
        {
            Vector2 tmp = Direction[i].normalized;
            _DirectionXs.Add(tmp.x);
            _DirectionYs.Add(tmp.y);
        }

        WaterMaterial.SetFloatArray("_DirectionXs", _DirectionXs);
        WaterMaterial.SetFloatArray("_DirectionYs", _DirectionYs);
    }
}

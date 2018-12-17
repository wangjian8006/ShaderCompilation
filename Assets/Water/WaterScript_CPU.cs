using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaterScript_CPU : MonoBehaviour
{
    [Range(1, 100)]
    public int WaterWidth = 1;

    [Range(1, 100)]
    public int WaterHeight = 1;

    public Material WaterMaterial;

    public float Waves = 1;     //频率

    public float Amplitude = 1;     //振幅

    public Vector2 Direction = Vector2.one;     //方向

    public float Phase = 0.0f;      //相位

    protected MeshFilter m_meshFilter;

    protected MeshRenderer m_meshRender;

    protected Vector2 vMidPosition;

    protected int GetIndexByPos(int x, int y)
    {
        return y * WaterHeight + x;
    }

    protected Mesh GenarateMesh()
    {
        vMidPosition = new Vector2((float)WaterWidth / 2.0f, (float)WaterHeight / 2.0f);

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

	void Start ()
    {
        m_meshFilter = this.gameObject.GetComponent<MeshFilter>();
        if (m_meshFilter == null) m_meshFilter = this.gameObject.AddComponent<MeshFilter>();

        m_meshRender = this.gameObject.GetComponent<MeshRenderer>();
        if (m_meshRender == null) m_meshRender = this.gameObject.AddComponent<MeshRenderer>();

        m_meshRender.material = WaterMaterial;
        m_meshFilter.sharedMesh = GenarateMesh();
	}
	
	void Update ()
    {
        List<Vector3> vertexs = new List<Vector3>();
        List<Vector3> normals = new List<Vector3>();
        List<Vector4> tangents = new List<Vector4>();

        Vector2 dir = Direction.normalized;

		for (int i = 0; i < WaterHeight; ++i)
        {
            for (int j = 0; j < WaterWidth; ++j)
            {
                Vector2 pos = new Vector2(i + 1 - vMidPosition.y, j + 1 - vMidPosition.x);

                float value = Vector2.Dot(dir, pos) * Waves + Time.time * Phase;
                float y = Amplitude * Mathf.Sin(value);
                vertexs.Add(new Vector3(pos.x, y, pos.y));

                float normalValue = Waves * Amplitude * Mathf.Cos(value);

                Vector3 binormal = new Vector3(1, 0, dir.x * normalValue);
                Vector3 tangent = new Vector3(0, 1, dir.y * normalValue);
                Vector3 normal = new Vector3(-dir.x * normalValue, -dir.y * normalValue, 1);
                normals.Add(normal);
                tangents.Add(new Vector4(tangent.x, tangent.y, tangent.z, 1));
            }
        }
        m_meshFilter.sharedMesh.vertices = vertexs.ToArray();
        m_meshFilter.sharedMesh.normals = normals.ToArray();
        m_meshFilter.sharedMesh.tangents = tangents.ToArray();

        WaterMaterial.SetVector("_Speed", this.Direction);
	}
}

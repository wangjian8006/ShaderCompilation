using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ElasticEffect : MonoBehaviour {

	private int posID;
    
    private int normalID;
    
    private int stimeID;

    private MeshRenderer mesh;

    private void Start()
    {
        mesh = GetComponent<MeshRenderer>();
        posID = Shader.PropertyToID("_Position");
        normalID = Shader.PropertyToID("_Normal");
        stimeID = Shader.PropertyToID("_StartTime");
    }

    public void OnElastic(RaycastHit hit)
    {
        Vector4 v = transform.InverseTransformPoint(hit.point);     //转模型坐标
        mesh.material.SetVector(posID, v);

        v = transform.InverseTransformDirection(hit.normal.normalized);     //转模型坐标
        mesh.material.SetVector(normalID, v);

        mesh.material.SetFloat(stimeID, Time.time);
    }

    public void Update()
    {
        if (Input.GetMouseButtonDown(0) == true)
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);

            RaycastHit hit;
            Physics.Raycast(ray, out hit);
            if (hit.transform == this.transform)
            {
                OnElastic(hit);
            }
        }
    }
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ComputeShaderTest : MonoBehaviour {

    public ComputeShader shader;

    private ComputeBuffer preBuffer;

    private ComputeBuffer nextBuffer;

    private ComputeBuffer resultBuffer;


    public Vector3[] array1;

    public Vector3[] array2;

    public Vector3[] resultArr;

    public int length = 16;


    private int kernel;

	void Start () {
        array1 = new Vector3[length];
        array2 = new Vector3[length];
        resultArr = new Vector3[length];

        for (int i = 0; i < length; ++i)
        {
            array1[i] = Vector3.one;
            array2[i] = Vector3.one * 2;
        }

        InitBuffer();
        kernel = shader.FindKernel("CSMain");
        shader.SetBuffer(kernel, "preVertices", preBuffer);
        shader.SetBuffer(kernel, "nextVertices", nextBuffer);
        shader.SetBuffer(kernel, "Result", resultBuffer);
	}

    private void InitBuffer()
    {
        preBuffer = new ComputeBuffer(array1.Length, 12);
        preBuffer.SetData(array1);
        nextBuffer = new ComputeBuffer(array2.Length, 12);
        nextBuffer.SetData(array2);
        resultBuffer = new ComputeBuffer(resultArr.Length, 12);
    }
	
	void Update () {
		if (Input.GetKeyDown(KeyCode.A) == true)
        {
            shader.Dispatch(kernel, 2, 2, 1);
            resultBuffer.GetData(resultArr);

            for (int i = 0; i < resultArr.Length; ++i)
            {
                Debug.LogError(resultArr[i]);
            }

            resultBuffer.Release();
        }
	}
}

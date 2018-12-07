using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionCtrl : MonoBehaviour {

    float startTime;

    float speed = 0.05f;

    MotionBlur motionBlur;

	void Start () {
        startTime = Time.time;
        motionBlur = Camera.main.gameObject.GetComponent<MotionBlur>();
	}
	
	void Update () {
        float duration = Time.time - startTime;
        if (duration > 1.0f)
        {
            motionBlur.clear = true;
            startTime = Time.time;
            speed = speed * -1;
        }

        Vector3 pos = gameObject.transform.position;
        pos.y += speed * duration;
        gameObject.transform.position = pos;
	}
}

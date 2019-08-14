using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FogTest : PostEffectBase {
	public Shader fogShader;
	private Material fogMat = null;

	public Material material {
		get {
			fogMat = CheckShaderAndCreateMaterial(fogShader, fogMat);
			return fogMat; 
		}
	}

	private Camera myCamera;
	public Camera _Camera {
		get {
			if (myCamera == null)
				myCamera = GetComponent<Camera>();
			return myCamera;
		}
	}

	private Transform myCameraTrans;
	public Transform _cameraTrans {
		get {
			if (myCameraTrans == null)
				myCameraTrans = _Camera.transform;
			return myCameraTrans;
		}
	}

	[Range(0.0f, 3.0f)]
	public float fogDensity = 1.0f;

	public Color fogColor = Color.white;

	public float fogStart = 0.0f;
	public float fogEnd = 2.0f;

	void OnEnable() {
		_Camera.depthTextureMode |= DepthTextureMode.Depth;
	}

	void Start() {
		// 最后换算的是模长为 0.5f
		Debug.Log(transform.forward * 0.5f);
	}

	void OnRenderImage(RenderTexture src, RenderTexture dest) {
		if (material == null) {
			Graphics.Blit(src, dest);
			return;
		}
		// frustum 锥形
		Matrix4x4 frustumCorners = Matrix4x4.identity;

		// 可视范围角度(Vertical)
		float fov = _Camera.fieldOfView;
		float near = _Camera.nearClipPlane;
		float aspect = _Camera.aspect;

		// Mathf.Deg2Rad 角度变弧度 PI / 2
		float halfHeight = near * Mathf.Tan(fov * 0.5f * Mathf.Deg2Rad);
		Vector3 toRight = _cameraTrans.right * halfHeight * aspect;
		Vector3 toTop = _cameraTrans.up * halfHeight;

		Vector3 topLeft = _cameraTrans.forward * near + toTop - toRight;
		// magnitude 模长
		float scale = topLeft.magnitude / near;
		//? 换算成是 scale 长度
		topLeft.Normalize();
		topLeft *= scale;


		Vector3 topRight = _cameraTrans.forward * near + toRight + toTop;
		topRight.Normalize();
		topRight *= scale;

		Vector3 bottomLeft = _cameraTrans.forward * near - toTop - toRight;
		bottomLeft.Normalize();
		bottomLeft *= scale;

		Vector3 bottomRight = _cameraTrans.forward * near + toRight - toTop;
		bottomRight.Normalize();
		bottomRight *= scale;

		frustumCorners.SetRow(0, bottomLeft);
		frustumCorners.SetRow(1, bottomRight);
		frustumCorners.SetRow(2, topRight);
		frustumCorners.SetRow(3, topLeft);

		material.SetMatrix("_FrustumCornersRay", frustumCorners);

		material.SetFloat("_FogDensity", fogDensity);
		material.SetColor("_FogColor", fogColor);
		material.SetFloat("_FogStart", fogStart);
		material.SetFloat("_FogEnd", fogEnd);

		Graphics.Blit(src, dest, material);
	}
}

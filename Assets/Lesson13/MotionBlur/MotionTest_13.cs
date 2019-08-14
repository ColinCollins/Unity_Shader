using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionTest_13 : PostEffectBase {
	public Shader motionBlurShader;

	private Material motionBlurMat = null;

	public Material material {
		get {
			motionBlurMat = CheckShaderAndCreateMaterial(motionBlurShader, motionBlurMat);
			return motionBlurMat;
		}
	}

	private Camera myCamera;
	public Camera _camera {
		get {
			if (myCamera == null) {
				myCamera = GetComponent<Camera>();
			}
			return myCamera;
		}
	}

	[Range(0.0f, 1.0f)]
	public float blurSize = 0.5f;

	private Matrix4x4 preViewProjMat;

	void OnEnable() {
		_camera.depthTextureMode |= DepthTextureMode.Depth;
		// 投影矩阵和视角矩阵 projectMatrix and viewMatrix
		preViewProjMat = _camera.projectionMatrix * _camera.worldToCameraMatrix;
	}

	void OnRenderImage(RenderTexture src, RenderTexture dest) {

		if (material == null) {
			Graphics.Blit(src, dest);
			return;
		}

			material.SetFloat("_BlurSize", blurSize);

			material.SetMatrix("_PreViewProjMat", preViewProjMat);

			Matrix4x4 curViewProjMat = _camera.projectionMatrix * _camera.worldToCameraMatrix;
			Matrix4x4 curViewProjMatInverseMat = curViewProjMat.inverse;

			material.SetMatrix("_CurViewProjInverseMat", curViewProjMatInverseMat);
			preViewProjMat = curViewProjMat;

			Graphics.Blit(src, dest, material);
	}
}

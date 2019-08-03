using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BrightingAndSaturationAndContrast : PostEffectBase {
	public Shader briSatConShader;

	private Material briSatConMat;
	public Material material {
		get {
			briSatConMat = CheckShaderAndCreateMaterial(briSatConShader, briSatConMat);
			return briSatConMat;
		}
	}

	[Range(0.0f, 3.0f)]
	public float brightness = 1.0f;

	[Range(0.0f, 3.0f)]
	public float saturation = 1.0f;

	[Range(0.0f, 3.0f)]
	public float contrast = 1.0f;

	// Unity 自带函数，会自动检测对象，添加 Camera 并见渲染 texture 传入 src 最终的 renderTexture 为 dest
	void OnRenderImage(RenderTexture src, RenderTexture dest) {
		if (!material) {
			Graphics.Blit(src, dest);
			return;
		}

		material.SetFloat("_Brightness", brightness);
		material.SetFloat("_Saturation", saturation);
		material.SetFloat("_Contrast", contrast);

		// srources texture, dest texture, material
		Graphics.Blit(src, dest, material);
	}
}

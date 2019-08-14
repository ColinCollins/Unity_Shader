using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BloomTest : PostEffectBase {
	public Shader bloomShader;
	private Material bloomMat = null;

	public Material material {
		get {
			bloomMat = CheckShaderAndCreateMaterial(bloomShader, bloomMat);
			return bloomMat;
		}
	}
	// 迭代次数
	[Range(0, 4)]
	public int iterations = 3;
	// 像素间隔
	[Range(0.2f, 3.0f)]
	public float blurSpread = 0.5f;
	// 降采样，取局部
	[Range(1, 8)]
	public int downSample = 2;
	// 高亮临界值
	[Range(0.0f, 4.0f)]
	public float luminanceThreshold = 0.6f;

	private void OnRenderImage(RenderTexture src, RenderTexture dest) {
		if (material == null) {
			Graphics.Blit(src, dest);
			return;
		}

		material.SetFloat("_LuminanceThreshold", luminanceThreshold);

		int rtW = src.width / downSample;
		int rtH = src.height / downSample;
		// 获取对应像素存储空间
		RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
		// 曲线采样，减少损耗
		buffer0.filterMode = FilterMode.Bilinear;
		// 写入缓存，Copies source texture into destination render texture with a shader.
		Graphics.Blit(src, buffer0, material, 0);

		for (int i = 0; i < iterations; i++) {
			material.SetFloat("_BlurSize", 1.0f + i * blurSpread);

			RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

			Graphics.Blit(buffer0, buffer1, material, 1);

			RenderTexture.ReleaseTemporary(buffer0);

			buffer0 = buffer1;
			buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);

			Graphics.Blit(buffer0, buffer1, material, 2);

			RenderTexture.ReleaseTemporary(buffer0);

			buffer0 = buffer1;
		}

		material.SetTexture("_Bloom", buffer0);
		Graphics.Blit(src, dest, material, 3);

		RenderTexture.ReleaseTemporary(buffer0);
	}
}

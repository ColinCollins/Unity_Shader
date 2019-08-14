using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GaussTest : PostEffectBase {
	public Shader gaussianBlurShader = null;
	private Material gaussianBlurMat = null;

	public Material material {
		get {
			gaussianBlurMat = CheckShaderAndCreateMaterial(gaussianBlurShader, gaussianBlurMat);
			return gaussianBlurMat;
		}
	}

	// Blur iterations - larger number means more blur
	[Range(0, 4)]
	public int iterations = 3;
	// Blur spread for each iteration - latger value means more blur
	[Range(0.2f, 3.0f)]
	public float blurSpread = 0.6f;
	// 采样空间
	[Range(1, 8)]
	public int downSample = 2;

	void OnRenderImage(RenderTexture src, RenderTexture dest) {
		if (material != null) {
			int rtW = src.width / downSample;
			int rtH = src.height / downSample;
			RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
			// 线性滤波
			buffer0.filterMode = FilterMode.Bilinear;
			Graphics.Blit(src, buffer0);

			for (int i = 0; i < iterations; i++) {
				material.SetFloat("_BlurSize", 1.0f + i * blurSpread);

				RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
				// Render the vertical pass 
				Graphics.Blit(buffer0, buffer1, material, 0);
				RenderTexture.ReleaseTemporary(buffer0);

				buffer0 = buffer1;
				buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
				
				// Render the horizontal pass
				Graphics.Blit(buffer0, buffer1, material, 1);

				RenderTexture.ReleaseTemporary(buffer0);
				buffer0 = buffer1;
			}

			Graphics.Blit(buffer0, dest);
			RenderTexture.ReleaseTemporary(buffer0);
		}
		else {
			Graphics.Blit(src, dest);
		}
	}
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlur : PostEffectBase {
	public Shader MotionBlurShader = null;

	private Material motionBlurMat = null;
	public Material material {
		get {
			motionBlurMat = CheckShaderAndCreateMaterial(MotionBlurShader, motionBlurMat);
			return motionBlurMat;
		}
	}

	[Range(0.0f, 0.9f)]
	public float blurAmount = 0.5f;

	private RenderTexture accumulationTexture;

	void OnDisable() {
		DestroyImmediate(accumulationTexture);
	}

	// 每帧都会调用
	void OnRenderImage (RenderTexture src, RenderTexture dest) {
		Debug.Log(1);
		if (material == null) {
			Graphics.Blit(src, dest);
			return;
		}
		// 加速度纹理
		if (accumulationTexture == null || 
			accumulationTexture.width != src.width || 
			accumulationTexture.height != src.height) {

			DestroyImmediate(accumulationTexture);
			accumulationTexture = new RenderTexture(src.width, src.height, 0);
			accumulationTexture.hideFlags = HideFlags.HideAndDontSave;

			Graphics.Blit(src, accumulationTexture);
		}
		// 存储上一帧的纹理
		accumulationTexture.MarkRestoreExpected();
		material.SetFloat("_BlurAmount", 1.0f - blurAmount);

		Graphics.Blit(src, accumulationTexture, material);
		Graphics.Blit(accumulationTexture, dest);
	}


//	Pass {
			
//			CGPROGRAM
//#pragma vertex vert 
//#pragma fragment fragTest

//			half4 fragTest(v2f i) : SV_Target {
//				half4 color = tex2D(_MainTex, i.uv);
//				return half4(lerp(half3(1.0, 0.0, 0.0), color.rgb, color.a), 1.0);
//			}

//ENDCG
//		}
}

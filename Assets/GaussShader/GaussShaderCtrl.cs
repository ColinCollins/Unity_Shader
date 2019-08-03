using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteInEditMode]

[AddComponentMenu("Learning Unity Shader/RapidBlurEffect")]
public class GaussShaderCtrl : MonoBehaviour {

	#region  Variables

	private string shaderName = "Learning Unity Shader/test";

	public Shader CurShader;
	private Material CurMaterial;
	// static 可以隐藏在 Inspector
	public static int ChangeValue;
	public static float ChangeValue2;
	public static int ChangeValue3;

	//降采样次数
	[Range(0, 6), Tooltip("[降采样次数]向下采样的次数。此值越大,则采样间隔越大,需要处理的像素点越少,运行速度越快。")]
	public int DownSampleNum = 2;
	//模糊扩散度
	[Range(0.0f, 20.0f), Tooltip("[模糊扩散度]进行高斯模糊时，相邻像素点的间隔。此值越大相邻像素间隔越远，图像越模糊。但过大的值会导致失真。")]
	public float BlurSpreadSize = 3.0f;
	//迭代次数
	[Range(0, 8), Tooltip("[迭代次数]此值越大,则模糊操作的迭代次数越多，模糊效果越好，但消耗越大。")]
	public int BlurIterations = 3;
	#endregion

	#region MaterialGetAndSet 
	Material material {
		get {
			if (CurMaterial == null) {
				CurMaterial = new Material(CurShader);
				CurMaterial.hideFlags = HideFlags.HideAndDontSave;
			}
			return CurMaterial;
		}
	}
	#endregion

	#region 

	void Start() {
		ChangeValue = DownSampleNum;
		ChangeValue2 = BlurSpreadSize;
		ChangeValue3 = BlurIterations;

		CurShader = Shader.Find(shaderName);

		if (!SystemInfo.supportsImageEffects) {
			enabled = false;
			return;
		}
	}

	// 此函数在完成所有渲染图片后被调用，用来渲染图片后期效果

	void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture) {
		if (CurShader == null) {
			Graphics.Blit(sourceTexture, destTexture);
			return;
		};

		float widthMod = 1.0f / (1.0f * (1 << DownSampleNum));
		material.SetFloat("_DownSamlpeValue", BlurSpreadSize * widthMod);

		sourceTexture.filterMode = FilterMode.Bilinear;
		//通过右移，准备长、宽参数值
		int renderWidth = sourceTexture.width >> DownSampleNum;
		int renderHeight = sourceTexture.height >> DownSampleNum;
		// 创建 renderBuffer, 用于存储新的像素数据
		RenderTexture renderBuffer = RenderTexture.GetTemporary(renderWidth, renderHeight, 0, sourceTexture.format);
		// copy sourceTexture 中的 pixel 数据到 renderBuffer, 并仅绘制指定的 pass0 纹理数据
		// Blit 拷贝数据到指定的 shader 通道中
		sourceTexture.filterMode = FilterMode.Bilinear;
		Graphics.Blit(sourceTexture, renderBuffer, material, 0);

		//【2】根据BlurIterations（迭代次数），来进行指定次数的迭代操作
		for (int i = 0; i < BlurIterations; i++) {
			//【2.1】Shader参数赋值
			//迭代偏移量参数
			float iterationOffs = (i * 1.0f);
			//Shader的降采样参数赋值
			material.SetFloat("_DownSampleValue", BlurSpreadSize * widthMod + iterationOffs);

			// 【2.2】处理Shader的通道1，垂直方向模糊处理 || Pass1,for vertical blur
			// 定义一个临时渲染的缓存tempBuffer
			RenderTexture tempBuffer = RenderTexture.GetTemporary(renderWidth, renderHeight, 0, sourceTexture.format);
			// 拷贝renderBuffer中的渲染数据到tempBuffer,并仅绘制指定的pass1的纹理数据
			Graphics.Blit(renderBuffer, tempBuffer, material, 1);
			//  清空renderBuffer
			RenderTexture.ReleaseTemporary(renderBuffer);
			// 将tempBuffer赋给renderBuffer，此时renderBuffer里面pass0和pass1的数据已经准备好
			renderBuffer = tempBuffer;

			// 【2.3】处理Shader的通道2，竖直方向模糊处理 || Pass2,for horizontal blur
			// 获取临时渲染纹理
			tempBuffer = RenderTexture.GetTemporary(renderWidth, renderHeight, 0, sourceTexture.format);
			// 拷贝renderBuffer中的渲染数据到tempBuffer,并仅绘制指定的pass2的纹理数据
			Graphics.Blit(renderBuffer, tempBuffer, CurMaterial, 2);

			//【2.4】得到pass0、pass1和pass2的数据都已经准备好的renderBuffer
			// 再次清空renderBuffer
			RenderTexture.ReleaseTemporary(renderBuffer);
			// 再次将tempBuffer赋给renderBuffer，此时renderBuffer里面pass0、pass1和pass2的数据都已经准备好
			renderBuffer = tempBuffer;
		}

		//拷贝最终的renderBuffer到目标纹理，并绘制所有通道的纹理到屏幕
		Graphics.Blit(renderBuffer, destTexture);
		//清空renderBuffer
		RenderTexture.ReleaseTemporary(renderBuffer);
	}

	// 编辑器当前脚本发生改变之后
	void OnValidate() {
		ChangeValue = DownSampleNum;
		ChangeValue2 = BlurSpreadSize;
		ChangeValue3 = BlurIterations;
	}
//	void Update() {
//		if (Application.isPlaying) {
//			ChangeValue = DownSampleNum;
//			ChangeValue2 = BlurSpreadSize;
//			ChangeValue3 = BlurIterations;
//		}

//#if UNITY_EDITOR
//		if (!Application.isPlaying) {
//			CurShader = Shader.Find(shaderName);
//		}
//#endif
//	}

	private void OnDisable() {
		if (CurMaterial) DestroyImmediate(CurMaterial);
	}

	#endregion
}

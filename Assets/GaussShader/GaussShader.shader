Shader "Custom/GaussTest/GaussShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
	SubShader
	{
		ZWrite Off
		Blend Off

		//---------------------------------------【通道0 || Pass 0】------------------------------------
		//通道0：降采样通道 ||Pass 0: Down Sample Pass
		Pass {
			ZTest Off
			Cull Off
 
			CGPROGRAM
		
			//指定此通道的顶点着色器为vert_DownSmpl
			#pragma vertex vert_DownSmpl
			//指定此通道的像素着色器为frag_DownSmpl
			#pragma fragment frag_DownSmpl

			//【4】降采样输出结构体 || Vertex Input Struct
			struct VertexOutput_DownSmpl {
				//像素位置坐标
				float4 pos : SV_POSITION;
				//一级纹理坐标（右上）
				half2 uv20 : TEXCOORD0;
				//二级纹理坐标（左下）
				half2 uv21 : TEXCOORD1;
				//三级纹理坐标（右下）
				half2 uv22 : TEXCOORD2;
				//四级纹理坐标（左上）
				half2 uv23 : TEXCOORD3;
			};
			
			VertexOutput_DownSmpl vert_DownSmpl(VertexInput v) {
				VertexOutput_DownSmpl o;

				o.pos = UnityObjectToClipPos(v.vertex);
				//对图像的降采样：取像素上下左右周围的点，分别存于四级纹理坐标中
				o.uv20 = v.uv + _MainTex_TexelSize.xy * half2(0.5h, 0.5h);
				o.uv21 = v.uv + _MainTex_TexelSize.xy * half2(-0.5h, -0.5h);
				o.uv22 = v.uv + _MainTex_TexelSize.xy * half2(0.5h, -0.5h);
				o.uv23 = v.uv + _MainTex_TexelSize.xy * half2(-0.5h, 0.5h);

				return o;
			}

			fixed4 frag_DownSmpl (VertexOutput_DownSmpl i) : SV_Target {
				fixed4 color = fixed4(0, 0, 0, 0);
				color += tex2D(_MainTex, i.uv20);
				color += tex2D(_MainTex, i.uv21);
				color += tex2D(_MainTex, i.uv22);
				color += tex2D(_MainTex, i.uv23);
				return color / 4;
			}

			ENDCG
 
		}
 
		//---------------------------------------【通道1 || Pass 1】------------------------------------
		//通道1：垂直方向模糊处理通道 ||Pass 1: Vertical Pass
		Pass
		{
			ZTest Always
			Cull Off
 
			CGPROGRAM
 
			//指定此通道的顶点着色器为vert_BlurVertical
			#pragma vertex vert_BlurVertical
			//指定此通道的像素着色器为frag_Blur
			#pragma fragment frag_Blur
			
				//【10】顶点着色函数 || Vertex Shader Function
			VertexOutput_Blur vert_BlurVertical(VertexInput v)
			{
				//【10.1】实例化一个输出结构
				VertexOutput_Blur o;
 
				//【10.2】填充输出结构
				//将三维空间中的坐标投影到二维窗口  
				o.pos = UnityObjectToClipPos(v.vertex);
				//纹理坐标
				o.uv = half4(v.uv.xy, 1, 1);
				//计算Y方向的偏移量
				o.offset = _MainTex_TexelSize.xy * half2(0.0, 1.0) * _DownSampleValue;
 
				//【10.3】返回最终的输出结果
				return o;
			}
			ENDCG
		}
 
		//---------------------------------------【通道2 || Pass 2】------------------------------------
		//通道2：水平方向模糊处理通道 ||Pass 2: Horizontal Pass
		Pass
		{
			ZTest Always
			Cull Off
 
			CGPROGRAM
 
			//指定此通道的顶点着色器为vert_BlurHorizontal
			#pragma vertex vert_BlurHorizontal
			//指定此通道的像素着色器为frag_Blur
			#pragma fragment frag_Blur
			
				//【9】顶点着色函数 || Vertex Shader Function
			VertexOutput_Blur vert_BlurHorizontal(VertexInput v)
			{
				//【9.1】实例化一个输出结构
				VertexOutput_Blur o;
 
				//【9.2】填充输出结构
				//将三维空间中的坐标投影到二维窗口  
				o.pos = UnityObjectToClipPos(v.vertex);
				//纹理坐标
				o.uv = half4(v.uv.xy, 1, 1);
				//计算X方向的偏移量
				o.offset = _MainTex_TexelSize.xy * half2(1.0, 0.0) * _DownSampleValue;
 
				//【9.3】返回最终的输出结果
				return o;
			}

			ENDCG
		}
	}
 
	CGINCLUDE

	//【1】头文件包含 || include
	#include "UnityCG.cginc"
 
	//【2】变量声明 || Variable Declaration
	sampler2D _MainTex;
	//UnityCG.cginc中内置的变量，纹理中的单像素尺寸|| it is the size of a texel of the texture
	uniform half4 _MainTex_TexelSize;
	//C#脚本控制的变量 || Parameter
	uniform half _DownSampleValue;
	struct VertexInput {
		float4 vertex : POSITION;
		half2 uv: TEXCOORD0;
	};



	// 高斯模糊权重矩阵，跟标准正态分布的区间比例有关
	//【5】准备高斯模糊权重矩阵参数7x4的矩阵 ||  Gauss Weight
	static const half4 GaussWeight[7] =
	{
		half4(0.0205, 0.0205, 0.0205, 0),
		half4(0.0855, 0.0855, 0.0855, 0),
		half4(0.232, 0.232, 0.232, 0),
		half4(0.324, 0.324, 0.324, 1),
		half4(0.232, 0.232, 0.232, 0),
		half4(0.0855, 0.0855, 0.0855, 0),
		half4(0.0205, 0.0205, 0.0205, 0)
	};



	struct VertexOutput_Blur {
		float4 pos : SV_POSITION;
		half4 uv : TEXCOORD0;
		half2 offset : TEXCOORD1;
	};

	half4 frag_Blur (VertexOutput_Blur i) : SV_Target {
		half2 uv = i.uv.xy;

		half2 offsetWidth = i.offset;
		// 从中心点偏移 3 个间隔从最左或者最上开始加权累加
		half2 uvWithOffset = uv - offsetWidth * 3.0;
		
		half4 color = 0;

		for (int j = 0; j < 7; j++) {
			half4 texCol = tex2D(_MainTex, uvWithOffset);
			color += texCol * GaussWeight[j];
			uvWithOffset += offsetWidth;
		}

		return color;
	}

	ENDCG

	FallBack Off
}

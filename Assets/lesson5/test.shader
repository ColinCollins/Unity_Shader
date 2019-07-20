// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 5/test"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }

	SubShader {
		Pass{
		CGPROGRAM
		
		#pragma vertex vert
		#pragma fragment frag

		// 结构体
		struct a2v {
			// 基本数据都包含在被渲染模型的 Mesh Render 内
			// POSITION 通知 Unity 使 Model Vertex Index 填充 vertex 变量
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			// TEXCOORD0 通知 Unity， 用 Model 第一套 texture 填充 texcoord_IndexCount
			float4 texcoord : TEXCOORD0;
		};
		// 定义结构体用于 vertex shader 与 fragment shader 通信
		struct v2f {
			// SV_POSITION 定义包含顶点再 Clip Space 内的位置信息
			float4 pos : SV_POSITION;
			fixed3 color: COLOR0;
		};
		// SV_POSITION 是 CG / HLSL  中的语义，不可省略，告诉系统，用户需要的输入值以及用户的输出值，用于修饰输出对象的
		v2f vert (a2v v) {
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);
			return o;
		}


		fixed4 frag(v2f i) : SV_Target {
			return fixed4(i.color, 1.0);
		}

		ENDCG
		}
	}

    FallBack "Diffuse"
}

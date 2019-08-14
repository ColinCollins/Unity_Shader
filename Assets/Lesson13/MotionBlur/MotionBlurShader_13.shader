Shader "Unity Shaders Book/Chapter 13/MotionBlurShader_13"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_BlurSize ("Blur Size", Float) = 1.0

    }
    SubShader {
		CGINCLUDE
			
		#include "UnityCG.cginc"

		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		sampler2D _CameraDepthTexture;
		float4x4 _CurViewProjInverseMat;
		float4x4 _PreViewProjMat;
		half _BlurSize;

		struct v2f {
			float4 pos : SV_POSITION;
			half2 uv : TEXCOORD0;
			half2 uv_depth : TEXCOORD1;
		};

		v2f vert (appdata_img v) {
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = v.texcoord;
			o.uv_depth = v.texcoord;

			// 倒转
			#if UNITY_UV_STARTS_AT_TOP 
				if (_MainTex_TexelSize.y < 0) {
					o.uv_depth.y = 1 - o.uv_depth.y;
				}
			#endif

			return o;
		}

		fixed4 frag(v2f i) : SV_Target {
			// d 深度纹理
			float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
			// 深度纹理 range 转换为 -1，1
			float4 H = float4 (i.uv.x * 2 - 1, i.uv.y * 2  - 1, d * 2 - 1, 1);
			// 将当前帧的空间坐标转换为世界坐标
			float4 D = mul(_CurViewProjInverseMat, H);

			float4 curWorldPos = D / D.w;

			float4 curPos = H;
			// 计算 NDC ,卧槽。。。我知道了，这他妈是计算摄像机的，和物体移动关系不大，就是移动摄像机才会出现效果，因为 worldPos 是没有变化的，而变化的是 viewMatrix
			float4 prePos = mul(_PreViewProjMat, curWorldPos);
			// 获得 齐次坐标
			prePos /= prePos.w;
			// 帧速度
			float2 velocity = (curPos.xy - prePos.xy) / 2.0f;

			float2 uv = i.uv;
			float4 c = tex2D(_MainTex, uv);

			uv += velocity * _BlurSize;
			for (int j = 1; j < 3; j++, uv += velocity * _BlurSize) {
				float4 currentColor = tex2D(_MainTex, uv);
				c += currentColor;
			}
			// 算 期望 
			c /= 3;

			return fixed4 (c.rgb, 1.0);
		}

		ENDCG

		Pass {
			ZTest Always
			Cull Off
			ZWrite Off
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			ENDCG
		}
    }

	FallBack Off
}

Shader "Unity Shaders Book/Chapter 12/MotionShader"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
		_BlurAmount ("Blur Amount", Float) = 1.0
    }
    SubShader
    {
		CGINCLUDE

		#include "UnityCG.cginc"
		sampler2D _MainTex;
		fixed _BlurAmount;

		struct v2f {
			float4 pos : SV_POSITION;
			half2 uv : TEXCOORD0;
		};

		v2f vert (appdata_img v) {
			v2f o;

			o.pos = UnityObjectToClipPos(v.vertex);

			o.uv = v.texcoord;

			return o;
		}

		fixed4 fragRGB (v2f i) : SV_Target {
			return fixed4(tex2D(_MainTex, i.uv).rgb, _BlurAmount);
		}

		half4 fragA(v2f i) : SV_Target {
			return tex2D(_MainTex, i.uv);
		}

		ENDCG

		ZTest Always
		Cull Off
		ZWrite Off
		// 这里抛弃了 alpha 通道
		Pass {
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGB

			CGPROGRAM
			#pragma vertex vert 
			#pragma fragment fragRGB
			ENDCG

        }
		// 这里重新将 alpha 通道赋值回去， One 表示原图内的 alpha 占比为 1
        Pass {
			Blend One Zero 
			ColorMask A

			CGPROGRAM
			#pragma vertex vert 
			#pragma fragment fragA
			ENDCG
        }
    }

	FallBack Off
}

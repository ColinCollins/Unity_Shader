Shader "Unity Shaders Book/Chapter 9/AlphaShadowRenderShader"
{
	Properties{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color Tint", Color) = (1, 1, 1, 1)
		_Cutoff("Alpha Cutoff", Range(0, 1)) = 0.5
	}

		SubShader{
			Tags { "Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
			LOD 100

			Pass {
				Tags{"LightMode" = "ForwardBase"}

				Cull Off

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

			// make fog work
			#pragma multi_compile_fwdbase

			#include "AutoLight.cginc"
			#include "Lighting.cginc"
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			fixed _Cutoff;

			struct a2v
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal: NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
				SHADOW_COORDS(3)
			};

			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				TRANSFER_SHADOW(o)
				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 lightDir = UnityWorldSpaceLightDir(i.pos);

				fixed4 texColor = tex2D(_MainTex, i.uv);
				// 清除对应渲染
				clip(texColor.a - _Cutoff);

				fixed3 albedo = texColor.rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, lightDir));
				// 光线衰减和阴影纹理深度贴图
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

				return fixed4((ambient + diffuse) * atten, 1.0);
			}
			ENDCG
			}
		}

			// Fallback "VertexLit"
			Fallback "Transparent/Cutout/VertexLit"
}

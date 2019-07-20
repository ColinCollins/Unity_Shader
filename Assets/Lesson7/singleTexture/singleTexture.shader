Shader "Unity Shaders Book/Chapter 7/Single Texture"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_Gloss ("Shininess", Range(8.0, 256)) = 20
    }
    SubShader {
	Pass {
			Tags { "LightMode"="ForwardBase" }

			CGPROGRAM

			#include "Lighting.cginc"

			#pragma vertex vert
			#pragma fragment frag

			fixed4 _Diffuse;
			fixed4 _Specular;
			sampler2D _MainTex;
			// 纹理属性，用于表示 scale 和 translation, _MainTex_ST.xy => Scale, _MainTex_ST.zw => translation
			float4 _MainTex_ST;
			float _Gloss;

			struct a2v {
				float4 vertex: POSITION;
				float3 normal: NORMAL;
				float3 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 position : SV_POSITION;
				float3 worldNormal: TEXCOORD0;
				float3 worldPos: TEXCOORD1;
				float2 uv : TEXCOORD2;
			};

			v2f vert(a2v v) {
				v2f o;
				// MVP 转换
				o.position = UnityObjectToClipPos(v.vertex);
				// 转换法线
				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				return o;
			}

			fixed4 frag(v2f f) : SV_Target {
				
				fixed3 albedo = tex2D(_MainTex, f.uv).rgb * _Diffuse.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				
				fixed3 worldNormal = normalize(f.worldNormal);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);

				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLightDir));
				
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz);
				// reflect 
				fixed3 halfDir = normalize(worldLightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);

				return fixed4(ambient + diffuse + specular, 1.0);
			}

			ENDCG
		}
    }
    FallBack "Diffuse"
}

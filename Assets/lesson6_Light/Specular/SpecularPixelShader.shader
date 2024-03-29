﻿// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 6/Specular Pixel-Level"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		// shiness
		_Gloss("Gloss", Range(8.0, 256)) = 32
    }
    SubShader
    {
		Pass {
			Tags { "RenderType"="Opaque" }
			LOD 200

			CGPROGRAM

			#pragma vertex vert 
			#pragma fragment frag

			#include "Lighting.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			// attributes
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};

			v2f vert (a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.worldNormal = mul(v.normal, (float3x3)unity_WorldToObject);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				// 获取环境光
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				// 获取对应片源 normal 法线
				fixed3 worldNormal = normalize(i.worldNormal);
				// 获取光照方向
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				// Compute diffuse term
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
				// 折射方向
				fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));

				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(dot(reflectDir, viewDir), 0.2), _Gloss);

				return  fixed4(ambient + diffuse + specular, 1.0);
			}

			ENDCG
		}
    }
    FallBack "Specular"
}

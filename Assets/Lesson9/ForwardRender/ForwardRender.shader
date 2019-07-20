Shader "Unity Shaders Book/Chapter 9/ForwardRender"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20

    }
    SubShader
    {
		Tags {"RenderType" = "Opaque"}

		Pass {
			// Pass for ambient light & first pixel light 
			Tags {"LightMode"="ForwardBase"}
			CGPROGRAM
			// 光照衰减等变量能够正确的赋值
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

            struct a2v {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
            };

			struct v2f {
				float3 worldPos : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float2 uv : TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			v2f vert (a2v v) {
				v2f o;
				// add projection
				o.vertex = UnityObjectToClipPos(v.vertex);

				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				// world vertex position
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				// o.uv = v.uv.xy * _MainTex_ST.xy + _MainTex.ST.zw
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				return o;
			}

			fixed4 frag (v2f i) : SV_TARGET {
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.vertex));
				fixed3 albedo = tex2D(_MainTex, i.uv).rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * albedo * max(0, dot(worldNormal, lightDir));

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(viewDir + lightDir);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
				fixed atten = 1.0;

				return fixed4(ambient + (diffuse + specular) * atten, 1.0);
			}

			ENDCG
		}

		// Addition Pass
        Pass {
			Tags {"LightMode"="ForwardAdd"}

			Blend SrcAlpha One

			CGPROGRAM
			// 保证在 addition pass 中能够访问到正确的光照变量
			#pragma multi_compile_fwdadd
			
			#pragma vertex vert 
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv : TEXCOORD2;
			};

			sampler2D _MainTex;
            float4 _MainTex_ST;
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			v2f vert (a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos (v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				fixed3 worldNormal = normalize(i.worldNormal);
				// 平行光
				#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				#else
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
				#endif 

				fixed3 albedo = tex2D(_MainTex, i.uv).rgb;

				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * albedo * saturate(dot(worldNormal, worldLightDir));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(worldLightDir + viewDir);

				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);

				#ifdef USING_DIRECTIONAL_LIGHT
					fixed atten = 1.0;
				#else 
					#if defined(POINT)
						float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
						fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
					#elif defined(SPOT)
						float4 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1));
						fixed atten = (lightCoord.z > 0) * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
					#else 
						fixed atten = 1.0;
					#endif
				#endif

				return fixed4((diffuse + specular) * atten, 1.0);
			}
            ENDCG
        }
    }
	FallBack "Specular"
}
	
Shader "Unity Shaders Book/Common/CommonAlpha"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_BumpMap ("Nomral Texture", 2D) = "white" {}
		_BumpScale ("Normal Depth", float) = 1
		_Specular ("Specular Color", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(8, 256)) = 20
		_AlphaScale("Alpha Scale", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "IgnoreProjector"="True" "Queue"="Transparent"}

        Pass {
			Tags {"LightMode"="ForwardBase"}

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			fixed4 _Color;
			fixed4 _Specular;
			fixed _AlphaScale;
			fixed _BumpScale;
			float _Gloss;

            struct a2v {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
            };

            struct v2f {
                float4 uv : TEXCOORD0;
				float4 tToW0 : TECOORD1;
				float4 tToW1 : TECOORD2;
				float4 tToW2 : TECOORD3;
                float4 pos : SV_POSITION;

				SHADOW_COORDS(4)
            };


            v2f vert (a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
				o.uv.xy = v.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.uv.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				TANGENT_SPACE_ROTATION;

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

				o.tToW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.tToW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.tToW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                float3 worldPos = float3(i.tToW0.w, i.tToW1.w, i.tToW2.w);
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

				fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
				bump.xy *= _BumpScale;
				bump = normalize(half3(dot(i.tToW0.xyz, bump), dot(i.tToW1.xyz, bump), dot(i.tToW2.xyz, bump)));

				fixed4 texColor = tex2D(_MainTex, i.uv.xy);

				fixed3 albedo = texColor.rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(bump, lightDir));

				fixed3 halfDir = normalize(lightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(bump, halfDir)), _Gloss);

				UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

				return fixed4 (ambient + (diffuse + specular) * atten, _AlphaScale * texColor.a);
            }
            ENDCG
        }

		Pass {
			Tags {"LightMode"="ForwardAdd"}

			Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fwdadd

            #include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			fixed4 _Color;
			fixed4 _Specular;
			fixed _AlphaScale;
			fixed _BumpScale;
			float _Gloss;

            struct a2v {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
            };

            struct v2f {
                float4 uv : TEXCOORD0;
				float4 tToW0 : TECOORD1;
				float4 tToW1 : TECOORD2;
				float4 tToW2 : TECOORD3;
                float4 pos : SV_POSITION;

				SHADOW_COORDS(4)
            };


            v2f vert (a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
				o.uv.xy = v.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.uv.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

				o.tToW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.tToW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.tToW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                float3 worldPos = float3(i.tToW0.w, i.tToW1.w, i.tToW2.w);
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

				fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
				bump.xy *= _BumpScale;
				bump = normalize(half3(dot(i.tToW0.xyz, bump), dot(i.tToW1.xyz, bump), dot(i.tToW2.xyz, bump)));

				fixed4 texColor = tex2D(_MainTex, i.uv.xy);

				fixed3 albedo = texColor.rgb * _Color.rgb;

				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(bump, lightDir));

				fixed3 halfDir = normalize(lightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(bump, halfDir)), _Gloss);

				UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

				return fixed4 ((diffuse + specular) * atten, _AlphaScale * texColor.a);
            }
            ENDCG
        }
    }

	FallBack "Transparent/VertexLit"
}

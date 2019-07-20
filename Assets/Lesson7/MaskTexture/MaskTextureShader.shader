Shader "Unity Shaders Book/Chapter 7/MaskTextureShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_BumpMap ("NormalMap", 2D) = "bump" {}
		_BumpScale ("Bump Scale", Float) = 1.0
		_SpecularMask ("Specular Mask", 2D) = "white" {}
		_SpecularScale ("Specular Scale", Float) = 1.0
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Pass
        {	
			// 只针对主光源进行漫反射
			Tags { "LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
			#include "Lighting.cginc"

			sampler2D _BumpMap;
			fixed _BumpScale;
			sampler2D _MainTex;
			// 可以省
            float4 _MainTex_ST;
			sampler2D _SpecularMask;
			float _SpecularScale;

			fixed4 _Specular;
			fixed4 _Color;
			float _Gloss;

            struct a2v {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
				float4 tangent : TANGENT;
				float3 normal : NORMAL;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

            v2f vert (a2v v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = v.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;

			   TANGENT_SPACE_ROTATION;
			   o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
			   o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
				
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);
				// 0,1 -> -1, 1
				fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv));
				tangentNormal.xy *= _BumpScale;
				// 通过其他两个分量求取第三个分量在 3D space 下，因为 _BumpMap 为 2D
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));

				fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
				// 高亮贴图
				fixed specularMask = tex2D(_SpecularMask, i.uv).r * _SpecularScale;
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss) * specularMask;
				
				return fixed4 (ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
	Fallback "Specular"
}

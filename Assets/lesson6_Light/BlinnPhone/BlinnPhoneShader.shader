Shader "Unity Shaders Book/Chapter 6/BlinnPhoneShader"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
		_Specular("Specular", Color) = (1, 1, 1, 1)
		_Gloss ("Shininess", Range(8, 256)) = 32
    }
    SubShader
    {
		Pass{
			Tags { "RenderType"="Opaque" }
			LOD 200

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
		
			#include "Lighting.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 position : SV_POSITION;
				// 因为 normal 是法线贴图
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};

			v2f vert (a2v v) {
				v2f o;
				o.position = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				return o;
			}

			fixed4 frag(v2f i) : SV_Target {
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));

				// camera 到顶点 xyz
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				// 这个是因为平行四边形
				fixed3 halfDir = normalize(worldLightDir + viewDir);
				// 计算高光
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);

				return fixed4(ambient + diffuse + specular, 1.0);
			}

			ENDCG
		}
    }
    FallBack "Diffuse"
}

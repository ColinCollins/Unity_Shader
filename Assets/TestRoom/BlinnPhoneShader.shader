Shader "Custom/BlinnPhoneShader"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
		_ShadowColor("Shadow Color", Color) = (1, 1, 1, 1)
		_LightDir ("Light Direction", Vector) = (0, 0, 0)
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
			fixed3 _LightDir;
			fixed4 _ShadowColor;

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
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 diffuse = _Diffuse.rgb;
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed shadowWeight = max(dot(worldNormal, lightDir), 0.0);

				if (shadowWeight < 0.7) {
					return fixed4(diffuse * _ShadowColor.rgb , 1.0);
				}

				return fixed4(diffuse, 1.0);
			}

			ENDCG
		}
    }
    FallBack "Diffuse"
}

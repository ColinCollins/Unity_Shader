// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unity Shaders Book/Chapter6_DiffuseLight/DiffuseVertexLevel"
{
	Properties{
		_Diffuse ("Diffuse", Color) = (1, 1, 1, 1)
	}

    SubShader
    {
        Pass{
			Tags{
				// 定义 lightMode 获取正确的 light 变量
				"LightMode" = "ForwardBase"
			}
			CGPROGRAM
				
				#pragma vertex vert
				#pragma fragment frag

				#include "Lighting.cginc"

				fixed4 _Diffuse;
				// attribute param
				struct a2v {
					float4 vertex : POSITION;
					float3 normal : NORMAL;
				};
				// vertex fragment
				struct v2f {
					float4 pos : SV_POSITION;
					fixed3 color : COLOR;
				};
				
				v2f vert (a2v v) {
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);

					// get ambient term 获取环境光
					fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

					// Transform the normal fram object space to world space -> 将法线方向相对于对象坐标系转换为顶点坐标系
					fixed3 worldNormal = normalize(mul(v.normal, (float3x3) unity_WorldToObject));
					fixed3 worldLightPos = normalize(_WorldSpaceLightPos0.xyz);
					// saturate 是 CG 提供的函数，为 max（dot(normal, dir)）
					fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightPos));

					o.color = ambient + diffuse;
					return o;
				}

				fixed4 frag(v2f i) : SV_Target {
					return fixed4 (i.color, 1.0);
				}
			ENDCG
		}
    }
    FallBack "Diffuse"
}

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shader Lab/Chapter 19/CartoonOutLineShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Outline ("Out line", range(0, 0.1)) = 0.02
		_Outline2 ("Out line2", range(0, 1)) = 0.2
		_Factor ("Factor", range(0, 1)) = 0.5
		_Factor2 ("Factor2", range(0, 1)) = 0.5
		_Color ("Out Line Color", Color) = (1, 1, 1, 1)
    }

    SubShader {
		Tags {"RenderType"="Transparent" "IgnoreProjector"="True" "Queue"="Transparent"}
		CGINCLUDE
			 #include "UnityCG.cginc"
			 #include "Lighting.cginc"

			 float _Outline;
			 float _Outline2;
			 float _Factor;
			 float _Factor2;
			 fixed4 _Color;
			 sampler2D _MainTex;
			 float4 _MainTex_ST;

		ENDCG
		pass{
			Tags{"LightMode"="ForwardBase"}
			Cull Back
			ZWrite On

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct v2f {
				float4 pos:SV_POSITION;
			};

			v2f vert (appdata_full v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				float3 dir = normalize(v.vertex.xyz);
				float3 dir2 = v.normal;
				dir = lerp(dir, dir2, _Factor);
				dir = mul ((float3x3)UNITY_MATRIX_IT_MV, dir);
				float2 offset = TransformViewToProjection(dir.xy);
				offset = normalize(offset);
				o.pos.xy += offset * o.pos.z *_Outline;

				return o;
			}
			float4 frag(v2f i):COLOR {
				return float4(1, 1, 1, 1);
			}
			ENDCG
		}
	

		Pass {
			Tags{"LightMode"="ForwardBase"}
			Cull Front
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			struct a2v {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TECOORD0;
				float dir : TEXCOORD0;
			};

			v2f vert (a2v v) {

				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				float3 dir = normalize(v.vertex.xyz);
				float3 dir2 = v.normal;

				dir = lerp(dir, dir2, _Factor2);
				dir = mul((float3x3)UNITY_MATRIX_IT_MV, dir);
				float2 offset = TransformViewToProjection(dir.xy);
				offset = normalize(offset);
				
				o.pos.xy += offset * o.pos.z * _Outline2;

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				return o;
			}

			fixed4 frag (v2f i) : COLOR {
				fixed4 texColor = tex2D(_MainTex, i.uv);
				_Color.a = texColor.a;
				return _Color;
			}

			ENDCG
		}

		Pass {
			Tags {"LightMode"="ForwardBase"}
			Blend DstColor Zero

			CGPROGRAM
			#pragma multi_compile_fwdbase
			#pragma vertex vert
			#pragma fragment frag

			struct v2f {
				float4 pos : SV_POSITION;
				float3 lightDir : TEXCOORD0;
				float3 viewDir : TEXCOORD1;
				float3 normal : NORMAL;
			};

			v2f vert (appdata_full v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				float3 dir = normalize(v.vertex.xyz);
				float3 dir2 = v.normal;
				dir = lerp (dir, dir2, _Factor);
				// model and view matrix inverseOf Transpose
				dir = mul((float3x3)UNITY_MATRIX_IT_MV, dir);

				float2 offset = TransformViewToProjection(dir.xy);
				offset = normalize(offset);
				o.pos.xy += offset * o.pos.z * _Outline;

				o.normal = normalize(v.normal);
				o.lightDir = normalize(ObjSpaceLightDir(v.vertex));
				o.viewDir = normalize(ObjSpaceViewDir(v.vertex));

				return o;
			}

			fixed4 frag (v2f i) : COLOR {
				fixed3 normal = i.normal;
				fixed3 viewDir = i.viewDir;
				fixed3 lightDir = i.lightDir;

				float diff = saturate(dot(normal, lightDir));
				diff = (diff + 1) / 2;
				diff = smoothstep(0, 1, diff);
				
				return diff;
			}
			ENDCG
		}
    }

	// FallBack "Diffuse"
}

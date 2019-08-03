// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unity Shaders Book/Chapter 11/Billboarding"
{
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		// 用于控制法线固定指向上
		_VerticalBillboarding ("Vertical Restraints", Range(0, 1)) = 1
    }
    SubShader {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" "IgnoreProjector"="True" "DisableBatching"="True"}

        Pass
        {
			Tags {"LightMode"="ForwardBase"}
			ZWrite Off
			Cull Off
			Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"

            struct a2v {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			fixed4 _Color;
			float _VerticalBillboarding;

            v2f vert (a2v v)
            {
                v2f o;
				// anchor center
				float3 center = float3(0, 0, 0);
				float3 viewer = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));

				float3 normalDir = viewer - center;
				normalDir.y = normalDir.y * _VerticalBillboarding;
				normalDir = normalize(normalDir);
				// normalDir == viewDir，这时候跟空间已经没什么关系了，就是对着 Camera 
				float3 upDir = abs(normalDir.y) > 0.999 ? float3 (0, 0, 1) : float3 (0, 1, 0);
				float3 rightDir = normalize(cross(upDir, normalDir));
				// 因为 upDir 与 noramliDir 应该不一定是垂直的
				upDir = normalize(cross(normalDir, rightDir));

				float3 centerOffs = v.vertex.xyz - center;
				float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;

                o.pos = UnityObjectToClipPos(float4(localPos, 1));
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
				col.rgb *= _Color.rgb;
                return col;
            }
            ENDCG
        }
    }

	Fallback "Transparent/VertexLit"
}

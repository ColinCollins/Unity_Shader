Shader "Unity Shaders Book/Chapter 8/BlendTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_AlphaScale ("Alpha Scale", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType"="Transparent" }
        Pass {
			Tags{"LightMode" = "ForwardBase"}
			ZWrite Off



			// Normal
			// Blend SrcAlpha OneMinusSrcAlpha

			// Soft Additive
			// Blend OneMinusDstColor One

			// Multiply
			// Blend DstColor Zero

			// 2x Multiply 
			// Blend DstColor SrcColor

			// Darken
			// BlendOp Min
			// Blend One One 无效设置

			// Lighten
			// BlendOp Max
			// Blend One One // 无效设置

			// Screen 
			Blend OneMinusDstColor One
			// Or
			// Blend One OneMinusSrcColor

			// Linear Dodge
			// Blend One One
			
			CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

			#include "Lighting.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			fixed4 _Color;
			fixed _AlphaScale;


            v2f vert (a2v v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target  {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                return fixed4 (col.rgb * _Color.rgb, col.a * _AlphaScale);
            }
            ENDCG
		}
    }
	FallBack "Transparent/VertexLit"
}

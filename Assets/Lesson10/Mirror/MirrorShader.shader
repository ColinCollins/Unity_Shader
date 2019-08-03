Shader "Unity Shaders Book/Chapter 10/MirrorShader"
{
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}
		
        Pass {

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct a2v
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcoord;
				// 翻转左右
				o.uv.x  = 1 - o.uv.x;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                // sample the texture
                return tex2D(_MainTex, i.uv);
            }
            ENDCG
        }
    }

	FallBack Off
}

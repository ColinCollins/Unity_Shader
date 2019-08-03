Shader "Unity Shaders Book/Chapter 11/ScrollBgShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_DetailTex("2nd Layer (RGB)", 2D) = "white" {}
		_ScrollX ("Base layer Scroll Speed", Float) = 1.0
		_ScrollX2 ("2nd Layer Scroll Speed", Float) = 1.0
		_Luminance ("Layer Luminance", Float) = 1  // 亮度
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
 
            #include "UnityCG.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			sampler2D _DetailTex;
			float4 _DetailTex_ST;
			float _ScrollX;
			float _ScrollX2;
			float _Luminance;

            v2f vert (a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
				// frac 返回标量或每个向量分量的小数部分
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex) + frac(float2(_ScrollX, 0.0) * _Time.y);
				o.uv.zw = TRANSFORM_TEX(v.uv, _DetailTex) + frac(float2(_ScrollX2, 0.0) * _Time.y);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 firstLayer = tex2D(_MainTex, i.uv.xy);
				fixed4 secondLayer = tex2D(_DetailTex, i.uv.zw);
				fixed4 col = lerp(firstLayer, secondLayer, secondLayer.a);
				col.rgb *= _Luminance;
                return col;
            }
            ENDCG
        }
    }
}

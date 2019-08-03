Shader "Unity Shaders Book/Chapter 11/ImageSequenceAnimation"
{
    Properties
    {
        _MainTex ("Image Sequence", 2D) = "white" {}
		_Color ("Colot Tint", Color) = (1, 1, 1, 1)
		_HorizontalAmount ("Horizontal Amount", Float) = 4
		_VerticalAmount ("Vertical Amount", Float) = 4
		_Speed ("Speed", Range(1, 100)) = 30
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }	

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

            struct a2v {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			fixed4 _Color;
			float _HorizontalAmount;
			float _VerticalAmount;
			float _Speed;

            v2f vert (a2v v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
				// 向下取整
				float time = floor(_Time.y * _Speed);
				// 水平数量，行
				float row = floor(time / _HorizontalAmount);
				// 垂直数量
				float column = time - row * _VerticalAmount;
				// opengl? 在 Unity uv.y 向下， 默认 uv 为 1, 1
				half2 uv = i.uv + half2(column, -row);

				uv.x /= _HorizontalAmount;
				uv.y /= _VerticalAmount;

				fixed4 c = tex2D(_MainTex, uv);
				c.rgb *= _Color;

                return c;
            }
            ENDCG
        }
    }

	FallBack "Transparent/VertexLit"
}

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unity Shaders Book/Chapter 11/WaterShader" {
		// Distortion 扭曲变形
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		// 波动振幅
		_Magnitude ("Distortion Magnitude", Float) = 1
		// 波动频率
		_Frequency ("Distortion Frequency", Float) = 1	
		// 波浪长度倒数
		_InvWaveLength ("Distortion Inverse Wave Length", Float) = 10
		_Speed ("Speed", Float) = 0.5
    }
    SubShader {
	// 关闭 批处理 ，开启批处理的话会导致模型空间丢失导致模型顶点动画无法运行
        Tags { "RenderType"="Transparent" "IgnoreProjector"="True" "Queue"="Transparent" "DisableBatching"="True"}

        Pass {
			Tags {"LightMode"="ForwardBase"}

			ZWrite Off
			Cull Off
			Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct a2v {
                float4 vertex : POSITION;
                float2 tex : TEXCOORD0;
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			fixed4 _Color;
			float _Magnitude;
			float _Frequency;
			float _InvWaveLength;
			float _Speed;

            v2f vert (a2v v) {
                v2f o;
				float4 offset;
				offset.yzw = float3(0.0, 0.0, 0.0);
				// ???
				offset.x = sin(_Frequency * _Time.y + v.vertex.x * _InvWaveLength + v.vertex.y * _InvWaveLength + v.vertex.z * _InvWaveLength) * _Magnitude;

                o.pos = UnityObjectToClipPos(v.vertex + offset);
				o.uv = TRANSFORM_TEX(v.tex, _MainTex);
				o.uv += float2(0.0, _Time.y * _Speed);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                fixed4 c = tex2D(_MainTex, i.uv);
				c.rgb *= _Color.rgb;

                return c;
            }
            ENDCG
        }
    }

	Fallback "Transparent/VertexLit"
}

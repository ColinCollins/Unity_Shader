Shader "Unity Shaders Book/Chapter 8/AlphaBlend"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Color("Main Tint", Color) = (1, 1, 1, 1)
		_AlphaScale ("Alpha Scale", Range(0, 1)) = 1
    }
    SubShader
    {
		// Transparent 透明的
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
        LOD 100

        Pass
        {
			Tags {"LightMode"="ForwardBase"}
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

			#include "Lighting.cginc"
			// attribute to vertex
            struct a2v {
                float4 vertex : POSITION;
				float3 normal: NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			fixed4 _Color;
			fixed _AlphaScale;

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed4 texColor = tex2D(_MainTex, i.uv);
				fixed3 albedo = texColor.rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * max(dot(worldNormal, worldLightDir), 0.0);

				return fixed4(ambient + diffuse, texColor.a * _AlphaScale);
            }
            ENDCG
        }
    }
}

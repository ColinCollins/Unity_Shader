Shader "Unity Shaders Book/Chapter 8/AlphaBlendZWriteMat"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Color ("Main Tint", Color) = (1, 1, 1, 1)
		_AlphaScale("Alpha Scale", Range(0, 1)) = 1
    }
    SubShader
    {
       Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}

		Pass {
			ZWrite On
			ColorMask 0
		}

        Pass
        {
			Tags { "LightMode"="ForwardBase" }
			
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag	

			#include "Lighting.cginc"

            struct a2v {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
				float3 normal : NORMAL;
            };

            struct v2f {	
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
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
				
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				
				return o;
            }

            fixed4 frag (v2f i) : SV_Target {
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				
				fixed4 texColor = tex2D(_MainTex, i.uv);
				
				fixed3 albedo = texColor.rgb * _Color.rgb;
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
				
				return fixed4(ambient + diffuse, texColor.a * _AlphaScale);
            }
            ENDCG
        }
    }
	FallBack "Transparent/VertexLit"
}

Shader "Unity Shaders Book/Chapter 8/AlphaTestBothSide"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Color ("Main Tint", Color) = (1, 1, 1, 1)
		_AlphaScale ("Alpha Scale", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }

        Pass
        {
			Tags {"LightMode"="ForwardBase"}
			// ZWrite Off 开启深度检测
			Blend SrcAlpha OneMinusSrcAlpha

			Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

			#include "Lighting.cginc"
            #include "UnityCG.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal: NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD2;
				float3 worldPos : TEXCOORD1;
				float3 worldNormal : TEXCOORD0;
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
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld, o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

				fixed3 albedo = col.rgb * _Color.rgb;

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, lightDir));
	
                return fixed4 (ambient + diffuse, col.a * _AlphaScale);
            }
            ENDCG
        }
    }
}

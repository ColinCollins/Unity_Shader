Shader "Unity Shaders Book/Chapter 7/NormalMapTangentSpace"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_BumpMap ("Normal Map", 2D) = "bump" {}
		_BumpScale ("Bump Scale", Float) = 1.0
		_Specular ("Specular", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
			Tags{"LihgtMode"="ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "UnityCG.cginc"
			#include "Lighting.cginc"

            struct a2v {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
				// 切线; w = direction
				float4 tangent : TANGENT;
				// TEXCOORD 实际上是一组插值寄存器，和 webgl 中的 texcoord 还不太一样
                float4 uv : TEXCOORD0;
            };

            struct v2f {
                float4 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			fixed4 _Color;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;

			fixed4 _Specular;
			float _Gloss;

            v2f vert (a2v v) {
                v2f o;
				// xy 是缩放， zw 是偏移
				// o.uv = TRANSFORM_TEX(v.uv, _MainTex); 获取的是 uv 值 2 维对象
				o.uv.xy = v.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.uv.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

				// 副切线
				// float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz) * v.tangent.w);
				// 转置矩阵 为啥这个是转置矩阵。。。https://note.youdao.com/web/#/file/230BD5309A76483E8A207668B38E4019/note/WEB8f0077c4334ca05bf813e4f59e5ce03a/
				// 相当于这么说，通过矩阵定义空间之后的转置表示，又因为转置矩阵在这种特殊情况下可以作为逆矩阵用于倒推模型空间，因此这么做。
				// float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);

				// 切线空间计算法线旋转 ？？
				TANGENT_SPACE_ROTATION; // -> create rotation

				o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
				o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
				// 切线坐标下的光照以及视角方向
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);

				// 法线贴图的方向问题
				fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);

				fixed3 tangentNormal;
				// pixel （0, 1）=> (-1, 1) 表示法线空间
				// tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
				// tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
				// range to 0 - 1
				tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));

				fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);

				return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
	Fallback "Specular"
}

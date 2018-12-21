Shader "Glass_Refract"
{
	Properties
	{
		_Color ("Color", Color) = (1, 1, 1, 1)
		_MainTex ("Texture", 2D) = "white" {}

		_Smoothness("Smoothness", Float) = 0.5

		_BumpTex("Normal",2D) = "bump"{}
		
		_RefractAmount("_RefractAmount", Range(0, 1)) = 0.5	//折射率
		_RefractRatio("_RefractRatio",  Range(-1, 1)) = 0.5	//折射方向
		_Refract("Refract", Cube) = ""{}
	}
	SubShader
	{
		Tags {
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
		}

		Pass
		{
			Zwrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
			};

			struct v2f
			{
				float4 pos			: SV_POSITION;
				float2 uv			: TEXCOORD0;
				fixed2 uvNormal 	: TEXCOORD1;
				fixed3 normalDir 	: TEXCOORD2;
				fixed3 tangentDir 	: TEXCOORD3;
				fixed3 bitangentDir : TEXCOORD4;
				fixed3 viewDir		: TEXCOORD5;
				fixed3 worldRefr	: TEXCOORD6;
			};

			fixed4 _Color;
			sampler2D _MainTex;uniform float4 _MainTex_ST;
			sampler2D _BumpTex;uniform float4 _BumpTex_ST;

			float _RefractAmount;
			float _RefractRatio;
			samplerCUBE _Refract;

			float _Smoothness;
			fixed3 _LightColor0;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.normalDir = UnityObjectToWorldNormal(v.normal);
				o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
				o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);

				//视线角度
				o.viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uvNormal = TRANSFORM_TEX(v.uv, _BumpTex);

				//根据折射率计算折射方向
				//假使三种色彩折射度一样
				o.worldRefr = refract(-normalize(o.viewDir), normalize(o.normalDir), _RefractRatio);
				return o;
			}

			fixed3 calculateNormal(v2f i)
			{
				i.normalDir = normalize(i.normalDir);
				fixed3 normalTangent = UnpackNormal(tex2D(_BumpTex, i.uvNormal));		//切线空间法线纹理
				fixed3 normalWorld = (i.tangentDir * normalTangent.x + i.bitangentDir * normalTangent.y + i.normalDir * normalTangent.z);
				return normalize(normalWorld);
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv) * _Color;

				float3 N = calculateNormal(i);
				float3 V = normalize(i.viewDir);
				float3 L = normalize(_WorldSpaceLightPos0.xyz);
				float3 H = normalize(_WorldSpaceLightPos0.xyz + i.viewDir);

				//specular
				float spec = max(0, dot(N, H));
				spec = pow(spec, _Smoothness);
				spec *= col.a;

				//refraction
				fixed3 diffuse = _LightColor0.rgb * col.rgb * saturate(dot(N,V));
				fixed3 refraction = texCUBE(_Refract, i.worldRefr).rgb;

				col.rgb = lerp(diffuse, refraction, _RefractAmount);
				col.rgb += _LightColor0.rgb * spec;

				col.a = max(spec, col.a);

				return col;
			}
			ENDCG
		}
	}
}

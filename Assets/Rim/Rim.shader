Shader "Rim"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BumpTex ("Texture", 2D) = "white" {}
		_RimColor ("Rim Color", Color) = (0,1,1,1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex		: POSITION;
				fixed3 normal 		: NORMAL;
				fixed4 tangent 		: TANGENT;
				float2 texcoord0	: TEXCOORD0;
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
			};

			sampler2D _MainTex;float4 _MainTex_ST;
			sampler2D _BumpTex;float4 _BumpTex_ST;
			fixed4 _RimColor;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.normalDir = UnityObjectToWorldNormal(v.normal);
				o.tangentDir = normalize( mul( unity_ObjectToWorld, float4( v.tangent.xyz, 0.0 ) ).xyz );
				o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);

				//视线角度
				o.viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);

				o.uv = TRANSFORM_TEX(v.texcoord0, _MainTex);
				o.uvNormal = TRANSFORM_TEX(v.texcoord0, _BumpTex);
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
				fixed4 col = tex2D(_MainTex, i.uv);

				//视线与法线的角度
				fixed NdotV = dot(calculateNormal(i), i.viewDir);

				//角度越大值越大，则发射越强（菲涅尔）
				float fresnel = max(0, _RimColor.a * 2.0 - NdotV);

				col.rgb += _RimColor.rgb * fresnel;
				return col;
			}
			ENDCG
		}
	}
}

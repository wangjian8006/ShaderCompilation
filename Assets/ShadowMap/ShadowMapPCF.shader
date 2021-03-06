﻿Shader "ShadowMapPCF"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "green" {}
		_MaskTex ("ShadowEdgeMask", 2D) = "white" {}
		_BaseBias("BaseBias", Float) = 0
		_MaxBias("MaxBias", Float) = 0.005
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv: TEXCOORD0;
                float4 worldPos : TEXCOORD1;
				float3 normalDir : TEXCOORD2;
			};
			
			sampler2D _MainTex;float4 _MainTex_ST;
			sampler2D _MaskTex;float4 _MaskTex_ST;
			float4x4 _ShadowMapLightProjectView;
			sampler2D _ShadowMapDepthTex;
			float _BaseBias;
			float _MaxBias;
			float _ShadowMapDepthTexWidth;
			float _ShadowMapDepthTexHeight;

			v2f vert (appdata v)
			{
				v2f o;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				o.vertex = UnityObjectToClipPos(v.vertex);

				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldPos = mul(UNITY_MATRIX_M, v.vertex);

				o.normalDir = UnityObjectToWorldNormal(v.normal);
				return o;
			}

			float GetShadowBias2(float NL, float maxBias, float baseBias)
			{
				float sin_val = sqrt(1 - NL * NL);		// sin(acos(L·N))
				float tan_val = sin_val / NL;			// tan(acos(L·N))

				float bias = baseBias + clamp(tan_val, 0, maxBias);

				return bias;
			}

			fixed4 frag (v2f v) : SV_Target
			{
				fixed4 ndcpos = mul(_ShadowMapLightProjectView, v.worldPos);
				ndcpos.xyz = ndcpos.xyz / ndcpos.w;
				float3 uvpos = ndcpos * 0.5 + 0.5;

                fixed4 col = tex2D(_MainTex, v.uv);

				//灯光空间位置当前渲染的深度
				float depth = ndcpos.z;

				float3 N = normalize(v.normalDir);
				float3 L = normalize(_WorldSpaceLightPos0.xyz);
				float NL = saturate(dot(L, N));

				float bias = GetShadowBias2(NL, _MaxBias, _BaseBias);
				float shadowScale = 0;
				float2 texelSize = float2(1.0 / _ShadowMapDepthTexWidth, 1.0 / _ShadowMapDepthTexHeight);

				for (int x = -1; x <= 1; x++) {
					for (int y = -1; y <= 1; y++) {
						float2 samplePos = uvpos.xy + float2(x, y) * texelSize;//采样坐标
						fixed4 depthRGBA = tex2D(_ShadowMapDepthTex, samplePos);
						fixed d = DecodeFloatRGBA(depthRGBA);
						shadowScale += depth + bias < d ? 1.0 : 0.0;
					}
				}

				shadowScale = 1 - shadowScale / 9.0;
				shadowScale = max(shadowScale, tex2D(_MaskTex, uvpos.xy).r);
                return col * shadowScale;
			}
			ENDCG
		}
	}
}

Shader "RobertsEdgeDetection"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;
			sampler2D _CameraDepthNormalsTexture;
			float _EdgeWidth;
			float4 _EdgeColor;
			float4 _BackgroundColor;
			float _SampleDistance;
			float2 _Sensitivity;
			float4 _MainTex_TexelSize;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv[5] : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				half2 uv = v.uv;
				o.uv[0] = uv;

				o.uv[1] = uv + _MainTex_TexelSize.xy * half2(1, 1) * _SampleDistance;
				o.uv[2] = uv + _MainTex_TexelSize.xy * half2(-1, -1) * _SampleDistance;
				o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1, 1) * _SampleDistance;
				o.uv[4] = uv + _MainTex_TexelSize.xy * half2(1, -1) * _SampleDistance;

				return o;
			}

			half CheckSame(half4 center, half4 sample)
			{
				half2 centerNormal = center.xy;
				float centerDepth = DecodeFloatRG(center.zw);
				half2 sampleNormal = sample.xy;
				float sampleDepth = DecodeFloatRG(sample.zw);

				half2 diffNormal = abs(centerNormal - sampleNormal) * _Sensitivity.x;
				int isSameNormal = (diffNormal.x + diffNormal.y) < 0.1;

				float diffDepth = abs(centerDepth - sampleDepth) * _Sensitivity.y;
				int isSameDepth = diffDepth < 0.1 * centerDepth;

				return isSameNormal * isSameDepth ? 1.0 : 0.0;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				half4 sample1 = tex2D(_CameraDepthNormalsTexture, i.uv[1]);
				half4 sample2 = tex2D(_CameraDepthNormalsTexture, i.uv[2]);
				half4 sample3 = tex2D(_CameraDepthNormalsTexture, i.uv[3]);
				half4 sample4 = tex2D(_CameraDepthNormalsTexture, i.uv[4]);

				half edge = 1.0f;
				edge *= CheckSame(sample1, sample2);
				edge *= CheckSame(sample3, sample4);

				fixed4 edgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[0]), edge);
				fixed4 edgeColor2 = lerp(_EdgeColor, _BackgroundColor, edge);

				fixed4 col = lerp(edgeColor, edgeColor2, _EdgeWidth);
				return col;
			}
			ENDCG
		}
	}
}

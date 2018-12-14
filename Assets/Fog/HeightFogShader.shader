Shader "HeightFogFogShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_FogIntensity("Fog Intensity", Float) = 1.0
		_FogStart("Fog Start", Float) = 1.0
		_FogEnd("Fog End", Float) = 1.0
		_FogColor("Fog Color", Color) = (1, 1, 1, 1)
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

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 interpolatedRay : TEXCOORD1;
				float4 vertex : SV_POSITION;
				float2 tmp :TEXCOORD2;
			};
			
			sampler2D _MainTex;
			fixed _FogIntensity;
			fixed _FogStart;
			fixed _FogEnd;
			fixed4 _FogColor;
			fixed4x4 _FrustumCorners;
			sampler2D _CameraDepthTexture;

			fixed3 _NoiseValue;
			sampler2D _NoiseTex;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

				int index = 0;
				if (v.uv.x > 0.5 && v.uv.y > 0.5) index = 1;
				else if (v.uv.x < 0.5 && v.uv.y < 0.5) index = 2;
				else if (v.uv.x > 0.5 && v.uv.y < 0.5) index = 3;

				/*fixed2 tmp;
				tmp.x = clamp(v.uv.x, 0, 1);
				tmp.y = clamp(v.uv.x, 0, 1);
				index = tmp.x * 2 + tmp.y * 4;*/

				o.tmp = o.uv;

				o.interpolatedRay = _FrustumCorners[index];

				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float linearDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv));	//转成视角空间的深度值
				float3 worldPos = _WorldSpaceCameraPos + linearDepth * i.interpolatedRay.xyz;

				fixed noise = tex2D(_NoiseTex, i.uv + _Time.y * _NoiseValue.xy).x * _NoiseValue.z + 1;

				float fogDensity = (_FogEnd - worldPos.y) / (_FogEnd - _FogStart);
				fogDensity = saturate(fogDensity * _FogIntensity * noise); 

				fixed4 col = tex2D(_MainTex, i.uv);
				col.rgb = lerp(col.rgb, _FogColor.rgb, fogDensity);
				
				return col;
			}
			ENDCG
		}
	}
	FallBack Off
}
Shader "Melt2"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_NoiseTex("Noise", 2D) = "white" {}
		_Threshold("Threshold", Range(0, 1)) = 0.5

		_EdgeLength("Edge Length", Range(0, 0.2)) = 0.1
		_EdgeStartColor("Edge Start Color", Color) = (1, 0, 0, 1)
		_EdgeEndColor("Edge Start Color", Color) = (1, 0, 0, 1)
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
				fixed4 vertex : POSITION;
				fixed2 uv : TEXCOORD0;
			};

			struct v2f
			{
				fixed2 uv : TEXCOORD0;
				fixed2 uvNoise : TEXCOORD1;
				fixed4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;fixed4 _MainTex_ST;
			sampler2D _NoiseTex;fixed4 _NoiseTex_ST;
			fixed _Threshold;
			fixed _EdgeLength;
			fixed4 _EdgeStartColor;
			fixed4 _EdgeEndColor;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uvNoise = TRANSFORM_TEX(v.uv, _NoiseTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed cutout = tex2D(_NoiseTex, i.uvNoise).r;
				clip(cutout - _Threshold);

				fixed f = _EdgeLength + _Threshold  - cutout;
				f = max(f, 0);
				
				fixed degree = saturate((cutout - _Threshold) / _EdgeLength);
				fixed4 edgeColor = lerp(_EdgeStartColor, _EdgeEndColor, degree);
				fixed4 col = tex2D(_MainTex, i.uv);

				return lerp(edgeColor, col, degree);
			}
			ENDCG
		}
	}
}

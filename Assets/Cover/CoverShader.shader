Shader "CoverShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_CoverTex ("Texture", 2D) = "white" {}
		_CoverRange ("Cover Range", Range(-5, 5)) = 1
		_CoverColor ("Cover Color", Color) = (0.5019608,0.5019608,0.5019608,1)
		_CoverColorIntensity ("Cover Color Intensity", Range(1, 10)) = 1
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
				fixed2 uvc : TEXCOORD1;
				fixed4 posWorld : TEXCOORD2;
				fixed4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;fixed4 _MainTex_ST;
			sampler2D _CoverTex;fixed4 _CoverTex_ST;
			fixed _CoverRange;
			fixed _CoverColorIntensity;
			fixed4 _CoverColor;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uvc = TRANSFORM_TEX(v.uv, _CoverTex);
				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);

				fixed3 startCol = saturate(((tex2D(_CoverTex, i.uvc).rgb * _CoverColor.rgb) * _CoverColorIntensity));
				fixed rate = saturate(((_CoverRange + i.posWorld.y) - unity_ObjectToWorld[1].w));
				
				fixed4 finalColor = fixed4(saturate(lerp(startCol, col.rgb, rate)), 1);
				return finalColor;
			}
			ENDCG
		}
	}
}

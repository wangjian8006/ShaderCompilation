Shader "FlareShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		CGINCLUDE
		#include "UnityCG.cginc"

		struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
		};

		struct v2f
		{
			float2 uv : TEXCOORD0;
			float4 vertex : SV_POSITION;
		};
		v2f vert (appdata v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.uv = v.uv; 
			return o;
		}

		sampler2D _MainTex;
		float2 _SunDirection;
		float2 _SunPosition;
		float _FlareSize;
		float _FlareIntensity;
		sampler2D _FlareTex;
		sampler2D _GradientTex;

		fixed4 frag2 (v2f i) : SV_Target
		{
			fixed4 col = fixed4(0, 0, 0, 0);
			fixed2 uv = i.uv;
			fixed flareNum = 4;
			fixed2 offset;
			fixed2 halfOne = fixed2(0.5, 0.5);
			fixed tmp;
			for (int ii = 0; ii < flareNum; ++ii)
			{
				uv = i.uv + _SunDirection * (flareNum - ii);		//计算方向与距离，并且递增


				//offset = (-halfOne) * (ii) * _FlareSize - (_SunPosition - halfOne) * (ii + 1) * _FlareSize;		//计算相对太阳的位置
				//uv = uv * ((ii + 1) * _FlareSize) + offset;

				//优化,合并同类项
				tmp = ii * _FlareSize;
				offset = -halfOne * tmp - (_SunPosition - halfOne) * (tmp + _FlareSize);
				uv = uv * (tmp + _FlareSize) + offset;

				col += tex2D(_FlareTex, uv) * tex2D(_GradientTex, length(uv - halfOne) / length(halfOne)) * _FlareIntensity;
			}

			//col *= tex2D(_GradientTex, length(uv - half2(0.5, 0.5)) / length(half2(0.5, 0.5))) * _FlareIntensity;
			col += tex2D(_MainTex, i.uv) * 1.2;
			
			return col;
		}

		ENDCG

		Pass
		{
			ZTest Always Cull Off ZWrite Off
            Fog{ Mode off }

            CGPROGRAM
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma vertex vert
            #pragma fragment frag2
            ENDCG
		}
	}
}

Shader "ElasticShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

		_StartTime("StartTime", Float) = 0
		_Duration ("Duration", Float) = 2
		_Intensity ("Intensity", Float) = 2
		_Speed ("Speed", Float) = 2

		_Normal ("Normal", vector) = (0, 1, 0, 0)
		_Position ("Position", vector) = (0, 0, 0, 1)
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
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Position;
			float4 _Normal;
			float _StartTime;
			float _Duration;
			float _Speed;
			float _Intensity;
			
			v2f vert (appdata v)
			{
				v2f o;

				float time = _Time.y - _StartTime; 

				if (time > 0 && time < _Duration)
				{
					half dir = (1 - saturate(length(v.vertex.xyz - _Position.xyz))) * _Normal.xyz;		//距离这个点越近，在法线上面偏移越多
					v.vertex.xyz += dir * sin(time * _Speed) * _Intensity;
				}

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
Shader "DepthBuffer"
{
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
				fixed4 vertex : POSITION;
			};

			struct v2f
			{
				fixed4 vertex : SV_POSITION;
				fixed2 depth : TEXCOORD0;
			};

			sampler2D _MainTex;fixed4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.depth = o.vertex.zw;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				return EncodeFloatRGBA(i.depth.x / i.depth.y);
			}
			ENDCG
		}
	}
}

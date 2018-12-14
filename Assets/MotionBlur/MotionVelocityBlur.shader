// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MotionVelocityBlur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BlurAmount("Blur Amount", Float) = 1.0
	}
	SubShader
	{
		Pass
		{
			ZTest Always Cull Off ZWrite Off

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
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			//float4 _MainTex_ST;
			sampler2D _CameraDepthTexture;
			float4x4 _CurrentViewProjectionInvMatrix;
			float4x4 _PreViewProjectionMatrix;
			float _BlurAmount;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);		//将[0, 1]映射到[-1, 1];
				float4 H = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, d * 2 - 1, 1);		//当前深度转屏幕坐标
				float4 D = mul(_CurrentViewProjectionInvMatrix, H);						//逆转换，逆投影，逆视角转换成世界坐标。
				float4 worldPos = D / D.w;
				
				float4 currentPos = H;												//当前的NDC坐标
				float4 prePos = mul(_PreViewProjectionMatrix, worldPos);			//由当前的世界坐标乘以上一次的VP矩阵，转换成上一次的NDC坐标
				prePos = prePos / prePos.w;											

				float2 velocity = (currentPos.xy - prePos.xy) / 2.0f;				//两次NDC坐标相减得到速度方向

				float2 uv_ofst = i.uv;
				float4 c = tex2D(_MainTex, uv_ofst);
				for (int it = 1; it < 3; ++it)
				{
					uv_ofst += velocity * _BlurAmount;
					float4 currentColor = tex2D(_MainTex, uv_ofst);
					c += currentColor;
				}
				c /= 3;

				return fixed4(c.rgb, 1.0f);
			}
			ENDCG
		}
	}
	Fallback Off
}

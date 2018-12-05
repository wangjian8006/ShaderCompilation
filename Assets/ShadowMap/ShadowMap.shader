Shader "ShadowMap"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "green" {}
	}
	SubShader
	{
		Tags
		{
		 	"RenderType"="Opaque" 
	 	}
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
				float4 vertex : SV_POSITION;
				float2 uv: TEXCOORD0;
                float4 lightSpacePos : TEXCOORD1;
			};
			
			sampler2D _MainTex;fixed4 _MainTex_ST;
			fixed4x4 _ShadowMapLightProjectView;
			sampler2D _ShadowMapDepthTex;

			v2f vert (appdata v)
			{
				v2f o;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				o.vertex = UnityObjectToClipPos(v.vertex);

				fixed4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				worldPos.w = 1;
				worldPos = mul(_ShadowMapLightProjectView, worldPos);
				worldPos.xyz = worldPos.xyz / worldPos.w;
				o.lightSpacePos = worldPos * 0.5 + 0.5;	//从[-1,1]映射到[0,1]

				return o;
			}

			fixed4 frag (v2f v) : SV_Target
			{
                fixed4 col = tex2D(_MainTex, v.uv);

				//灯光空间位置的最小的深度
				fixed4 lightPos = v.lightSpacePos;
				fixed4 depthRGBA = tex2D(_ShadowMapDepthTex, lightPos.xy);
				float d = DecodeFloatRGBA(depthRGBA);

				//灯光空间位置当前渲染的深度
				fixed depth = lightPos.z;

                float shadowScale = 1;
                if(depth < d) shadowScale = 0.55;
                return col * shadowScale;
			}
			ENDCG
		}
	}
}

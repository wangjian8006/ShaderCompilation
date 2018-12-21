Shader "ShadowProjector"
{
	Properties {
		_ShadowTex ("Cookie", 2D) = "black"{}
		_ShadowEdgeMask ("ShadowEdgeMask", 2D) = "white" {}
	}
	Subshader {
		Tags {"Queue"="Transparent"}
		Pass {
			ZWrite Off
			ColorMask RGB
			Blend DstColor Zero
 
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#include "UnityCG.cginc"
			
			struct v2f {
				float4 pos : SV_POSITION;
				float4 uvShadow : TEXCOORD0;
				UNITY_FOG_COORDS(1)
			};
			
			float4x4 unity_Projector;
 
			v2f vert (float4 vertex : POSITION)
			{
				v2f o;
				o.pos = UnityObjectToClipPos (vertex);
				o.uvShadow = mul (unity_Projector, vertex);
				UNITY_TRANSFER_FOG(o,o.pos);
				return o;
			}
			
			sampler2D _ShadowMapDepthTex;
			sampler2D _ShadowEdgeMask;
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed shadowScaler = tex2Dproj(_ShadowMapDepthTex, UNITY_PROJ_COORD(i.uvShadow)).a;
				fixed shadowEdgeMask = tex2Dproj(_ShadowEdgeMask, UNITY_PROJ_COORD(i.uvShadow)).r;
				shadowScaler = max(shadowScaler, shadowEdgeMask);

				fixed4 res = fixed4(1,1,1,1) * shadowScaler;
				UNITY_APPLY_FOG_COLOR(i.fogCoord, res, fixed4(1,1,1,1));
				return res;
			}
			ENDCG
		}
	}
}

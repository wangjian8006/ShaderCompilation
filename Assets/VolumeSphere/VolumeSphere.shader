Shader "VolumeSphere"
{
	Properties
	{
		_Color ("Color", Color) = (1, 1, 1, 1)
		_MainTex ("Texture", 2D) = "white" {}
		_Radius ("radius", Range(0, 1)) = 0.4
		_Smoothness("smoothness",Float) = 0.5
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
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 wPos : TEXCOORD1;
				float3 lPos : TEXCOORD2;
                float3 normal : TEXCOORD3;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;
			float _Radius;
			float _Smoothness;
			float4 _LightColor0;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.lPos = v.vertex;
				o.wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				o.normal = v.normal;

				return o;
			}

			inline float3 ToLocal(float3 pos)  
            {  
                return mul(unity_WorldToObject, float4(pos, 1.0)).xyz; 
            }

			inline float3 ToWorld(float3 pos)  
            {  
                return mul(unity_ObjectToWorld, float4(pos, 1.0)).xyz; 
            }

			fixed4 BlinnPhong(float3 pos, float3 N, float4 mainColor)
			{
				fixed4 col;
				float3 V = normalize(_WorldSpaceCameraPos.xyz - pos);
				float3 L = normalize(_WorldSpaceLightPos0.xyz);
				float LN = max(dot(L, N), 0);			//diffuse
					
				float3 H = normalize(L+ V);
				float LH = max(dot(N, H), 0);
				float spec = pow(LH, _Smoothness);		//specular

				col = mainColor * fixed4(UNITY_LIGHTMODEL_AMBIENT.rgb, 1.0) + (LN + spec) * fixed4(_LightColor0.rgb, 1.0);

				return col;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = fixed4(1, 1, 1, 1);;
                float3 N = normalize(i.normal);
                float len = length(i.lPos.xyz) - _Radius;

				if (len > 0)
				{
					float3 camera = ToLocal(_WorldSpaceCameraPos.xyz); 
					float3 dir = normalize(i.lPos.xyz - camera);
					
					//用投影判断这个顶点,是在球内还是球外，球内可以直接画
					float dirLenth = length(camera) * dot(dir, normalize(-camera));
					float3 spherePos = camera + dir * dirLenth;

					len = length(spherePos) / _Radius;
					if (len <= 1)
					{
						float3 dir0 = normalize(spherePos);		//有交点，这个是垂直于视角方向的方向
						float3 dir1 = normalize(camera);		//摄像头方向
						float3 dir2 = normalize(lerp(dir1, dir0, asin(len) / UNITY_PI * 2));		//对两个方向进行差值，得到法线向量
						N = UnityObjectToWorldNormal(dir2);
						col = BlinnPhong(ToWorld(spherePos), N, tex2D(_MainTex, i.uv));
					}
					else discard;

				}else col = BlinnPhong(i.wPos, N, _Color);

				return col;
			}
			ENDCG
		}
	}
}

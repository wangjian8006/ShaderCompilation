Shader "Water_GeometricWaves"
{
	Properties
	{
		_Color ("Color", Color) = (1, 1, 1, 1)
		_MainTex ("Texture", 2D) = "white" {}

		_Smoothness ("Smoothness", Float) = 0.5
		_BumpTex ("Normal", 2D) = "bump" {}

		_Fresnel ("Fresnel", Float) = 0.5
		_Reflect ("Reflect", Cube) = "" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_geometric
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
			};

			struct v2f
			{
				float4 pos			: SV_POSITION;
				float2 uv			: TEXCOORD0;
				fixed2 uvNormal 	: TEXCOORD1;
				fixed3 normalDir 	: TEXCOORD2;
				fixed3 tangentDir 	: TEXCOORD3;
				fixed3 bitangentDir : TEXCOORD4;
				fixed3 viewDir		: TEXCOORD5;
			};

			fixed4 _Color;
			sampler2D _MainTex;uniform float4 _MainTex_ST;
			sampler2D _BumpTex;uniform float4 _BumpTex_ST;

			float _Fresnel;
			samplerCUBE _Reflect;

			float _Smoothness;
			fixed3 _LightColor0;

			float _WavesLengths[3];		//波长、频率
			float _Amplitudes[3];		//振幅
			float _Phases[3];			//相位
			float _DirectionXs[3];		//方向
			float _DirectionYs[3];		//方向

			float _Sharps[3];

			float2 _TextureSpeed;
			float _SpeedTime;

			v2f vert_geometric (appdata v)
			{
				v2f o;

				float4 rawPos = v.vertex;

				for (int ii = 0; ii < 3; ++ii)
				{
					float value = dot(float2(_DirectionXs[ii], _DirectionYs[ii]), rawPos.xz) * _WavesLengths[ii] + _SpeedTime * _Phases[ii];

					rawPos.x += _Sharps[ii] * _Amplitudes[ii] * _DirectionXs[ii] * cos(value);
					rawPos.z += _Sharps[ii] * _Amplitudes[ii] * _DirectionYs[ii] * cos(value);
					rawPos.y += _Amplitudes[ii] * sin(value);
				}
				
				float3 binormal = float3(1, 0, 0);
                float3 tangent = float3(0, 1, 0);
                float3 normal = float3(0, 0, 1);

				for (int ii = 0; ii < 3; ++ii)
				{
					float value = dot(float2(_DirectionXs[ii], _DirectionYs[ii]), rawPos.xz) * _WavesLengths[ii] + _SpeedTime * _Phases[ii];
					float sinv, cosv;
					sincos(value, sinv, cosv);

					float WA = _WavesLengths[ii] * _Amplitudes[ii];
					sinv *= WA;
					cosv *= WA;

					binormal.x -= _Sharps[ii] * _DirectionXs[ii] * _DirectionXs[ii] * sinv;
					binormal.y -= _Sharps[ii] * _DirectionXs[ii] * sinv;
					binormal.z += _DirectionXs[ii] * cosv;

					tangent.x -= _Sharps[ii] * _DirectionXs[ii] * _DirectionYs[ii] * sinv;
					tangent.y -= _Sharps[ii] * _DirectionYs[ii] * _DirectionYs[ii] * sinv;
					tangent.z += _DirectionYs[ii] * cosv;

					normal.x -= _DirectionXs[ii] * cosv;
					normal.y -= _DirectionYs[ii] * cosv;
					normal.z -= _Sharps[ii] * sinv;
				}

				o.pos = UnityObjectToClipPos(rawPos);
				o.normalDir = UnityObjectToWorldNormal(normal);
				o.tangentDir = normalize(mul(unity_ObjectToWorld, float4(tangent.xyz, 0.0)).xyz);
				o.bitangentDir = normalize(mul(unity_ObjectToWorld, float4(binormal.xyz, 0.0)).xyz);

				//o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);

				//视线角度
				o.viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, rawPos).xyz);

				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uvNormal = TRANSFORM_TEX(v.uv, _BumpTex);

				return o;
			}
			
			fixed3 calculateNormal(v2f i)
			{
				i.normalDir = normalize(i.normalDir);
				fixed3 normalTangent = UnpackNormal(tex2D(_BumpTex, i.uvNormal));		//切线空间法线纹理
				fixed3 normalWorld = (i.tangentDir * normalTangent.x + i.bitangentDir * normalTangent.y + i.normalDir * normalTangent.z);
				return normalize(normalWorld);
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv + _TextureSpeed * _Time.x) * _Color;

				float3 N = calculateNormal(i);
				float3 V = i.viewDir;
				float3 L = normalize(_WorldSpaceLightPos0.xyz);
				float3 H = normalize(L+ V);

				//specular
				float spec = max(0, dot(N, H));
				spec = pow(spec, _Smoothness);
				spec *= col.a;

				//reflection
				float rim = max(0, _Fresnel - dot(N,V));
				rim *= col.a;
				fixed4 refl = texCUBE(_Reflect, -reflect(V, N)) * rim;

				col.rgb += UNITY_LIGHTMODEL_AMBIENT.xyz;
				col.rgb += _LightColor0.rgb * spec;
				col.rgb += refl.rgb;

				col.a = max(spec, col.a);
				//col = float4(i.normalDir, 1);
				//col = float4(N, 1);
				return col;
			}
			ENDCG
		}
	}
}

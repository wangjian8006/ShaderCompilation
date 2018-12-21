Shader "Water_GeometricWaves"
{
	Properties
	{
		_Color ("Color", Color) = (1, 1, 1, 1)

		_Smoothness ("Smoothness", Float) = 0.5
		_BumpTex ("Normal", 2D) = "bump" {}

		_Fresnel ("Fresnel", Float) = 0.5
		_Reflect ("Reflect", Cube) = "" {}
	}
	SubShader
	{
		/*Tags {
			"RenderType" = "Transparent"
			"Queue" = "Transparent"
		}
		*/
		Tags { "RenderType" = "Opaque" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_geometric
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				half4 vertex : POSITION;
				half2 uv : TEXCOORD0;
				half3 normal : NORMAL;
			};

			struct v2f
			{
				half4 pos			: SV_POSITION;
				half4 bumpUv		: TEXCOORD0;
				fixed3 normalDir 	: TEXCOORD1;
				fixed3 viewDir		: TEXCOORD2;
			};

			fixed4 _Color;
			sampler2D _BumpTex;uniform half4 _BumpTex_ST;

			half _Smoothness;
			fixed3 _LightColor0;

			half4 _WavesLengths;	//波长、频率
			half4 _Amplitudes;		//振幅
			half4 _Phases;			//相位
			half4 _Sharps;			//锐度
			half4 _DirectionX;		//AB方向
			half4 _DirectionY;		//CD方向

			samplerCUBE _Reflection;
			half _Fresnel;

			half4 _BumpDirection;
			half4 _BumpTiling;

			half3 CalculaterOffset(half3 rawPos)
			{
				half4 tmp = _WavesLengths * (_DirectionX * rawPos.x +  _DirectionY * rawPos.z) + _Phases * _Time.yyyy;
				half4 sinv, cosv;
				sincos(tmp, sinv, cosv);

				tmp = _Sharps * _Amplitudes;

				cosv *= tmp;

				rawPos.x = dot(_DirectionX, cosv);
				rawPos.z = dot(_DirectionY, cosv);
				rawPos.y = dot(_Amplitudes, sinv);

				return rawPos;
			}

			half3 GenerateNormal(half3 rawPos)
			{
				half4 tmp = _WavesLengths * (_DirectionX * rawPos.x +  _DirectionY * rawPos.z) + _Phases * _Time.yyyy;
				half4 cosv = cos(tmp);

				tmp = _WavesLengths * _Amplitudes;		//W x A
				cosv *= tmp;

				half3 normal;
				normal.x = -dot(_DirectionX, cosv);
				normal.y = 2.0;//1 - dot(_Sharps, sinv);
				normal.z = -dot(_DirectionY, cosv);

				normal = normalize(normal);
				return normal;
			}

			v2f vert_geometric (appdata v)
			{
				v2f o;

				half3 wolrdPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				half3 offsetPos = CalculaterOffset(wolrdPos);
				
				wolrdPos += offsetPos;
				half3 normal = GenerateNormal(wolrdPos);

				v.vertex.xyz += offsetPos;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.normalDir = normal;

				half2 tileableUv = mul(unity_ObjectToWorld, (v.vertex)).xz;
				o.bumpUv = (tileableUv.xyxy + _Time.xxxx * _BumpDirection.xyzw) * _BumpTiling.xyzw;

				//视线角度
				o.viewDir = _WorldSpaceCameraPos.xyz - wolrdPos.xyz;
				
				return o;
			}
			
			fixed3 CalculateNormal(v2f i)
			{
				half3 bump = (UnpackNormal(tex2D(_BumpTex, i.bumpUv.xy)) + UnpackNormal(tex2D(_BumpTex, i.bumpUv.zw))) * 0.5;
				half3 worldNormal = i.normalDir + bump.xxy * half3(1,0,1);
				return normalize(worldNormal);
			}

			float Fresnel(float3 V, float3 N)
			{

				half VN = max(dot(V, N), 0.0);
				half fresnelBias = 0.4;

				half facing = (1.0 - VN);
				return max(fresnelBias + (1 - fresnelBias) * pow(facing, _Fresnel), 0.0);
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = _Color;

				half3 N = CalculateNormal(i);
				half3 V = normalize(i.viewDir);
				half3 L = normalize(_WorldSpaceLightPos0.xyz);
				half3 H = normalize(_WorldSpaceLightPos0.xyz + i.viewDir);

				//specular
				half spec = max(0, dot(N, H));
				spec = max(0, pow(spec, _Smoothness));

				N = half3(0, 1, 0);
				half refl2Refr = Fresnel(V, N);
				half4 refColor = texCUBE(_Reflection, -reflect(V, N));

				col = lerp(col, refColor, refl2Refr);
				col.rgb += _LightColor0.rgb * spec;

				//col.rgb = half3(H.xyz);
				return col;
			}
			ENDCG
		}
	}
}

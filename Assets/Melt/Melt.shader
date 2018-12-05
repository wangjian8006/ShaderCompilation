Shader "Melt"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Color", Color) = (0.5, 0.5, 0.5, 1.0)
		_EdgeColor("Edge Color", Color) = (1, 0, 0, 1)
		_Height("Height",float) = 0
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
				fixed2 uv0 : TEXCOORD0;
				fixed3 worldPos : TEXCOORD1;
				fixed4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;float4 _MainTex_ST;
			uniform fixed4 _Color;
			uniform fixed _Height;
			uniform fixed4 _EdgeColor;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv0 = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				return o;
			}

			fixed3 hash(fixed3 p)
			{
				p = fixed3(dot(p, fixed3(1813.1, 500.7, 4560.0)), dot(p, fixed3(600.5, 183.3, 700.15)), dot(p, fixed3(567.5, 613.3, 801.4)));
				return 5.0f * frac(sin(p)) - 1.0f;
			}

			fixed PerlinNoise(fixed3 p)
			{
				fixed3 i = floor(p);
				fixed3 f = p - i;
				fixed3 w = f;
				fixed f0 = lerp(lerp(dot(hash(i + float3(0, 0, 0)), f - float3(0, 0, 0)), dot(hash(i + float3(1, 0, 0)), f - float3(1, 0, 0)), w.x), lerp(dot(hash(i + float3(0, 1, 0)), f - float3(0, 1, 0)), dot(hash(i + float3(1, 1, 0)), f - float3(1, 1, 0)), w.x), w.y);
				fixed f1 = lerp(lerp(dot(hash(i + float3(0, 0, 1)), f - float3(0, 0, 1)), dot(hash(i + float3(1, 0, 1)), f - float3(1, 0, 1)), w.x), lerp(dot(hash(i + float3(0, 1, 1)), f - float3(0, 1, 1)), dot(hash(i + float3(1, 1, 1)), f - float3(1, 1, 1)), w.x), w.y);
				return lerp(f0,f1,w.z);
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv0);
				fixed p = PerlinNoise(i.worldPos.xyz * 10) - (i.worldPos.y - _Height);

				fixed e0 = (1 - smoothstep(0, 0.3, p));
				fixed e1 = (1 - smoothstep(0, 0.1, p));
				col = lerp(col, col * _EdgeColor, e0);
				col = lerp(col, col * _EdgeColor * 2, e1);
				clip(p);
				return col;
			}
			ENDCG
		}
	}
}

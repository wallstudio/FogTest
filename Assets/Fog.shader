// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/Fog"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_FogColor ("Fog Color", Color) = (0, 0, 0, 0)
		_StartY ("Start Y", Float) = 0.0
		_EndY ("End Y", Float) = 1.0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
// Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members worldPos)
// #pragma exclude_renderers d3d11
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float4 worldPos : POSITION1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _StartY;
			float _EndY;
			float4 _FogColor;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				float y = clamp(i.worldPos.y, _StartY, _EndY);
				float x = (y - _StartY) / (_EndY - _StartY);
				return col * (1-x) + _FogColor * x;
			}
			ENDCG
		}
	}
}

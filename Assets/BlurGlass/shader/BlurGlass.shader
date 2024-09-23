Shader "mgo/BlurGlass" 
{
	Properties
	{
		_MainTexture("MainTexture", 2D) = "" {}
		_BlurTexture("BlurTexture", 2D) = "" {}
		_TintColor("TintColor", Color) = (0, 0, 1, 0.5)
	}

	HLSLINCLUDE

	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

	struct appdata_img 
	{
		float4 vertex:POSITION;
		float2 uv:TEXCOORD0;
	};
	struct v2f
	{
		float4 pos : POSITION;
		float2 uv : TEXCOORD0;
	};

	sampler2D _MainTexture;
	float4 _MainTexture_ST;
	sampler2D _BlurTexture;
	float4 _TintColor;

	v2f vert(appdata_img v) 
	{
		v2f o;
		VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
		o.pos = vertexInput.positionCS;
		o.uv = TRANSFORM_TEX(v.uv, _MainTexture);
		return o;
	}

	half4 frag(v2f i) : SV_Target
	{
		//ÆÁÄ»uv
		half2 screenUV = (i.pos.xy / _ScreenParams.xy);
		half4 blurCol = tex2D(_BlurTexture, screenUV);
		half4 mainCol = tex2D(_MainTexture, i.uv);
		mainCol *= _TintColor;
		blurCol.rgb = blurCol.rgb * (1-mainCol.a) + mainCol.rgb * mainCol.a;
		if(mainCol.a < 0.005)
		{
			blurCol.a = 0;
		}
		return blurCol;
	}

	ENDHLSL

	Subshader 
	{
		Pass
		{
			Tags
			{
				"LightMode" = "UniversalForward"
			}

			ZTest Always Cull Off ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			HLSLPROGRAM
			//#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment frag
			ENDHLSL
		}
	}
}

Shader "mgo/Blur" {
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "" {}
	}

	HLSLINCLUDE
	
	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

	struct appdata
	{
		float4 vertex:POSITION;
		float2 texcoord:TEXCOORD0;
	};
	struct v2f 
	{
		float4 pos : POSITION;
		float2 uv0 : TEXCOORD0;
		float4 uv1 : TEXCOORD1;
		float4 uv2 : TEXCOORD2;
		float4 uv3 : TEXCOORD3;
	};
	
	float2 offsets;
	
	sampler2D _MainTex;
	
	v2f vert (appdata v) 
	{
		v2f o;
		VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
		o.pos = vertexInput.positionCS;
		o.uv0.xy = v.texcoord.xy;

		o.uv1 =  v.texcoord.xyxy + offsets.xyxy * float4(1,1, -1,-1);
		o.uv2 =  v.texcoord.xyxy + offsets.xyxy * float4(1,1, -1,-1) * 2.0;
		o.uv3 =  v.texcoord.xyxy + offsets.xyxy * float4(1,1, -1,-1) * 3.0;
		return o;
	}
	
	half4 frag (v2f i) : COLOR
	{
		half4 color = float4 (0,0,0,0);

		color += 0.40 * tex2D (_MainTex, i.uv0);
		color += 0.15 * tex2D (_MainTex, i.uv1.xy);
		color += 0.15 * tex2D (_MainTex, i.uv1.zw);
		color += 0.10 * tex2D (_MainTex, i.uv2.xy);
		color += 0.10 * tex2D (_MainTex, i.uv2.zw);
		color += 0.05 * tex2D (_MainTex, i.uv3.xy);
		color += 0.05 * tex2D (_MainTex, i.uv3.zw);
		return color;
	}

	ENDHLSL
	
	Subshader 
	{
		Tags { "RenderType"="Opaque" }
        LOD 100

		Pass 
		{
			ZTest Always
			Cull Off 
			ZWrite Off
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDHLSL
		}
	}

}

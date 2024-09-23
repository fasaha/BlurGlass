Shader "mgo/BlurGlass" 
{
	Properties
	{
		_MainTexture("MainTexture", 2D) = "" {}
		_BlurTexture("BlurTexture", 2D) = "" {}
		_TintColor("TintColor", Color) = (0, 0, 1, 0.5)
	}


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

			CGPROGRAM

			#include "UnityCG.cginc"


			struct appdata
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

			v2f vert(appdata v) 
			{
				v2f o;
				//计算出裁剪空间下的坐标
				o.pos = UnityObjectToClipPos(v.vertex.xyz);
				o.uv = TRANSFORM_TEX(v.uv, _MainTexture);
				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				//_ScreenParams.xy 
				//x 是摄像机目标纹理的宽度（以像素为单位），y 是摄像机目标纹理的高度（以像素为单位）
				half2 screenUV = (i.pos.xy / _ScreenParams.xy);
				//对模糊RT采样
				half4 blurCol = tex2D(_BlurTexture, screenUV);
				//对玻璃贴图采样
				half4 mainCol = tex2D(_MainTexture, i.uv);
				mainCol *= _TintColor;
				//根据玻璃颜色和模糊RT计算最终呈现的颜色
				blurCol.rgb = blurCol.rgb * (1-mainCol.a) + mainCol.rgb * mainCol.a;
				if(mainCol.a < 0.005)
				{
					blurCol.a = 0;
				}
				return blurCol;
			}

			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
}

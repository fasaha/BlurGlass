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
				//������ü��ռ��µ�����
				o.pos = UnityObjectToClipPos(v.vertex.xyz);
				o.uv = TRANSFORM_TEX(v.uv, _MainTexture);
				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				//_ScreenParams.xy 
				//x �������Ŀ������Ŀ�ȣ�������Ϊ��λ����y �������Ŀ������ĸ߶ȣ�������Ϊ��λ��
				half2 screenUV = (i.pos.xy / _ScreenParams.xy);
				//��ģ��RT����
				half4 blurCol = tex2D(_BlurTexture, screenUV);
				//�Բ�����ͼ����
				half4 mainCol = tex2D(_MainTexture, i.uv);
				mainCol *= _TintColor;
				//���ݲ�����ɫ��ģ��RT�������ճ��ֵ���ɫ
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

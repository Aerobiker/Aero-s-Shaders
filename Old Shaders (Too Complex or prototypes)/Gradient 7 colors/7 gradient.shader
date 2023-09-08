Shader "AeroFunky/7 gradient"
{
	Properties
	{
		[Enum(Off, 0, Front, 1, Back, 2)] _CullMode("Culling Mode", int) = 2
		[Enum(1 color,0,2 colors, 1,3 colors, 2,4 colors, 3,5 colors, 4,6 colors, 5,7 colors, 6)] _settings("Select color gradient amount (How many colors to consider)",float) = 1
		[Enum(Lerp, 0, SmoothStep, 1)] _BlendMode("Blend mode",int) = 0

		[HDR]_colors_1_Color("First color",Color) = (1,1,1,1)

		_colors_2_Range("Blend pos for color 2",range(0,1)) = 1
		[HDR]_colors_2_Color("Second color",Color) = (1,1,1,1)

		_colors_3_Range("Blend pos for color 3",range(0,1)) = 1
		[HDR]_colors_3_Color("Third color",Color) = (1,1,1,1)

		_colors_4_Range("Blend pos for color 4",range(0,1)) = 1
		[HDR]_colors_4_Color("Fourth color",Color) = (1,1,1,1)

		_colors_5_Range("Blend pos for color 5",range(0,1)) = 1
		[HDR]_colors_5_Color("Fifth color",Color) = (1,1,1,1)

		_colors_6_Range("Blend pos for color 6",range(0,1)) = 1
		[HDR]_colors_6_Color("Sixth color",Color) = (1,1,1,1)
 
		[HDR]_colors_7_Color("Seventh color",Color) = (1,1,1,1)
	}
		SubShader
	{
		Tags
		{
			"RenderType" = "Opaque"
			"IsEmissive" = "true"
		}

		Cull[_CullMode]


		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			uniform float _settings;
			uniform float _BlendMode;

			uniform half4 _colors_1_Color;

			uniform fixed _colors_2_Range;
			uniform half4 _colors_2_Color;

			uniform fixed _colors_3_Range;
			uniform half4 _colors_3_Color;

			uniform fixed _colors_4_Range;
			uniform half4 _colors_4_Color;

			uniform fixed _colors_5_Range;
			uniform half4 _colors_5_Color;

			uniform fixed _colors_6_Range;
			uniform half4 _colors_6_Color;

			uniform half4 _colors_7_Color;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				half pointPos[7] : TEXCOORD1;
				float4 pointColor[7] : TEXCOORD8;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.pointPos[1] = _colors_2_Range;
				o.pointPos[2] = _colors_3_Range;
				o.pointPos[3] = _colors_4_Range;
				o.pointPos[4] = _colors_5_Range;
				o.pointPos[5] = _colors_6_Range;

				o.pointColor[0] = _colors_1_Color;
				o.pointColor[1] = _colors_2_Color;
				o.pointColor[2] = _colors_3_Color;
				o.pointColor[3] = _colors_4_Color;
				o.pointColor[4] = _colors_5_Color;
				o.pointColor[5] = _colors_6_Color;
				o.pointColor[6] = _colors_7_Color;

                return o;
            }

			float InverseLerp(float a, float b, float value)
			{
				return (value - a) / (b - a);
			}

			float4 SelectInterpolationMode(float4 color1, float4 color2, float pos, int mode) {
				switch(mode) {
					case 1:
						return 1 - smoothstep(color1, color2, pos);
						break;
					default:
						return lerp(color2, color1, pos);
						break;
				}
			}

            fixed4 frag (v2f i) : SV_Target
            {
				float segmentPortion = 1 / (_settings+1);
				int segmentIndex = (i.uv.x) / segmentPortion;
				if (segmentIndex == _settings) {
					return SelectInterpolationMode( i.pointColor[0] , i.pointColor[_settings] , (i.uv.x / segmentPortion - segmentIndex) , _BlendMode);
				}
				else {
					return SelectInterpolationMode( i.pointColor[segmentIndex+1] , i.pointColor[segmentIndex] , i.uv.x / segmentPortion - segmentIndex + i.pointPos[segmentIndex+1] , _BlendMode);
				}

            }
            ENDCG
        }
    }
	FallBack "Diffuse"
}

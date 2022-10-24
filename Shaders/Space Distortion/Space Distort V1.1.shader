Shader "AeroFunky/Space Distort V1.1"
{
    Properties
    {
		[Header(Distortion Settings)]
		[Enum(Wave, 0, Twirl, 1)]_DistortionMode("Distortion mode",int) = 0
		_DistortionScale("Distortion Scale",float) = 4.5
		_DistortionSpeed("Distortion Speed",float) = 0
		_DistortionParam("Distortion param(scale,shift,power,0)",Vector) = (0.3,9,1,0)

		[Space(8)]
		[Header(Color Settings)]
		[Toggle]_HoleMode("Toggle hole", int) = 1
		[HDR]_HoleColor("Color of the hole created",COLOR) = (0,0,0,0)
		_HoleParam("Hole param(scale,power,0,0)",Vector) = (1.15,1.8,0,0)
    }
    SubShader
    {
		Tags{
				"Queue" = "Transparent"
				"DisableBatching" = "True"
		}
        LOD 100

		GrabPass
		{
			"_BackgroundTexture"
		}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

			sampler2D _BackgroundTexture;

			fixed _DistortionMode;
			float _DistortionScale;
			float _DistortionSpeed;
			float4 _DistortionParam;

			fixed _HoleMode;
			float4 _HoleColor;
			float4 _HoleParam;

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float4 screenUV : TEXCOORD0;
				float4 scrPos : TEXCOORD1;
				float4 objectPos : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.scrPos = ComputeScreenPos(o.vertex);
				o.screenUV = ComputeGrabScreenPos(o.vertex);
				o.objectPos = ComputeScreenPos(UnityObjectToClipPos(float3(0, 0, 0)));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float4 objectOrigin = mul(unity_ObjectToWorld, float4(0,0,0, 1.0));
				float distanceOrigin = distance(objectOrigin, _WorldSpaceCameraPos);

				float2 uv3 = i.screenUV.xy / i.screenUV.w;
				float2 objectUV = -(i.objectPos.xy / i.objectPos.w) + (i.scrPos.xy / i.scrPos.w);

				objectUV.x *= _ScreenParams.x / _ScreenParams.y;
				objectUV.xy *= distanceOrigin;

				float xsquared = dot(objectUV, objectUV)*_DistortionScale*distanceOrigin;
				float influence = pow(max(1 - (2 * xsquared / (xsquared + 1)), 0), _DistortionParam[2]);

				float2 shiftEQ;
				float angle;
				switch (_DistortionMode) {
					case 0:
						angle = influence * _DistortionParam[1] + _Time.z*_DistortionSpeed;
						shiftEQ = _DistortionParam[0] * influence * float2(sin(angle), cos(angle));
						break;
					case 1:
						angle = influence * length(objectUV) * _DistortionParam[1] + _Time.z*_DistortionSpeed;
						shiftEQ = _DistortionParam[0] * influence * float2(

										cos(angle) * objectUV.x - sin(angle) * objectUV.y	,
										sin(angle) * objectUV.x + cos(angle) * objectUV.y

										);
						break;
					default:
						shiftEQ = float2(0, 0);
						break;
				}
				

                fixed4 col = tex2D(_BackgroundTexture, uv3 + shiftEQ);
				if (_HoleMode) {
					col.rgb = lerp(col.rgb , _HoleColor.rgb , pow(influence * _HoleParam[0], _HoleParam[1]));
				}
                return col;
            }
            ENDCG
        }
    }
}

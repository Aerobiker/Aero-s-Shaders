Shader "AeroFunky/Lens Distort V2"
{
	Properties
	{
		[Enum(Fresnel Zoom, 0, Half PBR, 1)]_LensDistortionMode("Lens Distortion Mode", float) = 0  

		[Header(Fresnel Zoom)]
		[Space(10)]
		[Toggle]_ToggleDistortionFresnelObserve("Toggle Fresnel Preview",float) = 0
		_DistortionFresnelThreshold("IOR",float) = 1.9
		_DistortionFresnel("Distortion Power",float) = -1.51
		_Magnification("Magnification coefficient",float) = 2

		[Header(Half PBR)]
		[Space(10)]
		_IORMaterial("IOR value of the material", float) = 1.33
		_IORSpace("IOR value of the air", float) = 1.00273
		_IORMagnification("Magnification",float) = 1

		[Space(40)]
		[Header(Fresnel effect on the lens)]
		[Space(10)]
		[Toggle]_ToggleFresnel("Toggle Fresnel",float) = 0
		_Fresnel("Fresnel", float) = 124.91
		_FresnelPower("Fresnel Power", float) = -1.37

		[Space(40)]
		[Header(Chromatic Aberation)]
		[Space(10)]
		[Toggle]_ToggleChromaticAberation("Toggle Chromatic Aberation",float) = 0
		_ChromaticAberation("Chromatic Aberation",float) = 0.03
		_ChromaticShiftX("Chromatic Aberation 'R G B' shift X", Vector) = (0,0,0,0.73)
		_ChromaticShiftY("Chromatic Aberation 'R G B' shift Y", Vector) = (0,0,0,2.63)
	}


		SubShader
	{
		Tags
			{
				"Queue" = "Transparent"
				"DisableBatching" = "True"
			}
		LOD 100

		// Grab the screen behind the object into _BackgroundTexture (will batch the screen texture, for other objects using the same name) -> efficient
		GrabPass
		{
			"_BackgroundTexture"
		}

		// Render the object with the texture generated above, and invert the colors
		Pass
		{
			ZTest less
			Cull Back

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			// ====================== VARIABLES ======================

			fixed _LensDistortionMode;
			sampler2D _BackgroundTexture;

			fixed _ToggleDistortionFresnelObserve;
			float _DistortionFresnelThreshold;
			float _DistortionFresnel;
			float _Magnification;

			float _IORMaterial;
			float _IORSpace;
			float _IORMagnification;

			fixed _ToggleFresnel;
			float  _Fresnel;
			float _FresnelPower;

			fixed _ToggleChromaticAberation;
			float _ChromaticAberation;
			float4 _ChromaticShiftX;
			float4 _ChromaticShiftY;

			// ====================== DATA STRUCTURES ======================

            struct appdata
            {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION; // a.k.a. : pos
				float4 grabPos : TEXCOORD0;

				float3 normal : NORMAL;
				float3 viewDir : TEXCOORD1;
				float3 refractionMap : TEXCOORD2;
				float fresnelCoords : TEXCOORD3;
				float distortionFresnelUV : TEXCOORD4;
            };

			// ====================== VERTEX FUNCTION ======================

            v2f vert (appdata v)
            {
                v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);		// Pos of vertecies

				o.normal = UnityObjectToWorldNormal(v.normal); // Get normals and set them to world
				o.viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex)); // SImple get view dir OF EVERY VERTEX

				static const float IOR = _IORSpace/_IORMaterial;
				o.refractionMap = normalize(o.viewDir + o.normal*IOR); // Gets the refracted vector
				o.fresnelCoords = dot(o.normal, o.viewDir);
				o.distortionFresnelUV = pow(o.fresnelCoords * _DistortionFresnelThreshold, _DistortionFresnel); // Make it more powerful

				switch (_LensDistortionMode) {
					case 0 :
						o.grabPos = ComputeGrabScreenPos(o.vertex + float4(0, 0, 0, o.distortionFresnelUV*_Magnification)); // GrabPos gets the screen uv's of the object in the screen (and the vector, allows a shift in the clip pos (zoom))
						break;
					case 1 :
						o.grabPos = ComputeGrabScreenPos(o.vertex);
						break;
					default :
						o.grabPos = ComputeGrabScreenPos(o.vertex);
						break;
				}
				




                return o;
            }

			// ====================== FRAGMENT FUNCTION ======================

            fixed4 frag (v2f i) : SV_Target
            {
				float4 coords;
				switch (_LensDistortionMode) {
					case 0:
						coords = UNITY_PROJ_COORD(i.grabPos); // Project the coords correctly
						break;
					case 1:
						float4 ScreenPosRefractionMap = ComputeGrabScreenPos(float4(i.refractionMap, _IORMagnification));
						coords = UNITY_PROJ_COORD(ScreenPosRefractionMap);
						break;
					default:
						coords = UNITY_PROJ_COORD(i.grabPos);
						break;
				}

				float2 cordUV = coords.xy / coords.w; // Scale the UV's by their distance in the clip plane
				float4 col = float4(1, 1, 1, 1);

				if (_ToggleChromaticAberation) {
					// Shift red, green and blue channels of the texture (must be treated separatly)
					float fresnelAbberation = pow(i.fresnelCoords*_ChromaticShiftX[3], _ChromaticShiftY[3]);
					float2 red_uv = cordUV + _ChromaticAberation*float2(_ChromaticShiftX[0], _ChromaticShiftY[0])*0.1 / fresnelAbberation;
					float2 green_uv = cordUV + _ChromaticAberation*float2(_ChromaticShiftX[1], _ChromaticShiftY[1])*0.1 / fresnelAbberation;
					float2 blue_uv = cordUV + _ChromaticAberation*float2(_ChromaticShiftX[2], _ChromaticShiftY[2])*0.1/ fresnelAbberation;

					col.r = tex2D(_BackgroundTexture, red_uv).r;
					col.g = tex2D(_BackgroundTexture, green_uv).g;
					col.b = tex2D(_BackgroundTexture, blue_uv).b;
				}
				else {
					col = tex2D(_BackgroundTexture, cordUV); // (simply show the magnification
				}

				col += i.distortionFresnelUV*_ToggleDistortionFresnelObserve; // make a preview, so its easier to set the right parameters for the distortion

				if (_ToggleFresnel) {
					col += pow(i.fresnelCoords*_Fresnel, _FresnelPower);
				}

                return col;
            }
            ENDCG
        }
    }
}

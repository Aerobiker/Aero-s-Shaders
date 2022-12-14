Shader "AeroFunky/Simple Zoom V1.3"
{
	Properties
	{
		[Header(########  ( Main Settings )  ########)]
		[Space(6)]
		[PowerSlider(2)]_ZoomFactor("Zoom Factor", Range(-10, 10)) = 0

		// --------
		[Space(40)]
		[Header(########  ( Color Settings )  ########)]
		[Space(6)]
		[Enum(Multiply,0,Sum,1,Hue Shift,2,Gradient,3,Modulo,4)] _ColorBlendMode("Color blending mode",int) = 0
		[Toggle] _InvertColors("Invert Colors (for all modes)",int) = 0
		[HDR] _ColorToBlend("Color to get blended",Color) = (1,1,1,1)

		[Header((  .  ) Hue Options (  .  ))]
		[Space(6)]
		_HueShift("Hue shift (select mode first)",Range(0,6.2831853)) = 0
		[HDR] _HueColorShift("Hue Color Shift (only on hue)",Color) = (1,1,1,1)
		_HueSaturation("Hue Saturation Control",Range(0,5)) = 1
		_HueBrigthness("Hue Brightness Control",Range(-1,1)) = 0

		[Header((  .  )  Gradient Options (  .  ) )]
		[Space(6)]
		[Toggle] _GradientToggleCol_Map("Use a 2 colors or a gradient map",int) = 0
		[HDR] _GradientColor1("Gradient Color 1 (Dark zones)",Color) = (0,0,0,1)
		[HDR] _GradientColor2("Gradient Color 2 (Bright zones)",Color) = (1,1,1,1)
		_GradientSampleTex("Gradient map (1D image on x)",2D) = "gradient" {}
		[Header((  .  )  Effects Options (  .  ) )]
		[Space(6)]
		[PowerSlider(2)]_ModuloProportion("Modulo degree (effect modulo)",Range(0,2)) = 0.5

		// --------
		[Space(40)]
		[Header(########  ( Shading Settings )  ########)]
		[Space(6)]
		[Enum(None,0,MatCap,1,Cubemap,2,Blinn Phong,3,Goosh,4)] _ShadingMode("Shading mode (lazy implementation)",int) = 0 // https://github.com/GarrettGunnell
		[Enum(Real,0,Point Light,1)] _FakeLightMode("Light mode",int) = 0
		
		[Header((  .  )  Light Options (  .  ) )]
		[Space(6)]
		[HDR] _PointLightColor("Point Light Color",Color) = (1,1,1,1)
		_FakeLightPointVector("Point Light Params (local) (x, y, z, power)",Vector) = (0,1,1,1)

		[Header((  .  )  Texture Options (  .  ) )]
		[Space(6)]
		[NoScaleOffset]_MatcapSampleTex("Matcap Texture (Sum blend)",2D) = "white" {}
		[NoScaleOffset]_CubemapSampleTex("Cubemap (HDR) (For fake lights) DEPRECATED",Cube) = "grey" {} // https://github.com/TwoTailsGames/Unity-Built-in-Shaders/blob/master/DefaultResourcesExtra/Skybox-Cubed.shader
		
		[Header((  .  )  Blinn Phong Options (  .  ) )]
		[Space(6)]
		[HDR]_Diffuse("Diffuse Color", Color) = (1, 1, 1, 1)
		[HDR]_Specular("Specular Color", Color) = (1, 1, 1, 1)
		[PowerSlider(3.0)]_Gloss("Gloss", Range(1.0, 256.0)) = 32.0
		
		[Header((  .  )  Goosh Options (  .  ) )]
		[Space(6)]
		_Smoothness("Smoothness", Range(0.01, 1)) = 0.5
		_Warm("Warm Color", Color) = (1, 0.588, 0, 1)
		_Cool("Cool Color", Color) = (0.345098, 0.160784, 0.623539, 1)
		_Alpha("Alpha (Cool control)", Range(0.01, 1)) = 0.5
		_Beta("Beta (Warm control)", Range(0.01, 1)) = 0.5

		// --------
		[Space(100)]
		[Header(########   Technical Options   ########)]
		[Space(6)]
		[Enum(Off, 0, On, 1)]_ZWriteMode("ZWriteMode", float) = 1
		[Enum(UnityEngine.Rendering.CompareFunction)]_ZTestMode("ZTestMode", float) = 4
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode", float) = 2
	}


		SubShader
		{
			Tags
				{
					"Queue" = "Transparent"
					"RenderType" = "Transparent"
					"DisableBatching" = "True"
				}
			LOD 100

			// Grab the screen behind the object into _BackgroundTexture (will batch the screen texture, for other objects using the same name) -> efficient
			GrabPass
			{
				"_GrabTexture_Transparent"
			}

			// Render the object with the texture generated above, and invert the colors
			Pass
			{
				ZTest[_ZTestMode]
				Cull[_CullMode]

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#include "UnityCG.cginc"
				#include "lighting.cginc"

			// ====================== VARIABLES ======================

				sampler2D	_GrabTexture_Transparent;

				float	_ZoomFactor;

				float4	_ColorToBlend;
				fixed	_ColorBlendMode;
				fixed	_InvertColors;

				float	_HueShift;
				float4	_HueColorShift;
				float	_HueSaturation;
				float	_HueBrigthness;

				fixed	_GradientToggleCol_Map;
				half4	_GradientColor1;
				half4	_GradientColor2;
				sampler2D	_GradientSampleTex;

				float	_ModuloProportion;
					
				fixed	_ShadingMode;
				sampler2D	_MatcapSampleTex;
				samplerCUBE _CubemapSampleTex;

				fixed	_FakeLightMode;
				half4	_PointLightColor;
				half4	_FakeLightPointVector;
				half4	_Diffuse;
				half4	_Specular;
				half	_Gloss;

				float4 _Warm, _Cool;
				float _Smoothness, _Alpha, _Beta;

			// ====================== DATA STRUCTURES ======================

				struct appdata
				{
					float4 vertex		: POSITION;
					float2 uv			: TEXCOORD0;
					float3 normal		: NORMAL;
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				struct v2f
				{
					float4 pos			: SV_POSITION;
					float4 grabPos		: TEXCOORD0; // grabbed screen pos
					float3 viewPos		: TEXCOORD1; // VIEW pos of vertex
					float3 wordPos		: TEXCOORD13;
					float4 vertex		: TEXCOORD2; // CLIP pos of vertex
					float2 uv			: TEXCOORD3;
					float3 normal		: TEXCOORD4; // OBJECT normal
					float3 worldViewDir	: TEXCOORD5; // WORLD ViewDir
					float3 worldNorm	: TEXCOORD6; // WORLD normal
					float3 viewNorm		: TEXCOORD7; // VIEW normal
					float3 viewDir		: TEXCOORD8; // VIEW vertex
					float3 viewOrigin	: TEXCOORD9; // WORLD cam origin
					float3 objOrigin	: TEXCOORD10; // WORLD object origin
					float distOrigin	: TEXCOORD11; // Distance from center to camera
					float2 capUV		: TEXCOORD12;
					UNITY_VERTEX_OUTPUT_STEREO
						
				};

				// ====================== CUSTOM FUNCTION ======================

				float3 hueShift(float3 color, float hueAdjust) {
					// Optimised Hue shift function in GLSL (adapted to HLSL)
					// Source : https://gist.github.com/mairod/a75e7b44f68110e1576d77419d608786

					const float3  kRGBToYPrime = float3(0.299, 0.587, 0.114);
					const float3  kRGBToI = float3(0.596, -0.275, -0.321);
					const float3  kRGBToQ = float3(0.212, -0.523, 0.311);

					const float3  kYIQToR = float3(1.0, 0.956, 0.621);
					const float3  kYIQToG = float3(1.0, -0.272, -0.647);
					const float3  kYIQToB = float3(1.0, -1.107, 1.704);

					float   YPrime = dot(color, kRGBToYPrime) + _HueBrigthness;
					float   I = dot(color, kRGBToI);
					float   Q = dot(color, kRGBToQ);
					float   hue = atan2(Q, I);
					float   chroma = sqrt(I * I + Q * Q) * _HueSaturation;

					hue += hueAdjust;

					Q = chroma * sin(hue);
					I = chroma * cos(hue);

					float3    yIQ = float3(YPrime, I, Q);

					return float3(dot(yIQ, kYIQToR), dot(yIQ, kYIQToG), dot(yIQ, kYIQToB));

				}

				// ====================== VERTEX FUNCTION ======================

				v2f vert(appdata v)
				{
					v2f o;
					o.pos			= UnityObjectToClipPos(v.vertex); // vertecies
					o.grabPos		= ComputeGrabScreenPos(o.pos + float4(0, 0, 0, _ZoomFactor)); // reprojection
					o.wordPos		= mul(unity_ObjectToWorld, v.vertex);
					o.viewPos		= UnityObjectToViewPos(v.vertex);
					o.viewDir		= normalize(o.viewPos);
					o.objOrigin		= mul(unity_ObjectToWorld, float4(0, 0, 0, 1.0));
					o.vertex = v.vertex;
					o.uv			= v.uv;
					o.normal		= normalize(v.normal);
					o.worldNorm		= UnityObjectToWorldNormal(v.normal);
					o.viewNorm		= mul((float3x3)UNITY_MATRIX_V, o.worldNorm);
					
					#if defined(USING_STEREO_MATRICES)
						UNITY_SETUP_INSTANCE_ID(v);
						UNITY_INITIALIZE_OUTPUT(v2f, o);
						UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
						o.viewOrigin = (unity_StereoWorldSpaceCameraPos[0] + unity_StereoWorldSpaceCameraPos[1]) / 2;
					#else
						o.viewOrigin = _WorldSpaceCameraPos.xyz;
					#endif

					o.worldViewDir	= normalize(mul(unity_ObjectToWorld, v.vertex).xyz - o.viewOrigin);
					o.distOrigin	= distance(o.viewOrigin, o.objOrigin);

					// get vector perpendicular to both view direction and view normal
					float3 viewCross = cross(o.viewDir, o.viewNorm);
					// swizzle perpendicular vector components to create a new perspective corrected view normal
					o.capUV = float2(-viewCross.y, viewCross.x) * 0.5 + 0.5;

					return o;
				}

				// ====================== FRAGMENT FUNCTION ======================

				half4 frag(v2f i) : SV_Target
				{
					
					const float3 RGBToIntensity = float3(0.2627, 0.678, 0.0593);

					// -------------------------------------

					float4 coords = UNITY_PROJ_COORD(i.grabPos);
					float4 col = tex2D(_GrabTexture_Transparent, coords.xy / coords.w);
					half colIntensity = dot(col.rgb, RGBToIntensity);

					#if defined(USING_STEREO_MATRICES)
						UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
						i.distOrigin *= 2;
					#endif

					// -------------------------------------

					switch (_ColorBlendMode) {
						case 0: // Multiply
							col *= _ColorToBlend;
							break;

						case 1: // Sum
							col += _ColorToBlend;
							break;

						case 2: // Hue Shift
							col.rgb = hueShift(col.rgb*_HueColorShift.rgb, _HueShift)*_ColorToBlend.rgb;
							col.a *= _ColorToBlend.a*_HueColorShift.a;
							break;

						case 3: // Gradient Texture
							if (_GradientToggleCol_Map) {
								col.rgb = tex2D(_GradientSampleTex, float2(colIntensity, 0));
							}else {
								col.rgb = lerp(_GradientColor1.rgb, _GradientColor2.rgb, colIntensity);
							}							
							col.a = _ColorToBlend.a;
							break;

						case 4: // Modulo
							col.rgb = col.rgb % _ModuloProportion;
							col.rgb /= _ModuloProportion;
							break;

						default:
							col *= _ColorToBlend; 
							break;
					}

					// -------------------------------------

					if (_InvertColors) { // Invert colors in regards to the intensity of the color blend
						col.rgb = dot(_ColorToBlend, RGBToIntensity) - col.rgb;
					}

					// -------------------------------------

					float3 lightColor;
					float3 lightPos;
					
					switch (_FakeLightMode) {
						case 0: // Real
							lightColor	= _LightColor0.rgb;
							lightPos	= _WorldSpaceLightPos0.xyz;
							break;
						case 1: // Point Light
							lightColor	= _PointLightColor.rgb * _FakeLightPointVector.w;
							lightPos	= _FakeLightPointVector.xyz;
							break;
					}
					float3 lightDir = normalize(lightPos - i.vertex);
					float3 viewDir = -i.worldViewDir;
					float attenuation = 1.0 / i.distOrigin;


					switch (_ShadingMode) {
						case 1: //matcap shading
							//https://forum.unity.com/threads/getting-normals-relative-to-camera-view.452631/#post-2933684

							col += tex2D(_MatcapSampleTex, i.capUV)/2;
							break;
						
						case 2: // Cube Map
							// implementation from https://en.wikibooks.org/wiki/Cg_Programming/Unity/Reflecting_Surfaces
							float3 reflectedDir = reflect(i.worldViewDir, normalize(i.normal));
							float4 cubeColor = texCUBE(_CubemapSampleTex, reflectedDir); // Project to textured sphere
							col += cubeColor/2;
							//col += cubeColor * pow(max(0.0, dot(reflect(_FakeLightPointVector.xyz, i.normalDir),i.viewDir)), 1);
							break;

						case 3: // Blinn Phong							
							float3 halfwayDir	= normalize(lightDir + viewDir);
							float lambertian	= max(dot(i.normal, halfwayDir), 0.0f);

							half3 ambient		= UNITY_LIGHTMODEL_AMBIENT * col.rgb * attenuation;
							half3 diffuse		= _Diffuse * attenuation * lambertian;
													// we only want to apply a specular when the diffuse is > 0
							half3 specular		= _Specular * attenuation * pow(max(dot(i.normal, halfwayDir), 0.0), _Gloss) * (lambertian > 0.0);
							
							col += float4(ambient + (diffuse * col.rgb + specular)* lightColor, 1.0)/2;
							break;
							
						case 4: // Goosh
							// https://github.com/GarrettGunnell/Gooch-Shading/blob/main/Assets/Gooch.shader

							float3 reflectionDir = reflect(-lightDir, i.normal);
							float3 specular2 = DotClamped(viewDir, reflectionDir);
							specular2 = pow(specular2, (1.005 - _Smoothness) * 500)*attenuation;

							float goochDiffuse = (1.0f + dot(lightDir, i.normal)) / 2.0f;

							float3 kCool = _Cool.rgb + _Alpha * col.rgb; // auto mixes color
							float3 kWarm = _Warm.rgb + _Beta * col.rgb;

							float3 gooch = (goochDiffuse * kWarm) + ((1 - goochDiffuse) * kCool);

							col.rgb = gooch + specular2;
							break;
					}


					return col;
				}
				ENDCG
			}
		}
}

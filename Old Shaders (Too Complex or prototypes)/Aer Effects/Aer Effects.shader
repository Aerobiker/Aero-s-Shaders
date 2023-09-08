Shader "AeroFunky/Aer Effects"
{
    Properties
    {
		[Header(Render Options)]
		[Space]
		[Enum(Off, 0, On, 1)]_ZWriteMode("ZWriteMode", float) = 1
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode", float) = 2
		[Enum(UnityEngine.Rendering.CompareFunction)]_ZTestMode("ZTestMode", Float) = 4


		[Space(5)]
		[Header(Texture Options)]
		[Space]
        [HDR] _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_BumpNormalMap("Normal Map", 2D) = "bump" {}
		_BumpHeight("Bump Height", Range(-2,2)) = 1
		_BumpModulation("Bump Modulation", Range(0,2)) = 1
		_DetailTex("Detail Texture (sum on Albedo)", 2D) = "gray" {}


		[Space(5)]
		[Header(Shading Options)]
		[Space]
		[Enum(Unlit, 0, Blinn Phong, 1)]_ShadingType("Shading Mode",float) = 0 
        _Diffuse("Diffuse Color", Color) = (1, 1, 1, 1)
		_Specular("Specular Color", Color) = (1, 1, 1, 1)
		[PowerSlider(3.0)]_Gloss("Gloss", Range(1.0, 256.0)) = 32.0
		

		[Space(5)]
		[Header(Alpha Clip Options)]
		[Space]
		[Enum(Alpha Clip, 0, Dithering, 1,Alpha Blend, 2)]_AlphaOption("Alpha Mode",float) = 0
		_AlphaThreshHold("Alpha Clip", Range(-0.01,1.1)) = 0.5

		[Space(2)]
		[Header(Alpha Disolve)]
		[Space]
		_AlphaClipDisolveTex("Disolve Mask", 2D) = "white" {}
		_AlphaClipDisolveDetailTex("Disolve Mask (BW)", 2D) = "white" {}
		_AlphaClipToOpaque("Disolve Progression",Range(-0.01,1.1)) = 0
		_AlphaDisolveDetailRange("Disolve Detail Range (relative)",Range(0,50)) = 0
		[HDR] _AlphaClipDitterColor("Disolve Color", Color) = (1,1,1,1)

		[Space(2)]
		[Header(Dithering Options)]
		[Space]
		_DitherPattern("Dither Pattern", 2D) = "white" {}
		_DitherPower("Dither Power",Range(0,10)) = 0
		_DitherDisolvePower("Dither Disolve Power",float) = 10
		[Toggle]_DistanceFade("Toggle distance Fade",float) = 0
		_DistanceFadeParam("Distance Fade Min/Max/Step_Speed/-",Vector) = (10,100,1,0)


		[Space(5)]
		[Header(Matcap)]
		[Space]
		[Toggle]_UseMatcap("Toggle Matcap", float) = 0
		[Enum(Use Default, 0, Custom(Map), 1)]_MatcapNormalMode("Matcap Select Normals", float) = 0
		[Enum(Multiply, 0, Sum, 1, None, 2)]_MatcapMixMode("Matcap Select color blending mode", float) = 2
		_MatcapTex("Matcap (RGB)", 2D) = "white" {}
		[HDR] _MatcapColor("Matcap Tint", Color) = (1,1,1,1)


		[Space(5)]
		[Header(Fresnel)]
		[Space]
		[Toggle]_UseFresnel("Toggle Fresnel", float) = 0
		[Enum(Use Default, 0, Custom (Map), 1)]_FresnelNormalMode("Fresnel Select Normals", float) = 1
		_FresnelThreshold("Fresnel Threshhold", float) = 1
		_FresnelPower("Fresnel Power", float) = 2
		[HDR] _FresnelColor("Fresnel Color", Color) = (1,1,1,1)
    }
    SubShader
		{
			Tags { "RenderType" = "Opaque" "LightMode" = "ForwardBase"  }
			LOD 100

			Pass{

				ZWrite[_ZWriteMode]
				ZTest[_ZTestMode] // Changing the layer display
				Cull[_CullMode]
				


				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"
				#include "Lighting.cginc"
				
				// ====================== DATA STRUCT ======================

				struct appdata
				{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					float2 uv : TEXCOORD0;
				};

				struct v2f
				{
					float4 pos : SV_POSITION;
					float4 scrPos : TEXCOORD0;
					float vertDistance : TEXCOORD4;
					float3 normal : NORMAL;
					float2 uv : TEXCOORD1;
					float3 viewDir: TEXCOORD2;
					float2 matcapUV : TEXCOORD3;

				};

				// ====================== DATA ======================

				// Simple Textures
				sampler2D _MainTex;
				float4 _MainTex_ST;
				float4 _Color;
				sampler2D _DetailTex;
				float4 _DetailTex_ST;

				//Normal
				sampler2D _BumpNormalMap;
				half _BumpHeight;
				half _BumpModulation;

				// -- Alpha Clip --
				half _AlphaOption;
				// Alpha clip
				half _AlphaClipToOpaque;
				half _AlphaThreshHold;
				sampler2D _AlphaClipDisolveTex;
				// Dittering
				sampler2D _DitherPattern;
				float4 _DitherPattern_TexelSize;
				float _DitherPower;
				float _DitherDisolvePower;
				fixed _DistanceFade;
				float4 _DistanceFadeParam;
				// Disolve effect
				half _AlphaDisolveDetailRange;
				sampler2D _AlphaClipDisolveDetailTex;
				float3 _AlphaClipDitterColor;

				//-- Shading selection
				half _ShadingType;
				// PBR
				half _Glossiness;
				half _Metallic;
				// Blinn Phong
				fixed4 _Diffuse;
				fixed4 _Specular;
				float _Gloss;


				// Matcap
				fixed _UseMatcap;
				fixed _MatcapNormalMode;
				fixed _MatcapMixMode;
				sampler2D _MatcapTex;
				float4 _MatcapColor;
				// Fresnel
				fixed _UseFresnel;
				fixed _FresnelNormalMode;
				float _FresnelPower;
				float _FresnelThreshold;
				float4 _FresnelColor;

				// ======================= AER FUNCTIONS ======================

				float AER_GetLuminosity(float4 Color) {
					// - Mask Luminance Calculation -  (HDR, UHDTV : ranges Y'_2020)
					return mul(Color, float3(0.2627, 0.678, 0.0593));
				}

				float AER_DitherAlpha(float4 ScreenPos,sampler2D DitherPattern, float4 DitherPattern_TexelSize) {
					float2 screenPos = ScreenPos.xy / ScreenPos.w;
					float2 ditherCoordinate = screenPos * _ScreenParams.xy * DitherPattern_TexelSize.xy;
					float ditherValue = tex2D(DitherPattern, ditherCoordinate).r;
					return ditherValue;
				}

				// ======================= VERTEX FUNCTION ======================
				v2f vert(appdata v)
				{
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.scrPos = ComputeScreenPos(o.pos);
					o.uv = TRANSFORM_TEX(v.uv, _MainTex);
					o.normal = UnityObjectToWorldNormal(v.normal); // o.uv_bump = TRANSFORM_TEX(v.texcoord,_BumpMap);
					float4 worldVertex = mul(unity_ObjectToWorld, v.vertex);
					o.viewDir = normalize(_WorldSpaceCameraPos.xyz - worldVertex);
					o.vertDistance = distance(worldVertex, _WorldSpaceCameraPos);
					float3 originPos = mul(unity_ObjectToWorld, float4(0.0, 0.0, 0.0, 1.0));
					float3 originViewDir = normalize(_WorldSpaceCameraPos.xyz - originPos);

					// ---- Matcap ----
					fixed3 matcapNormal = o.normal;
					//if (_MatcapNormalMode) { matcapNormal = o.customNormal; }     	
					half3 worldViewRight = -normalize(float3(o.viewDir.z, 0, -o.viewDir.x)); // Rotate the view direction on the y axis, and ignore the y component  to have a perpendicular line and parallel to the camera.
					half3 worldViewUp = normalize(cross(worldViewRight, o.viewDir)); // get the oriented vertical (y) vector of the camera (Theory is : ignore yaw component of camera, so we can re assemble the functions)
					o.matcapUV = half2(dot(worldViewRight, o.normal), dot(worldViewUp, o.normal)) * 0.49 + 0.5; // Compare the world normals to the rotation vector of the camera

					// Useful matrix transofrsm : https://forum.unity.com/threads/get-just-the-objects-rotation-matrix-in-shader-without-view-or-projection-included.440863/
					return o;
				}



				// ======================= FRAGMENT FUNCTION ======================
				fixed4 frag(v2f i) : SV_Target
				{
					// ---- Texturing ----
					// - Albedo -
					fixed4 col = tex2D(_MainTex, i.uv) * _Color;

					// - Normals -
					float3 customNormal = UnpackNormal(tex2D(_BumpNormalMap, i.uv)*_BumpModulation);

					// - Detail Map -
					col.rgb *= tex2D(_DetailTex, i.uv).rgb * 3;

					// ---- Alpha ----
					float PixelLuminance_DisolveDetail = AER_GetLuminosity(tex2D(_AlphaClipDisolveDetailTex, i.uv));
					float PixelLuminance_DisolveMask = AER_GetLuminosity(tex2D(_AlphaClipDisolveTex, i.uv));
					float ditherVal = AER_DitherAlpha(i.scrPos, _DitherPattern, _DitherPattern_TexelSize);

					switch (_AlphaOption) {
						case 0 : // Alpha clip
							// - Clipping -
							if ((PixelLuminance_DisolveMask < (_AlphaClipToOpaque)) | col.a <= _AlphaThreshHold) {discard;}     //clip(frac((i.worldPos.y + i.worldPos.z*0.1) * 5) - 0.5);

							// - Disolve -
							if (PixelLuminance_DisolveDetail + PixelLuminance_DisolveMask < _AlphaClipToOpaque + _AlphaDisolveDetailRange * _AlphaClipToOpaque) {
								col.rgb = (1 - PixelLuminance_DisolveDetail) * 4 * _AlphaClipDitterColor;
							}
							break;

						case 1 : // Dithering
							clip(col.a*_DitherPower - (_AlphaClipToOpaque+0.01)*PixelLuminance_DisolveMask*_DitherDisolvePower*_DitherPower - ditherVal);

							if (PixelLuminance_DisolveDetail + PixelLuminance_DisolveMask < _AlphaClipToOpaque + _AlphaDisolveDetailRange * _AlphaClipToOpaque) {
								col.rgb = (1 - PixelLuminance_DisolveDetail) * 4 * _AlphaClipDitterColor;
							}
							break;

						default : // None
							break;
					}

					if (_DistanceFade) {
						float DitherStep = smoothstep(_DistanceFadeParam[0], _DistanceFadeParam[1] * _DistanceFadeParam[2], i.vertDistance*_DistanceFadeParam[2]);
						clip( ditherVal - DitherStep);
					}

					
					// ---- Shading ----
					
					switch (_ShadingType) {
						case 1:
							// - Lighting - 
							fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;
							fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.pos));
							// Diffuse
							fixed3 lightDir = UnityWorldSpaceLightDir(i.pos);
							fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(customNormal, lightDir));
							// Blinn-Phong (mid normal)
							fixed3 halfDir = normalize(lightDir + viewDir);
							// Gloss
							fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(customNormal, halfDir)), _Gloss);

							// Final Fuse
							col *= fixed4(ambient + diffuse + specular, 1);
							break;
						default:
							break;
					};


					// ---- Matcap ----
					if (_UseMatcap) {
						float3 matcap = tex2D(_MatcapTex, i.matcapUV).xyz*_MatcapColor;

						switch (_MatcapMixMode) {
							case 0:
								col.xyz *= matcap;
							break;
							case 1:
								col.xyz += matcap;
							break;
							case 2:
								col.xyz = matcap;
							break;
							default:
								col.xyz = matcap;
							break;
						};
					}


					// ---- Fresnel ----
					if (_UseFresnel) {
						// - Normal Select -
						fixed3 fresnelNormal = i.normal;
						if (_FresnelNormalMode) { fresnelNormal = customNormal; }

						// - Fresnel Effect -
						float isFresnel = 1- mul(i.viewDir, fresnelNormal);
						col += pow(isFresnel*_FresnelThreshold, _FresnelPower)* _FresnelColor;
						
					}

					return col;
					
				}
				ENDCG
		}
		
	}
    FallBack "Diffuse"
}

// Sources:
// https://github.com/csdjk/LearnUnityShader
// https://github.com/csdjk/LearnUnityShader/blob/master/Assets/Scenes/ShaderGUI/ShaderGUI_Built-in.shader
// https://docs.unity3d.com/Manual/SL-SurfaceShaderExamples.html
// https://en.wikipedia.org/wiki/HSL_and_HSV

// https://www.rastertek.com/tertut15.html
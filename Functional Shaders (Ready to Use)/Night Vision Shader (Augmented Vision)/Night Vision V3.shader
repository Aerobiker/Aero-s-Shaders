Shader "AeroFunky/Night Vision V3"
{
    Properties
    {

        [Space(10)][Header(#### ( Night Vision Settings ) ####)][Space(10)]
        [Enum(None, 0, Luminosity Correction (tint), 1, BW black compensation (tint), 2, Raw Luminosity(For Color Palettes), 3, Depth, 4)] _Effect_Equation("Nightvision Type", int) = 1
        _Color("Vision Tint", Color) = (1,1,1,1)
        _DepthPeriod("Depth Period (far plane units before repetition)", float) = 5
        [Toggle]_DepthMultiplyColor("Depth & Vision Mix (multiplication, works with all visions)", int) = 0

        
        [Space(16)][Header(#### (Custom Gradient Settings) ####)][Space(10)]
        [Enum(None, 0, JET, 1, HSV (fac 2), 2, Modulo (fac 1 2), 3, Image, 4)] _Color_Palette("Color Palette Selection", int) = 0
        _Gradient_factor_1("Gradient Factor 1", Range(0,1)) = 0.01
        _Gradient_factor_2("Gradient Factor 2", Range(0,10)) = 10
        _GradientTex("Gradient Texture (1D, horizontal)", 2D) = "white" {}

        // Viridis, Inferno, Plasma, MPL_gist_ncar
        // https://www.ncl.ucar.edu/Document/Graphics/ColorTables/MPL_gist_ncar.shtml

        [Space(16)][Header(#### (Zoom Settings) ####)][Space(10)]
        [Enum(Uniform, 0, UV Gaussian, 1, Fresnel, 2)]_ZoomMode("Zoom Mode", int) = 0
        _ZoomFactor("Zoom Factor", Range(-10,10)) = 0
        [Toggle]_ZoomOverlay("Zoom After Overlay", int) = 0
        

        [Space(16)][Header(#### (Overlay Settings) ####)][Space(10)]
        [Enum(Off, 0, Screen Space, 1, Mesh UV, 2)]_OverlayMode("Overlay Option Selection", int) = 0
        [Enum(Multiply, 0, Addition, 1, Dodge, 2, Overlay, 3, Mean, 4, Power, 5)]_OverlayColorMix("Overlay Tint Mode", int) = 0
        [HDR]_OverlayColor("Overlay Tint (no alpha)", Color) = (1,1,1,1)
        _OverlayAlphaOveride("Overlay Alpha Overide", Range(0,1)) = 1
        _OverlayTex("Overlay Texture (2D, scalable)", 2D) = "white" {}
        
        [Space(16)][Header(#### (Post Processing Settings) ####)][Space(10)]
        [HDR]_FinalTint("Final Tint (multiply)", Color) = (1,1,1,1)

        //[Toggle]_PostChromaticAbberationToggle("Chromatic Abberation Toggle", int) = 0
        //[Enum(Before Overlay, 0, After Overlay, 1, After Post Processing, 2)]_PostChromaticAbberationRange("Chromatic Abberation Effect Stack", int) = 0
        //_PostChromaticAbberationVector("Chromatic Abberation Vector Deform (2D)", Vector) = (0,0,0,0)

        [Space(30)][Header(#### (Graphic Settings) ####)][Space(10)]
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode", float) = 2
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTestMode("ZTestMode", Float) = 4
        [Enum(Off, 0, On, 1)]_ZWriteMode("ZWriteMode", float) = 1
        [Enum(UnityEngine.Rendering.ColorWriteMask)]_ColorMask("ColorMask", Float) = 15
        [Space(8)]
        [Enum(UnityEngine.Rendering.BlendOp)]  _BlendOp("BlendOp", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("SrcBlend", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("DstBlend", Float) = 10
    }
    SubShader
    {
        Tags{
            "Queue" = "Overlay"
            "RenderType" = "Opaque"
            "DisableBatching" = "True"
        }
        LOD 100

        GrabPass {
            "_GrabTexture"
        }

        Pass
        {
            BlendOp[_BlendOp]
            Blend[_SrcBlend][_DstBlend] // Blend SrcAlpha OneMinusSrcAlpha
            ZWrite[_ZWriteMode]
            ZTest[_ZTestMode]
            Cull[_CullMode]
            ColorMask[_ColorMask]

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
            sampler2D _GrabTexture, _GradientTex, _OverlayTex;
            float4 _GrabTexture_ST, _GradientTex_ST, _OverlayTex_ST;
            float4 _Color, _OverlayColor, _FinalTint;
            float _Gradient_factor_1, _Gradient_factor_2, _ZoomFactor, _OverlayAlphaOveride, _DepthPeriod;
            int _Effect_Equation, _Color_Palette, _ZoomMode, _OverlayColorMix, _OverlayMode, _ZoomOverlay, _DepthMultiplyColor;

            float luminance(float3 color) {
                return dot(color, float3(0.299f, 0.587f, 0.114f));
            }

            float3 hue2rgb(float3 hue) {
                hue = frac(hue); //only use fractional part of hue, making it loop
                return saturate(float3(0, 2, 2) + float3(1, -1, -1) * abs(hue * 6 - float3(3, 2, 4)));
            }

            float sawtoothFunction(float t, float period) {
                return 2 * abs(t / period - floor(t / period + 0.5f));
            }

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID // VR INSTANCING SUPPORT
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 vertex2 : TEXCOORD1;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 grabPos : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO // VR INSTANCING SUPPORT
            };

            v2f vert (appdata v)
            {
                v2f o;

                // VR INSTANCING SUPPORT
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                // CLASSIC VERTEX STUFF
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.vertex2 = v.vertex;
                o.uv = v.uv - 0.5f;
                o.normal = v.normal;
                o.grabPos = ComputeGrabScreenPos(o.vertex);
                return o;
            }

            sampler2D _MainTex;

            fixed4 frag (v2f i) : SV_Target
            {
                // VR INSTANCING SUPPORT
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                // ZOOM

                float zoomFac;
                switch (_ZoomMode) {
                    default: zoomFac = _ZoomFactor; break;
                    case 1: float beta = 4 / (dot(i.uv, i.uv) + 1) - 2; zoomFac = pow(beta, _ZoomFactor) - 1; break;
                    case 2: zoomFac = pow(saturate(dot(i.normal, ObjSpaceViewDir(i.vertex2))),_ZoomFactor/10) - 1; break;
                }
                float4 grabPos = ComputeGrabScreenPos(UnityObjectToClipPos(i.vertex2) + float4(0,0,0,zoomFac));

                // SCREEN  GRAB

                float4 coords = UNITY_PROJ_COORD(grabPos);
                float4 col = tex2D(_GrabTexture, coords.xy / coords.w);
                float luminosity = luminance(col.rgb);

                // NV EQUATION

                float4 final_color;
                switch (_Effect_Equation) {
                    case 1: // Luminosity Correction
                        final_color = pow(col, (1 - float4(0.299f, 0.587f, 0.114f, 1.0f)))*_Color;
                        break;
                    case 2: // BW Black Correction
                        final_color = pow(luminosity, luminosity) * _Color;
                        break;
                    case 3: // Raw Luminosity
                        final_color = luminosity;
                        break;
                    case 4: // Depth Based
                        final_color = sawtoothFunction(Linear01Depth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, coords.xy / coords.w))* _ProjectionParams.z,_DepthPeriod);
                        break;
                    default: // None
                        final_color = col;
                        break;
                };

                if (_DepthMultiplyColor) { final_color *= col; }

                // GRADIENT

                switch (_Color_Palette) {
                    case 1: // JET
                        final_color = saturate(float4(1.5f, 1.5f, 1.5f, 10) - abs(4 * final_color + float4(-3, -2, -1, 0)));
                        break;
                    case 2: // HSV
                        final_color.rgb = hue2rgb(final_color * _Gradient_factor_2);
                        break;
                    case 3: // Modulo
                        final_color = (final_color % _Gradient_factor_1) * _Gradient_factor_2;
                        break;
                    case 4: // Image
                        final_color = tex2D(_GradientTex, float2(frac(length(final_color)/ 1.73205f), 0.5f));
                        break;
                    default: // NONE
                        break;
                }

                // OVERLAY

                float4 overlayColor; 
                float overlayZoom = _ZoomOverlay ? 1 / (1 + zoomFac) : 1;
                float4 overlayCoords = _ZoomOverlay ? coords : UNITY_PROJ_COORD(i.grabPos);
                #if defined(USING_STEREO_MATRICES) // VR Overlay Size Correction
                    overlayCoords.x *= 2;
                    overlayCoords.xy *= 2;
                #endif
                switch (_OverlayMode) {
                    default: overlayColor = 0; break;
                    case 1: overlayColor = tex2D(_OverlayTex, (overlayCoords.xy / overlayCoords.w) * _OverlayTex_ST.xy * float2(_ScreenParams.x/_ScreenParams.y, 1) + _OverlayTex_ST.zw); break;
                    case 2: overlayColor = tex2D(_OverlayTex, (i.uv*overlayZoom + 0.5f) * _OverlayTex_ST.xy + _OverlayTex_ST.zw); break;
                }

                switch (_OverlayColorMix) {
                    default: overlayColor *= _OverlayColor;  break; // Mult
                    case 1: overlayColor += _OverlayColor;  break; // Add
                    case 2: overlayColor = _OverlayColor / (1.0f - overlayColor);  break; // Dodge
                    case 3: overlayColor = (overlayColor <= 0.5) ? 2 * overlayColor * _OverlayColor : 1 - 2 * (1 - overlayColor) * (1 - _OverlayColor); break; // Overlay
                    case 4: overlayColor = (_OverlayColor + overlayColor) / 2; break; // Mean
                    case 5: overlayColor = saturate(pow(overlayColor, _OverlayColor)); break; // Power
                }

                overlayColor.w = 0;
                final_color.w = 1;
                return (final_color + overlayColor * _OverlayAlphaOveride)* float4(_FinalTint.rgb, 1);
            }
            ENDCG
        }
    }
}

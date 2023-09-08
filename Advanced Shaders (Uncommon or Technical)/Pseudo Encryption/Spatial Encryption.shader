Shader "AeroFunky/Spatial Encryption (sender)"
{
    Properties
    {
        [Header(Base Settings)]
        [Space(10)]
        [Toggle] _Shield("Activate shield (avoid pissing off players)", int) = 1
        _Range("Shield Range (from object origin)", float) = 1

        [Space(15)]
        [Header(Shading Settings)]
        [Space(10)]
        [Enum(Off, 0, Realistic, 1, Goosh, 2)]_ShadingMode("Shading Mode", int) = 1
        _ShieldBaseColor("Base Color", Color) = (.3, .05, .2, 1)

        [Space(20)]
        [PowerSlider(4)]_Specular("Specular Factor", Range(1, 500)) = 3
        [PowerSlider(4)]_SpecularPower("Specular Power", Range(0, 100)) = 10
        _DiffuseColor("Diffuse Color", Color) = (.3, .05, .2, 0)
        _SpecularColor("Specular Color", Color) = (1, 1, 1, 0)

        [Space(20)]
        _GooshCoolColor("Goosh Cool Color", Color) = (.3, .25, .5, 0)
        _GooshWarmColor("Goosh Warm Color", Color) = (.5, .05, .2, 0)
        _GooshAlpha("Goosh Alpha", Range(0,1)) = .5
        _GooshBeta("Goosh Beta", Range(0,1)) = .1
        [PowerSlider(2)]_GooshSpecular("Goosh Specular", Range(1, 100)) = 2
        _GooshSpecularPower("Goosh Specular Power", Range(0, 10)) = 0.55
            
        [Space(25)]
        [Header(Encryption Keys)]
        [Space(10)]
        [IntRange]_KeySelector("Key Selector", Range(0,20)) = 0
        [Space(10)]
        _PublicKey(">>  Public Key '10398724' (Default)", int) = 10398724
        _key1(">>  Key 1 (int 32)", int) = 0
        _key2(">>  Key 2 (int 32)", int) = 0
        _key3(">>  Key 3 (int 32)", int) = 0
        _key4(">>  Key 4 (int 32)", int) = 0
        _key5(">>  Key 5 (int 32)", int) = 0
        _key6(">>  Key 6 (int 32)", int) = 0
        _key7(">>  Key 7 (int 32)", int) = 0
        _key8(">>  Key 8 (int 32)", int) = 0
        _key9(">>  Key 9 (int 32)", int) = 0
        _key10(">>  Key 10 (int 32)", int) = 0
        _key11(">>  Key 11 (int 32)", int) = 0
        _key12(">>  Key 12 (int 32)", int) = 0
        _key13(">>  Key 13 (int 32)", int) = 0
        _key14(">>  Key 14 (int 32)", int) = 0
        _key15(">>  Key 15 (int 32)", int) = 0
        _key16(">>  Key 16 (int 32)", int) = 0
        _key17(">>  Key 17 (int 32)", int) = 0
        _key18(">>  Key 18 (int 32)", int) = 0
        _key19(">>  Key 19 (int 32)", int) = 0
        _key20(">>  Key 20 (int 32)", int) = 0
    }

    SubShader
    {
        Tags {  "RenderType" = "Opaque"
                "Queue" = "Transparent+10"
                "LightMode" = "Always"
                "ForceNoShadowCasting" = "True"
                "IgnoreProjector" = "True"
            }

        GrabPass { // Fix the Queue issue with other shaders (not optimal, but a bit better)
            "_GrabTexture_Transparent"
        }

        Pass
        {
            Tags {
                "RenderType" = "Opaque"
                "Queue" = "Opaque"
                "LightMode" = "Always"
            }
            ZTest LEqual
            ZWrite On
            Cull Back
            Fog{ Mode Off}

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            half4 _ShieldBaseColor;
            half4 _GooshCoolColor , _GooshWarmColor;
            half4 _DiffuseColor   , _SpecularColor ;
            half  _GooshAlpha     , _GooshBeta     , _GooshSpecular , _GooshSpecularPower; 
            half  _Specular       , _SpecularPower ;
            int   _ShadingMode    , _Shield        ;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex       : SV_POSITION;
                float3 viewOrigin	: TEXCOORD1;
                float3 worldViewDir	: TEXCOORD2; 
                float worldViewDist : TEXCOORD3;
                float3 normal       : TEXCOORD4;
                float wPos          : TEXCOORD5;
                UNITY_VERTEX_OUTPUT_STEREO

            };

            v2f vert(appdata v)
            {
                v2f o;
                #if defined(USING_STEREO_MATRICES)
                    UNITY_SETUP_INSTANCE_ID(v);
                    UNITY_INITIALIZE_OUTPUT(v2f, o);
                    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                    o.viewOrigin = (unity_StereoWorldSpaceCameraPos[0] + unity_StereoWorldSpaceCameraPos[1]) / 2;
                #else
                    o.viewOrigin = _WorldSpaceCameraPos.xyz;
                #endif

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.wPos   = mul(unity_ObjectToWorld, v.vertex);

                o.worldViewDist =  distance(o.viewOrigin , mul(unity_ObjectToWorld, v.vertex).xyz);
                o.worldViewDir  = normalize(o.viewOrigin - mul(unity_ObjectToWorld, v.vertex).xyz);
                
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                if (_Shield == 0) { discard; }
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                
                float3 L    = normalize(_WorldSpaceLightPos0.xyz);
                float3 V    = i.worldViewDir;
                float3 HR   = normalize(L + V);

                //float AT  = i.worldViewDist;
                float3 N    = normalize(i.normal);
                float  LAMB = (1.0f + dot(L, N)) * 0.5f;


                switch(_ShadingMode) {
                    case 1 : // Blinn - Phong model
                        float3 diffuseBlinnPhong  = LAMB * _LightColor0.rgb * _DiffuseColor.rgb;
                        float3 specularBlinnPhong = pow(DotClamped(HR, N), _Specular) * _SpecularColor.rgb * _SpecularPower * 0.05f;

                        return float4(diffuseBlinnPhong + specularBlinnPhong + _ShieldBaseColor.rgb, 1);

                    case 2: // Goosh
                        float3 specularGoosh = pow( DotClamped(V, reflect(-L, N)), _GooshSpecular) * _GooshSpecularPower;

                        float3 kCool = _GooshCoolColor + _GooshAlpha * _ShieldBaseColor;
                        float3 kWarm = _GooshWarmColor + _GooshBeta  * _ShieldBaseColor;

                        float3 gooch = (LAMB * kWarm) + ((1 - LAMB) * kCool);

                        return half4(gooch + specularGoosh, 1);

                    default: // None or Off
                        return _ShieldBaseColor;
                }
            }
            ENDCG
        }

        Pass
        {
            Name "CSA_Encryption_AeroFunky"
            ZTest NotEqual
            ZWrite On
            Cull Front
            Fog{ Mode Off}

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex   : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                float3 camPos   : TEXCOORD1;
                float3 objOrigin: TEXCOORD2;    
                float  objDist  : TEXCOORD3;       
                float  wObjDist : TEXCOORD4;       
                UNITY_VERTEX_OUTPUT_STEREO

            };

            float _Range;
            sampler2D _GrabTexture_Transparent;
            float4 _GrabTexture_Transparent_TexelSize;
            
            int _KeySelector, _Shield;
            int _key1 , _key2 , _key3 , _key4 , _key5 , _key6 , _key7 , _key8 , _key9 , _key10;
            int _key11, _key12, _key13, _key14, _key15, _key16, _key17, _key18, _key19, _key20;

            // -----------------------------------------------------------

            //https://www.reedbeta.com/blog/quick-and-easy-gpu-random-numbers-in-d3d11/
            uint wang_hash(uint seed) // can hash one 32-bit integer into another
            {
                seed = (seed ^ 61) ^ (seed >> 16);
                seed *= 9;
                seed = seed ^ (seed >> 4);
                seed *= 0x27d4eb2d;
                seed = seed ^ (seed >> 15);
                return seed;
            }

            float CSA(float bit_stream, int key) { // xor based encryption algorithm
                int bit_stream_int = round(bit_stream * 2147483648);
                int rng    = wang_hash(key);
                int cipher = bit_stream_int ^ (key + rng);
                return float(cipher) / 2147483648.0f;

            }

            // -----------------------------------------------------------
            v2f vert(appdata v)
            {  
                v2f o;
                #if defined(USING_STEREO_MATRICES)
                    UNITY_SETUP_INSTANCE_ID(v);
                    UNITY_INITIALIZE_OUTPUT(v2f, o);
                    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                    o.camPos = (unity_StereoWorldSpaceCameraPos[0] + unity_StereoWorldSpaceCameraPos[1]) / 2;
                #else
                    o.camPos = _WorldSpaceCameraPos.xyz;
                #endif

                o.vertex    = UnityObjectToClipPos(v.vertex);

                o.objOrigin = mul(unity_ObjectToWorld, float4(0,0,0, 1.0));
                o.objDist   = distance(o.camPos, mul(unity_ObjectToWorld, v.vertex).xyz);
                o.wObjDist  = distance(o.camPos, o.objOrigin);

                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                if (i.wObjDist > _Range && _Shield == 1) { discard; }

                int seed = 10398724; // _PublicKey
                switch (_KeySelector) {
                    case 1: seed  = _key1; break;
                    case 2: seed  = _key2; break;
                    case 3: seed  = _key3; break;
                    case 4: seed  = _key4; break;
                    case 5: seed  = _key5; break;
                    case 6: seed  = _key6; break;
                    case 7: seed  = _key7; break;
                    case 8: seed  = _key8; break;
                    case 9: seed  = _key9; break;
                    case 10: seed = _key10; break;
                    case 11: seed = _key11; break;
                    case 12: seed = _key12; break;
                    case 13: seed = _key13; break;
                    case 14: seed = _key14; break;
                    case 15: seed = _key15; break;
                    case 16: seed = _key16; break;
                    case 17: seed = _key17; break;
                    case 18: seed = _key18; break;
                    case 19: seed = _key19; break;
                    case 20: seed = _key20; break;
                }

                int2 shift = i.vertex.xy;
                float4 col = tex2D(_GrabTexture_Transparent, (float2(shift) + 0.5f) / float2(_GrabTexture_Transparent_TexelSize.zw));

                // Key generation
                seed += round(_Time[3]) * (wang_hash(seed) >> 20) * 17;
                int key = seed + shift.x + 189 * shift.y;
                int offset = 97 * (wang_hash(seed + 19) >> 20);

                // First Layer (encryption)
                col.r = CSA(col.r, key);
                col.g = CSA(col.g, key);
                col.b = CSA(col.b, key);

                // Second Layer (encryption)
                col.r = CSA(col.r, offset + key);
                col.g = CSA(col.g, offset + key);
                col.b = CSA(col.b, offset + key);

                return  float4(col.rgb, 1);
            }
            ENDCG
        }
    } 
}

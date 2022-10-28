Shader "AeroFunky/Super Emitter V2.1"
{
    Properties
    {
		[Header(Render Options)]
		[Space]
		[Enum(UnityEngine.Rendering.CompareFunction)]_ZTestMode("ZTestMode", float) = 4
		
		[Space(4)]
		[Header(Texture Options)]
		[Space]
		[Enum(Color,0,Black and white (no alpha), 1, Color (no alpha),2)]_TextureMode("Texture mixing mode", int) = 0
		[HDR]_Color("Color shift", Color) = (1,1,1,1)
		_MainTex("Texture", 2D) = "white" {}
		_Scale("Size of the image XY", float) = 1

		[Space(4)]
		[Header(Additional Options)]
		[Space]
		_SpaceOffset("Offsets the position of the sprite XYZ*", Vector) = (0,0,0,0)
		_DistanceFadeMax("Distance of the de render, to avoid making long distance stuff",float) = 100

    }
    SubShader
    {
		Tags { "RenderType" = "Overlay" "Queue" = "Overlay" }
		LOD 100

        Pass
        {
			Lighting Off
			ZTest[_ZTestMode]
			Blend SrcAlpha OneMinusSrcAlpha
			

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;
			float _Scale;
			float4 _SpaceOffset;
			float _DistanceFadeMax;
			fixed _TextureMode;

            struct appdata
            {
				float4 vertex : POSITION;
            };

            struct v2f
            {
				float4 pos : SV_POSITION;
				float4 scrPos : TEXCOORD0;
				float distanceOrigin : TEXCOORD1;
            };


            v2f vert (appdata v)
            {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.scrPos = ComputeScreenPos(o.pos);

				#if defined(USING_STEREO_MATRICES)
				float3 PlayerCenterCamera = (unity_StereoWorldSpaceCameraPos[0] + unity_StereoWorldSpaceCameraPos[1]) / 2;
				#else
				float3 PlayerCenterCamera = _WorldSpaceCameraPos.xyz;
				#endif

				float4 objectOrigin = mul(unity_ObjectToWorld, float4(_SpaceOffset.xyz, 1.0));
				o.distanceOrigin = distance(objectOrigin, PlayerCenterCamera);
				//float3 worldView = normalize(lerp(_WorldSpaceCameraPos.xyz - i.posWorld.xyz, UNITY_MATRIX_V[2].xyz, unity_OrthoParams.w));

				return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				
				// sample the texture
				if (i.distanceOrigin > _DistanceFadeMax) {
					discard;
				}
				
				float4 ObjectToScreen = ComputeScreenPos(UnityObjectToClipPos(_SpaceOffset.xyz)); // Gets the screen coordinate of the origin and its position in the clip map
				float aspect = _ScreenParams.x / _ScreenParams.y;
				float2 objectUV = -(ObjectToScreen.xy / ObjectToScreen.w) + (i.scrPos.xy / i.scrPos.w); // corrects the position of the UV's (but gets stretched when geometry changes for some reason.
				objectUV *= i.distanceOrigin / _Scale;
				objectUV.x *= aspect;

				#if defined(USING_STEREO_MATRICES)
				objectUV.x *= 2;
				#endif


				fixed4 col = tex2D(_MainTex, TRANSFORM_TEX(objectUV, _MainTex)); //tex2D(_MainTex, i.uv) But i pre transform the uv's first
				switch (_TextureMode) {
					case 1:
						col.a = col.rgb;
						break;
					case 2:
						if (max(max(col.r,col.g),col.b) < 0.2) {
							col.a = col.rgb;
						}
						break;
					}
				
                return col*_Color;
            }
            ENDCG
        }
    }
}

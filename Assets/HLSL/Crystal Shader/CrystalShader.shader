/// this shader was done during te OCEs with Elias for feedback and support


Shader "Unlit/CrystalShader"
{
    Properties {
        _CrystalTopColor ("Crystal Top Color", Color) = (1,1,1,1)
        _CrystalBottomColor ("Crystal Bottom Color", Color) = (1,1,1,1)

        _movement("Movement Amplitude", vector) = (0,0,0,1) 
        _moveSpeed("Move Speed", float) = 1

        [NoScaleOffset]_noiseMap("Noise Texture", 2D) = "bump"{}
        _noiseColor("Noise Color", Color) = (1,1,1,1)
        _noiseColor2("Noise color 2", Color) = (1,1,1,1)
    }
    SubShader {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 normal : NORMAL;
            };

            // Vertex To Fragment Shader Stage Data Struct
            struct v2f {
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
                fixed2 uv  : TEXCOORD0;
            };

            // Variables
            float4 _CrystalTopColor;
            float4 _CrystalBottomColor;
            
            float3 _movement;
            float _moveSpeed;

            sampler2D _noiseMap;
            float4 _noiseColor;
            float4 _noiseColor2;

            // I am the Vertex Shader Stage
            v2f vert (appdata v) {
                v2f o;
                //o.uv = TRANSFORM_TEX(v.uv, _noiseMap); // v.uv + Translation * Scale
                o.uv = v.uv;
                float3 timeMovement = _movement * sin(_Time.y * _moveSpeed);
                o.vertex = UnityObjectToClipPos(v.vertex + timeMovement);
                
                
                return o;
            }

            // I am the Fragment Shader Stage
            fixed4 frag (v2f i) : SV_Target {

                float noise1 = tex2D(_noiseMap, i.uv * _Time.y);
                float noise2 = tex2D(_noiseMap, i.uv * _Time.y * 0.25f);
    
                float3 topColor = lerp(_CrystalTopColor.xyz, _noiseColor.xyz, noise1);
                float3 topColor2 = lerp(_CrystalTopColor.xyz, _noiseColor2.xyz, noise2);


                float4 fullTopColor = float4(((topColor + topColor2)/2),_CrystalTopColor.a);
                fixed4 col = lerp(_CrystalBottomColor, fullTopColor, i.uv.y);
                
                //return float4(i.uv.yyy,1);
                //return float4(noise2.xxx,1);
                
                return col;
            }
            ENDCG
        }
    }
}

Shader "Unlit/NewUnlitShader"
{
    Properties
    {
    
        _Tex1 ("Texture 1", 2D) = "white" {}
        _Tex1Color ("Texture 1 Color", Color) = (1,1,1,1)
        _Tex2 ("Texture", 2D) = "white" {}
        _Tex2Color ("Texture 1 Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 view : TEXCOORD1;
            };

            sampler2D _Tex1;
            float4 _Tex1Color;
            sampler2D _Tex2;
            float4 _Tex2Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv = v.uv;
                o.view = normalize(_WorldSpaceCameraPos - mul(float4(v.vertex.xyz, 0.0f), UNITY_MATRIX_MVP).xyz);;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col1 = tex2D(_Tex1, i.uv) * _Tex1Color;
                fixed4 col2 = tex2D(_Tex2, i.uv) * _Tex2Color;
                //Blend between the two

                //I liked the effect giving it the viewport colors gave so I added it to this to make it fancier
                fixed4 col = lerp(col1, col2, i.uv.y) + float4(i.view, 1.0f);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}

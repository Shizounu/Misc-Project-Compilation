//Translated from lessons with Hacki

Shader "Unlit/BlinnPhongShader"
{
    Properties
    {
        _MainColor ("Color", Color) = (0,0,0,1)
        
        _LightPosition ("Light Position", vector) = (0,0,0,1)
        _LightAmbient ("Ambient Color", Color) = (0,0,0,1)
        _LightDiffuse ("Diffuse Color", Color) = (0,0,0,1)
        _LightSpecular ("Specular Color", Color) = (0,0,0,1)
        _LightEmission ("Emission Color", Color) = (0,0,0,1)
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
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float3 view : TEXCOORD1;
            };

            //Variables
            float4 _MainColor;

            float3 _LightPosition;

            float4 _LightAmbient;
            float4 _LightDiffuse;
            float4 _LightEmission;
            float4 _LightSpecular;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = normalize(mul(v.normal, (float3x3)unity_ObjectToWorld));
                o.uv = v.uv;
                o.view = normalize(_WorldSpaceCameraPos - mul(float4(v.vertex.xyz, 0.0f), UNITY_MATRIX_MVP).xyz);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 textureColor = _MainColor;
	            float4 ambientColor = _LightAmbient;
	            float4 diffuseColor = 0.0f;
	            float4 specularColor = 0.0f;
	            float4 emissionColor = _LightEmission;
                
                // light data
	            float3 normalVector = normalize(i.normal);
	            float3 lightVector = normalize(-_LightPosition); // directional light vector
	            float3 reflectVector = normalize(reflect(-lightVector, normalVector));
	            float3 viewVector = normalize(i.view);
                
                // diffuse color - Lambert Lighting
	            float diffuseIntensity = max(dot(normalVector, lightVector), 0.0f);
	            diffuseColor = _LightDiffuse * diffuseIntensity;

	            // specular color - Phong Lighting
	            float specularIntensity = pow(max(dot(reflectVector, viewVector), 0.0f), 512.0f); // Phong exponent
	            specularColor = _LightSpecular * specularIntensity;

	            // texture * (ambient + diffuse) + specular + emission
	            return saturate(textureColor * saturate(ambientColor + diffuseColor) + specularColor + emissionColor);
            }
            ENDCG
        }
    }
}

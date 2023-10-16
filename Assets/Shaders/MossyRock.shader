Shader "Custom/MossyRock"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" }

        pass
        {
            // Name "Forward Lit"
            // Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            float4 _MainTex_ST;

            // Input struct
            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            // Output struct
            struct Varyings
            {            
                float4 positionHCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float3 positionWS : TEXCOORD1;   
                float2 uv : TEXCOORD2;    
            };

            Varyings Vertex(const Attributes input){
                Varyings output;
                
                output.positionHCS = TransformObjectToHClip(input.positionOS);
                output.positionWS = TransformObjectToWorld(input.positionOS);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);

                output.uv = input.uv * _MainTex_ST.xy + _MainTex_ST.zw + _Time.y * float2(0.5, 1);

                return output;
            }

            half4 Fragment(Varyings input) : SV_TARGET{

                

                return SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
            }


            ENDHLSL

        }

        Pass
        {
            Name "Normals"
            Tags { "LightMode" = "DepthNormalsOnly" }
            
            Cull Back
            ZTest LEqual
            ZWrite On
        }
        
    }
}

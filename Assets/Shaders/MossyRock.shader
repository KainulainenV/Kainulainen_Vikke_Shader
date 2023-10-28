Shader "Custom/MossyRock"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _SecondaryTex ("Albedo (RGB)", 2D) = "white" {}
        _StripeCount("Stripe Count", range(0, 10)) = 0.5
        _Fade("Fade", range(0, 1)) = 0.5
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
            TEXTURE2D(_SecondaryTex);
            SAMPLER(sampler_MainTex);
            SAMPLER(sampler_SecondaryTex);

            float4 _MainTex_ST;
            float4 _SecondaryTex_ST;
            float _StripeCount;
            float _Fade;

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

                output.uv = input.uv;// * _MainTex_ST.xy + _MainTex_ST.zw;// + _Time.y * float2(0.5, 1);

                return output;
            }

            half4 Fragment(Varyings input) : SV_TARGET{

                float stripe = _Fade * (1.0 + sin(input.uv.x * _StripeCount * 2 * 3.14159265358));

                return lerp(SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv * _MainTex_ST.xy + _MainTex_ST.zw), SAMPLE_TEXTURE2D(_SecondaryTex, sampler_SecondaryTex, input.uv * _SecondaryTex_ST.xy + _SecondaryTex_ST.zw), stripe);
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

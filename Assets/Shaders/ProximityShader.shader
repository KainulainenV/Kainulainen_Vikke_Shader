Shader "Custom/ProximityShader"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _PlayerPosition("Player Position", Vector) = (0, 0, 0, 0)
        _PlayerPosition2("Player Position", Vector) = (0, 0, 0, 0)
        _DistanceAttuenation("Distance Attuenation", range(1, 10)) = 1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" }

        pass
        {
            HLSLPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            float4 _MainTex_ST;
            float3 _PlayerPosition;
            float3 _PlayerPosition2;
            float _DistanceAttuenation;

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

                output.uv = input.uv * _MainTex_ST.xy + _MainTex_ST.zw;// + _Time.y * float2(0.5, 1);

                return output;
            }

            half4 Fragment(Varyings input) : SV_TARGET{

                const float4 color1 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);

                float distance = length(_PlayerPosition - input.positionWS);
                distance = saturate(1 - distance / _DistanceAttuenation);

                float distance2 = length(_PlayerPosition2 - input.positionWS);
                distance2 = saturate(1 - distance2 / _DistanceAttuenation);

                return lerp(0, (sin(distance * 50 /*+ _Time.y*10*/) + 1) * color1, distance);
                //return lerp(0, color1, distance + distance2);
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
            
            HLSLPROGRAM
            
            #pragma vertex DepthNormalsVert
            #pragma fragment DepthNormalsFrag

            #include "Common/DepthNormalsOnly.hlsl"
            
            ENDHLSL
        }
        
    }
}

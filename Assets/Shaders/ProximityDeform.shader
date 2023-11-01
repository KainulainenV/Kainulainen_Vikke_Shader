Shader "Custom/ProximityDeform"
{
    Properties
    {
        _Color("Main Color", Color) = (1, 1, 1, 1)
        _PlayerPosition("Player Position", Vector) = (0, 0, 0, 0)
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

            float4 _Color;
            float3 _PlayerPosition;
            float _DistanceAttuenation;

            // Input struct
            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            // Output struct
            struct Varyings
            {            
                float4 positionHCS : SV_POSITION;  
            };

            Varyings Vertex(Attributes input)
            {
                Varyings output; 
                const float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
               
                float3 dir = positionWS - _PlayerPosition;
                float distance = length(dir);
                distance = saturate(1 - distance / _DistanceAttuenation);

                output.positionHCS = TransformWorldToHClip(positionWS + normalize(dir) * distance);

                return output;
            }

            half4 Fragment(Varyings input) : SV_TARGET{

                return _Color;
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

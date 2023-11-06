Shader "Custom/Intersection"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _IntersectionColor("Intersection Color", Color) = (0, 0, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent" "RenderPipeline"="UniversalPipeline" }

        pass
        {
            Name "IntersectionUnlit"
            Tags { "LightMode"="SRPDefaultUnlit" }
            
            Cull Back
            Blend One Zero
            ZTest LEqual
            ZWrite On
            
            HLSLPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            #pragma vertex Vertex
            #pragma fragment Fragment

            float4 _Color;
            float4 _IntersectionColor;
            
            
            // Input struct
            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            // Output struct
            struct Varyings
            {            
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;   
            };

            Varyings Vertex(const Attributes input){
                Varyings output;
                
                output.positionHCS = TransformObjectToHClip(input.positionOS);
                output.positionWS = TransformObjectToWorld(input.positionOS);

                return output;
            }



            half4 Fragment(Varyings input) : SV_TARGET{

                float2 screenUV = GetNormalizedScreenSpaceUV(input.positionHCS);
                float3 SceneDepth = SampleSceneDepth(screenUV);
                float3 depthTexture = LinearEyeDepth(SceneDepth, _ZBufferParams);
                float3 depthObject = LinearEyeDepth(input.positionWS, UNITY_MATRIX_V);

                float lerpValue = pow(1- saturate(depthTexture - depthObject), 15);

                return lerp(_Color, _IntersectionColor, lerpValue);
                
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

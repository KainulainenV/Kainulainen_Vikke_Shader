Shader "Custom/BlinnPhong"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Shininess ("Shininess", Range(0.01,500)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" }

        Pass {
            Name "Forward Lit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            #pragma vertex Vertex
            #pragma fragment Fragment
          
            // Vaihe 2
            struct Attributes
            {
                // -> float4
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                    
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float _Shininess;
            CBUFFER_END
            
            // Vaihe 3
            Varyings Vertex(const Attributes input)
            {

                Varyings output;

                output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
            
                // output.positionHCS = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_V, mul(UNITY_MATRIX_M, float4(input.positionOS, 1))));

                // output.positionWS = mul(unity_ObjectToWorld, input.positionOS);
                // output.normalWS = mul((float3x3)unity_ObjectToWorld, input.normalOS);
                    
                return output;
            }

            // Vaihe 4
            float4 BlinnPhong(const Varyings input) {
                
                Light light = GetMainLight();

                float3 ambientLighting = 0.1 * light.color;
                float3 diffuse = saturate(dot(input.normalWS, light.direction)) * light.color;

                //const VertexPositionInputs position_inputs = GetVertexPositionInputs(/*positionOS*/)
                //const VertexNormalInputs normal_inputs = GetVertexNormalInputs(/*normalOS, tangentOS*/)            

                float3 viewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
                float3 halfwayVector = normalize(light.direction + viewDirection);

                float3 specularLighting = pow(saturate(dot(input.normalWS, halfwayVector)), _Shininess) * light.color;
            
                return float4((ambientLighting + diffuse + specularLighting /* *10 (optional) */) * _Color.rgb, 1);
            }

            // Vaihe 5
            float4 Fragment(const Varyings input) : SV_TARGET
            {                   
                return BlinnPhong(input);
            }    
           
            ENDHLSL            
        }

        Pass
        {
            Name "Depth"
            Tags { "LightMode" = "DepthOnly" }
            
            Cull Back
            ZTest LEqual
            ZWrite On
            ColorMask R
            
            HLSLPROGRAM
            
            #pragma vertex DepthVert
            #pragma fragment DepthFrag
            // PITÄÄ OLLA RELATIVE PATH TIEDOSTOON!!!
            #include "Common/DepthOnly.hlsl"
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

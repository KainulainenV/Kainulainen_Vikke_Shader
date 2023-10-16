Shader"Custom/TestiShader"
{
    Properties
    {
        [KeywordEnum(World, Local)]
        _ColorKeyword("Color", Float) = 0
        _Color("Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Tags { 
               "RenderType"="Opaque" 
               "RenderPipeline" = "UniversalPipeline" 
               "Queue" = "Geometry" 
             }
            Pass
            {
                Name "OmaPass"
                Tags
                {
                    "LightMode" = "UniversalForward"
                }

                HLSLPROGRAM
                #pragma vertex Vert
                #pragma fragment Frag

                #pragma shader_feature_local_fragment LOCAL_COORDINATES_WORLD LOCAL_COORDINATES_OBJECT

                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"

                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                };

                struct Varyings
                {
                    float4 positionHCS : SV_POSITION;
                    float3 positionWS : TEXCOORD0;
                    
                };

                // SRP Batcher compatible
                CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                CBUFFER_END
               

                Varyings Vert(const Attributes input)
                {
                    Varyings output;

                    //float3 newPosition = input.positionOS + float3(0,1,0);

                    // #if LOCAL_COORDINATES_WORLD
                    output.positionHCS = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_V, mul(UNITY_MATRIX_M, float4(input.positionOS, 1))));
                    output.positionWS = input.positionOS;
                    // #elif LOCAL_COORDINATES_OBJECT
                    // float4 newPosition = float4(input.positionOS + float3(0, 1, 0), 1);
                    // output.positionHCS = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_V, mul(UNITY_MATRIX_M, newPosition)));
                    // output.positionWS = newPosition.xyz;
                    // #endif

               
    
                    //output.positionHCS = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_V, mul(UNITY_MATRIX_M, float4(input.positionOS, 1))));
                    //output.positionHCS = TransformObjectToHClip(input.positionOS);
                    //output.positionWS = TransformObjectToWorld(input.positionOS);
                    //output.positionWS = mul(UNITY_MATRIX_M, input.positionOS + newPosition);

                    //const float3 os = mul(UNITY_MATRIX_I_M, output.positionWS)
                    //output.positionWS = input.normalOS;
                    return output;
                }

                float3 Frag(const Varyings input) : SV_TARGET
                {
                    float4 col = 1;

                    //half3 normalColor = input.positionWS * 0.5 + 0.5;
                    
                    return _Color * clamp(input.positionWS.x, 0, 1);
                }            
                //clamp(input.positionWS.x, 0, 1)

                ENDHLSL
            }                       
    }
}

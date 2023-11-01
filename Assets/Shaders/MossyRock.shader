Shader "Custom/MossyRock"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _SecondaryTex ("Albedo (RGB)", 2D) = "white" {}
        _NormalMap("Normal", 2D) = "bump" {}

        _StripeCount("Stripe Count", range(0, 10)) = 0.5
        _Fade("Fade", range(0, 1)) = 0.5

        _Shininess ("Shininess", Range(0.01,500)) = 0.5
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

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            TEXTURE2D(_MainTex);
            TEXTURE2D(_SecondaryTex);
            TEXTURE2D(_NormalMap);

            SAMPLER(sampler_MainTex);
            SAMPLER(sampler_SecondaryTex);
            SAMPLER(sampler_NormalMap);

            float4 _MainTex_ST;
            float4 _SecondaryTex_ST;
            float4 _NormalMap_ST;

            float _Shininess;
            float _StripeCount;
            float _Fade;

            // Input struct
            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
                float4 tangentOS : TANGENT;
            };

            // Output struct
            struct Varyings
            {            
                float4 positionHCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float3 positionWS : TEXCOORD1;   
                float2 uv : TEXCOORD2;    
                float3 tangentWS : TEXCOORD3;
                float3 bitangentWS : TEXCOORD4;
            };

            Varyings Vertex(const Attributes input){
                Varyings output;
                
                const VertexPositionInputs posInputs = GetVertexPositionInputs(input.positionOS);
                const VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                output.positionHCS = posInputs.positionCS;
                output.normalWS = normalInputs.normalWS;
                output.tangentWS = normalInputs.tangentWS;
                output.bitangentWS = normalInputs.bitangentWS;
                output.positionWS = posInputs.positionWS; // <===== Ei tarvitse
                
                output.uv = input.uv;

                //output.positionWS = TransformObjectToWorld(input.positionOS);
                //output.normalWS = TransformObjectToWorldNormal(input.normalOS);

                return output;
            }

            float4 BlinnPhong(const Varyings input, float4 color) {
                
                Light light = GetMainLight();

                float3 ambientLighting = 0.1 * light.color;
                float3 diffuse = saturate(dot(input.normalWS, light.direction)) * light.color;

                //const VertexPositionInputs position_inputs = GetVertexPositionInputs(/*positionOS*/)
                //const VertexNormalInputs normal_inputs = GetVertexNormalInputs(/*normalOS, tangentOS*/)            

                float3 viewDirection = GetWorldSpaceNormalizeViewDir(input.positionWS);
                float3 halfwayVector = normalize(light.direction + viewDirection);

                float3 specularLighting = pow(saturate(dot(input.normalWS, halfwayVector)), _Shininess) * light.color;
            
                return float4((ambientLighting + diffuse + specularLighting /* *10 (optional) */) * color.rgb, 1);
            }

            half4 Fragment(Varyings input) : SV_TARGET{

                const float4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, TRANSFORM_TEX(input.uv, _MainTex));
                const float3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, TRANSFORM_TEX(input.uv, _MainTex)));
                const float3x3 TangentToWorld = float3x3(input.tangentWS, input.bitangentWS, input.normalWS);

                const float3 normalWS = TransformTangentToWorld(normalTS, TangentToWorld, true);

                input.normalWS = normalWS; // <=== ei liity tehtävään
                
                return BlinnPhong(input, texColor);
                // float stripe = _Fade * (1.0 + sin(input.uv.x * _StripeCount * 2 * 3.14159265358));
                
                // return lerp(SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv * _MainTex_ST.xy + _MainTex_ST.zw), SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, input.uv * _NormalMap_ST.xy + _NormalMap_ST.zw), stripe);
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

// Upgrade NOTE: upgraded instancing buffer 'InstanceProperties' to new syntax.

// Upgrade NOTE: replaced 'UNITY_PASS_TEXCUBE(unity_SpecCube1)' with 'UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1,unity_SpecCube0)'

#if !defined(MY_LIGHTING_INPUT_INCLUDED)
#define MY_LIGHTING_INPUT_INCLUDED

#include "UnityPBSLighting.cginc"
#include "AutoLight.cginc"
#include "MySurface.cginc"

#if defined(_NORMAL_MAP) || defined(_DETAIL_NORMAL_MAP) || defined(_PARALLAX_MAP)
	#define REQUIRES_TANGENT_SPACE 1
	#define TESSELLATION_TANGENT 1
#endif
#define TESSELLATION_UV1 1
#define TESSELLATION_UV2 1

#if defined(_PARALLAX_MAP) && defined(VERTEX_DISPLACEMENT_INSTEAD_OF_PARALLAX)
	#undef _PARALLAX_MAP
	#define VERTEX_DISPLACEMENT 1
	#define _DisplacementMap _ParallaxMap
	#define _DisplacementStrength _ParallaxStrength
#endif

#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
	#if !defined(FOG_DISTANCE)
		#define FOG_DEPTH 1
	#endif
	#define FOG_ON 1
#endif

#if !defined(LIGHTMAP_ON) && defined(SHADOWS_SCREEN)
	#if defined(SHADOWS_SHADOWMASK) && !defined(UNITY_NO_SCREENSPACE_SHADOWS)
		#define ADDITIONAL_MASKED_DIRECTIONAL_SHADOWS 1
	#endif
#endif

#if defined(LIGHTMAP_ON) && defined(SHADOWS_SCREEN)
	#if defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK)
		#define SUBTRACTIVE_LIGHTING 1
	#endif
#endif

UNITY_INSTANCING_BUFFER_START(InstanceProperties)
	UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
#define _Color_arr InstanceProperties
UNITY_INSTANCING_BUFFER_END(InstanceProperties)
sampler2D _MainTex, _DetailTex, _DetailMask;
float4 _MainTex_ST, _DetailTex_ST;

sampler2D _NormalMap, _DetailNormalMap;
float _BumpScale, _DetailBumpScale;

sampler2D _MetallicMap;
float _Metallic;
float _Smoothness;

sampler2D _EmissionMap;
float3 _Emission;

sampler2D _ParallaxMap;
float _ParallaxStrength;

sampler2D _OcclusionMap;
float _OcclusionStrength;

float _Cutoff;

struct VertexData {
	UNITY_VERTEX_INPUT_INSTANCE_ID
	float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
	float2 uv : TEXCOORD0;
	float2 uv1 : TEXCOORD1;
	float2 uv2 : TEXCOORD2;
};

struct InterpolatorsVertex {
	UNITY_VERTEX_INPUT_INSTANCE_ID
	float4 pos : SV_POSITION;

	#if !defined(NO_DEFAULT_UV)
		float4 uv : TEXCOORD0;
	#endif

    float3 normal : TEXCOORD1;
    
    #if REQUIRES_TANGENT_SPACE
		#if defined(BINORMAL_PER_FRAGMENT)
			float4 tangent : TEXCOORD2;
		#else
			float3 tangent : TEXCOORD2;
			float3 binormal : TEXCOORD3;
		#endif
	#endif

	#if FOG_DEPTH
		float4 worldPos : TEXCOORD4;
	#else
		float3 worldPos : TEXCOORD4;
	#endif

	UNITY_SHADOW_COORDS(5)

    #if defined(VERTEXLIGHT_ON)
		float3 vertexLightColor : TEXCOORD6;
	#endif

	#if defined(LIGHTMAP_ON) || ADDITIONAL_MASKED_DIRECTIONAL_SHADOWS
		float2 lightmapUV : TEXCOORD6;
	#endif

	#if defined(DYNAMICLIGHTMAP_ON)
		float2 dynamicLightmapUV : TEXCOORD7;
	#endif

	#if defined(_PARALLAX_MAP)
		float3 tangentViewDir : TEXCOORD8;
	#endif
};

struct Interpolators {
	UNITY_VERTEX_INPUT_INSTANCE_ID
	#if defined(LOD_FADE_CROSSFADE)
		UNITY_VPOS_TYPE vpos : VPOS;
	#else
		float4 pos : SV_POSITION;
	#endif

	#if !defined(NO_DEFAULT_UV)
		float4 uv : TEXCOORD0;
	#endif

    float3 normal : TEXCOORD1;
    
    #if REQUIRES_TANGENT_SPACE
		#if defined(BINORMAL_PER_FRAGMENT)
			float4 tangent : TEXCOORD2;
		#else
			float3 tangent : TEXCOORD2;
			float3 binormal : TEXCOORD3;
		#endif
	#endif

	#if FOG_DEPTH
		float4 worldPos : TEXCOORD4;
	#else
		float3 worldPos : TEXCOORD4;
	#endif

	UNITY_SHADOW_COORDS(5)

    #if defined(VERTEXLIGHT_ON)
		float3 vertexLightColor : TEXCOORD6;
	#endif

	#if defined(LIGHTMAP_ON) || ADDITIONAL_MASKED_DIRECTIONAL_SHADOWS
		float2 lightmapUV : TEXCOORD6;
	#endif

	#if defined(DYNAMICLIGHTMAP_ON)
		float2 dynamicLightmapUV : TEXCOORD7;
	#endif

	#if defined(_PARALLAX_MAP)
		float3 tangentViewDir : TEXCOORD8;
	#endif

	#if defined (CUSTOM_GEOMETRY_INTERPOLATORS)
		CUSTOM_GEOMETRY_INTERPOLATORS
	#endif
};

float4 GetDefaultUV (Interpolators i) {
	#if defined(NO_DEFAULT_UV)
		return float4(0, 0, 0, 0);
	#else
		return i.uv;
	#endif
}

#if !defined(UV_FUNCTION)
	#define UV_FUNCTION GetDefaultUV
#endif

float GetMetallic (Interpolators i) {
	#if defined(_MERALLIC_MAP)
		return tex2D(_MetallicMap, UV_FUNCTION(i).xy).r;
	#else
		return _Metallic;
	#endif
}

float GetSmoothness (Interpolators i) {
	float smoothness = 1;
	#if defined(_SMOOTHNESS_ALBEDO)
		smoothness = tex2D(_MainTex, UV_FUNCTION(i).xy).a;
	#elif defined(_SMOOTHNESS_METALLIC) && defined(_METALLIC_MAP)
		smoothness = tex2D(_MetallicMap, UV_FUNCTION(i).xy).a;
	#endif
	return smoothness * _Smoothness;
}

float3 GetEmission (Interpolators i) {
	#if defined(FORWARD_BASE_PASS) || defined(DEFERRED_PASS)
		#if defined(_EMISSION_MAP)
			return tex2D(_EmissionMap, UV_FUNCTION(i).xy) * _Emission;
		#else
			return _Emission;
		#endif
	#else
		return 0;
	#endif
}

float3 GetOcclusion (Interpolators i) {
	#if defined(_OCCLUSION_MAP)
		return lerp(1, tex2D(_OcclusionMap, UV_FUNCTION(i).xy).g, _OcclusionStrength);
	#else
		return 1;
	#endif
}

float GetDetailMask (Interpolators i) {
	#if defined (_DETAIL_MASK)
		return tex2D(_DetailMask, UV_FUNCTION(i).xy).a;
	#else
		return 1;
	#endif
}

float3 GetAlbedo (Interpolators i) {
	float3 albedo = 
		tex2D(_MainTex, UV_FUNCTION(i).xy).rgb * UNITY_ACCESS_INSTANCED_PROP(_Color_arr, _Color).rgb;
	#if defined (_DETAIL_ALBEDO_MAP)
		float3 details = tex2D(_DetailTex, UV_FUNCTION(i).zw) * unity_ColorSpaceDouble;
		albedo = lerp(albedo, albedo * details, GetDetailMask(i));
	#endif
	return albedo;
}

float3 GetTangentSpaceNormal (Interpolators i) {
	float3 normal = float3(0, 0, 1);
	#if defined(_NORMAL_MAP)
		normal = UnpackScaleNormal(tex2D(_NormalMap, UV_FUNCTION(i).xy), _BumpScale);
	#endif
	#if defined(_DETAIL_NORMAL_MAP)
		float3 detailNormal =
			UnpackScaleNormal(tex2D(_DetailNormalMap, UV_FUNCTION(i).zw), _DetailBumpScale);
		detailNormal = lerp(float3(0, 0, 1), detailNormal, GetDetailMask(i));
		normal = BlendNormals(normal, detailNormal);
	#endif
	return normal;
}

float GetAlpha (Interpolators i) {
	float alpha = UNITY_ACCESS_INSTANCED_PROP(_Color_arr, _Color).a;
	#if !defined(_SMOOTHNESS_ALBEDO)
		alpha *= tex2D(_MainTex, UV_FUNCTION(i).xy).a;
	#endif
	return alpha;
}

#endif
// Upgrade NOTE: replaced 'UNITY_PASS_TEXCUBE(unity_SpecCube1)' with 'UNITY_PASS_TEXCUBE_SAMPLER(unity_SpecCube1,unity_SpecCube0)'

#if !defined(MY_LIGHTING_INCLUDED)
#define MY_LIGHTING_INCLUDED

#include "MyLightingInput.cginc"
#include "UnityMetaPass.cginc"

Interpolators MyLightmappingVertexProgram (VertexData v) {
	Interpolators i;
	i.pos = UnityMetaVertexPosition(
		v.vertex, v.uv1, v.uv2, unity_LightmapST, unity_DynamicLightmapST
	);

	#if defined(META_PASS_NEEDS_NORMALS)
		i.normal = UnityObjectToWorldNormal(v.normal);
	#else
		i.normal = float3(0, 1, 0);
	#endif
	#if defined(META_PASS_NEEDS_POSITION)
		i.worldPos.xyz = mul(unity_ObjectToWorld, v.vertex);
	#else
		i.worldPos.xyz = 0;
	#endif

	#if !defined(NO_DEFAULT_UV)
		i.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
		i.uv.zw = TRANSFORM_TEX(v.uv, _DetailTex);
	#endif

	return i;
}

#if !defined(ALBEDO_FUNCTION)
	#define ALBEDO_FUNCTION GetAlbedo
#endif

float4 MyLightmappingFragmentProgram (Interpolators i) : SV_TARGET {
	SurfaceData surface;
	surface.normal = normalize(i.normal);
	surface.albedo = 1;
	surface.alpha = 1;
	surface.emission = 0;
	surface.metallic = 0;
	surface.occlusion = 1;
	surface.smoothness = 0.5;
	#if defined(SURFACE_FUNCTION)
		SurfaceParameters sp;
		sp.normal = i.normal;
		sp.position = i.worldPos.xyz;
		sp.uv = UV_FUNCTION(i);

		SURFACE_FUNCTION(surface, sp);
	#else
		surface.albedo = ALBEDO_FUNCTION(i);
		surface.emission = GetEmission(i);
		surface.metallic = GetMetallic(i);
		surface.smoothness = GetSmoothness(i);
	#endif

	UnityMetaInput surfaceData;
	surfaceData.Emission = surface.emission;
	float oneMinusReflectivity;
	surfaceData.Albedo = DiffuseAndSpecularFromMetallic(
		surface.albedo, surface.metallic,
		surfaceData.SpecularColor, oneMinusReflectivity
	);

	float roughness = SmoothnessToRoughness(surface.smoothness) * 0.5;
	surfaceData.Albedo += surfaceData.SpecularColor * roughness;

	return UnityMetaFragment(surfaceData);
}

#endif
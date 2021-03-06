//
// P4LWRP.cginc
//
// Projector For LWRP
//
// Copyright (c) 2019 NYAHOON GAMES PTE. LTD.
//

#if !defined(P4LWRP_CGINC_INCLUDED)
#define P4LWRP_CGINC_INCLUDED
#include "UnityCG.cginc"

struct P4LWRP_V2F_PROJECTOR {
	float4 uvShadow : TEXCOORD0;
	UNITY_FOG_COORDS(1)
	float4 pos : SV_POSITION;
};

#if defined(FSR_PROJECTOR_FOR_LWRP)
CBUFFER_START(FSR_ProjectorTransform)
float4x4 _FSRWorldToProjector;
float4 _FSRWorldProjectDir;
CBUFFER_END
void fsrTransformVertex(float4 v, out float4 clipPos, out float4 shadowUV)
{
	float4 worldPos;
	worldPos.xyz = mul(unity_ObjectToWorld, v).xyz;
	worldPos.w = 1.0f;
#if defined(STEREO_CUBEMAP_RENDER_ON)
    worldPos.xyz += ODSOffset(worldPos.xyz, unity_HalfStereoSeparation.x);
#endif
	clipPos = mul(UNITY_MATRIX_VP, worldPos);
	shadowUV = mul(_FSRWorldToProjector, worldPos);
}
float3 fsrProjectorDir()
{
	return UnityWorldToObjectDir(_FSRWorldProjectDir.xyz);
}
#elif defined(FSR_RECEIVER) // FSR_RECEIVER keyword is used by Projection Receiver Renderer component which is contained in Fast Shadow Receiver.
CBUFFER_START(FSR_ProjectorTransform)
float4x4 _FSRProjector;
float4 _FSRProjectDir;
CBUFFER_END
void fsrTransformVertex(float4 v, out float4 clipPos, out float4 shadowUV)
{
	clipPos = UnityObjectToClipPos(v);
	shadowUV = mul(_FSRProjector, v);
}
float3 fsrProjectorDir()
{
	return _FSRProjectDir.xyz;
}
#else
CBUFFER_START(FSR_ProjectorTransform)
float4x4 unity_Projector;
float4x4 unity_ProjectorClip;
CBUFFER_END
void fsrTransformVertex(float4 v, out float4 clipPos, out float4 shadowUV)
{
	clipPos = UnityObjectToClipPos(v);
	shadowUV = mul (unity_Projector, v);
	shadowUV.z = mul (unity_ProjectorClip, v).x;
}
float3 fsrProjectorDir()
{
	return normalize(float3(unity_Projector[2][0],unity_Projector[2][1], unity_Projector[2][2]));
}
#endif

sampler2D _ShadowTex;
sampler2D _FalloffTex;
CBUFFER_START(P4LWRP_ProjectorParams)
fixed4 _Color;
CBUFFER_END

P4LWRP_V2F_PROJECTOR p4lwrp_vert_projector(float4 vertex : POSITION)
{
	P4LWRP_V2F_PROJECTOR o;
	fsrTransformVertex(vertex, o.pos, o.uvShadow);
	UNITY_TRANSFER_FOG(o, o.pos);
	return o;
}

fixed4 p4lwrp_frag_projector_shadow(P4LWRP_V2F_PROJECTOR i) : SV_Target
{
	fixed4 col;
	fixed alpha = tex2D(_FalloffTex, i.uvShadow.zz).a;
	col.rgb = tex2Dproj(_ShadowTex, UNITY_PROJ_COORD(i.uvShadow)).rgb;
	col.a = 1.0f;
	col.rgb = lerp(fixed3(1,1,1), col.rgb, alpha);
	UNITY_APPLY_FOG_COLOR(i.fogCoord, col, fixed4(1,1,1,1));
	return col;
}

fixed4 p4lwrp_frag_projector_light(P4LWRP_V2F_PROJECTOR i) : SV_Target
{
	fixed4 col;
	fixed alpha = tex2D(_FalloffTex, i.uvShadow.zz).a;
	col.rgb = _Color.rgb * tex2Dproj(_ShadowTex, UNITY_PROJ_COORD(i.uvShadow)).rgb;
	col.a = 1.0f;
	col.rgb *= alpha;
	UNITY_APPLY_FOG_COLOR(i.fogCoord, col, fixed4(0,0,0,0));
	return col;
}

#endif // !defined(P4LWRP_CGINC_INCLUDED)

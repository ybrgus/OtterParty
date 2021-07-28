﻿Shader "Projector For LWRP/Shadow" 
{
	Properties {
		[NoScaleOffset] _ShadowTex ("Cookie", 2D) = "gray" {}
		[NoScaleOffset] _FalloffTex ("FallOff", 2D) = "white" {}
		_Offset ("Offset", Range (-1, -10)) = -1.0
	}
	SubShader
	{
		Tags {"Queue"="Transparent-1"}
        // Shader code
		Pass
        {
			ZWrite Off
			Fog { Color (1, 1, 1) }
			ColorMask RGB
			Blend DstColor Zero
			Offset -1, [_Offset]

			CGPROGRAM
			#pragma vertex p4lwrp_vert_projector
			#pragma fragment p4lwrp_frag_projector_shadow
			#pragma multi_compile _ FSR_RECEIVER FSR_PROJECTOR_FOR_LWRP
			#pragma multi_compile_fog
			#include "UnityCG.cginc"
			#include "P4LWRP.cginc"
			ENDCG
		}
	} 
}

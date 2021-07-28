﻿//
// ProjectorRendererFeature.cs
//
// Projector For LWRP
//
// Copyright (c) 2019 NYAHOON GAMES PTE. LTD.
//

using UnityEngine;

using System.Collections.Generic;

namespace ProjectorForLWRP
{
	public class ProjectorRendererFeature : UnityEngine.Rendering.Universal.ScriptableRendererFeature
	{
		private static Dictionary<Camera, RenderProjectorPass> s_projectorPasses = new Dictionary<Camera, RenderProjectorPass>();
		public static void AddProjector(ProjectorForLWRP projector, Camera camera)
		{
			RenderProjectorPass pass;
			if (!s_projectorPasses.TryGetValue(camera, out pass))
			{
				pass = new RenderProjectorPass(camera); pass.renderPassEvent = projector.renderPassEvent; s_projectorPasses.Add(camera, pass);
			}
			pass.AddProjector(projector);
		}
		public override void Create()
		{
			s_projectorPasses = new Dictionary<Camera, RenderProjectorPass>();
		}
		public override void AddRenderPasses(UnityEngine.Rendering.Universal.ScriptableRenderer renderer, ref UnityEngine.Rendering.Universal.RenderingData renderingData)
		{
			RenderProjectorPass pass; if (s_projectorPasses.TryGetValue(renderingData.cameraData.camera, out pass))
			{
				renderer.EnqueuePass(pass);
			}
		}
	}
}

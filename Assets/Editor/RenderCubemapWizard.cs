using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class RenderCubemapWizard : ScriptableWizard {

	public Transform renderFromPosition;
	public Cubemap cubemap;

	void OnWizardUpdate() {
		helpString = "Select transform to render from and cubemap to render into";
		isValid = (renderFromPosition != null) && (cubemap != null);
	}

	void OnWizardCreate() {
		// create temporary camera for rendering 
		GameObject go = new GameObject("CubemapCamera");
		Camera cam = go.AddComponent<Camera>();
		// place it on the object
		go.transform.position = renderFromPosition.position;
		// render into cubemap
		cam.RenderToCubemap(cubemap);

		DestroyImmediate(go);
	}

	[MenuItem("GameObject/Render into Cubemap")]
	static void RenderCubemap() {
		ScriptableWizard.DisplayWizard<RenderCubemapWizard>("Render cubemap", "Render!");
	}
}

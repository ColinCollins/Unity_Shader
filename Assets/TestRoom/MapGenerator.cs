using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

[RequireComponent(typeof(MeshFilter))]
public class MapGenerator : MonoBehaviour {

	private Vector3[] vertexs;
	private Vector3[] normals;
	private Vector2[] uvs;
	private int[] indices;

	private int cubeCount = 0;

	public Material testMaterial;

	void Start() {

		vertexs = new Vector3[] { };
		normals = new Vector3[] { };
		uvs = new Vector2[] { };
		indices = new int[] { };

		Mesh mesh = new Mesh();
		GetComponent<MeshFilter>().mesh = mesh;
		// AddCom<MeshRenderer>();
		this.gameObject.AddComponent<MeshRenderer>();
		this.gameObject.GetComponent<Renderer>().material = testMaterial;
		Vector3 moveTo = new Vector3(1, 0, 0);
		createNewCube();
		createNewCube(moveTo);
		updateShape(mesh);
	}

	private void createNewCube(Vector3 moveTo = default(Vector3)) {
		cubeCount++;

		Vector3[] newVertexs = getVertexsData();
		Vector3[] tempVertexs = new Vector3[newVertexs.Length * cubeCount];
		vertexs.CopyTo(tempVertexs, 0);

		if (moveTo != default(Vector3)) {
			newVertexs = MoveTo(moveTo, newVertexs);
		}
		newVertexs.CopyTo(tempVertexs, vertexs.Length);
		vertexs = tempVertexs;

		Vector3[] newNormals = getNormalsData();
		Vector3[] tempNormals = new Vector3[newNormals.Length * cubeCount];
		normals.CopyTo(tempVertexs, 0);
		newNormals.CopyTo(tempNormals, normals.Length);
		normals = tempNormals;

		Vector2[] newUVs = getUVData();
		Vector2[] tempUVs = new Vector2[newUVs.Length * cubeCount];
		uvs.CopyTo(tempUVs, 0);
		newUVs.CopyTo(tempUVs, uvs.Length);
		uvs = tempUVs;

		int[] newIndices = getIndexData();

		for (int i = 0; i < newIndices.Length; i++) {
			newIndices[i] += newVertexs.Length * (cubeCount - 1);
		}

		int[] tempIndices = new int[newIndices.Length * cubeCount];
		indices.CopyTo(tempIndices, 0);
		newIndices.CopyTo(tempIndices, indices.Length);
		indices = tempIndices;
	}

	private void updateShape(Mesh mesh) {
		mesh.Clear();

		mesh.vertices = vertexs;
		mesh.triangles = indices;
		mesh.normals = normals;
		mesh.uv = uvs;

		mesh.RecalculateNormals();
	}

	private Vector3[] MoveTo(Vector3 newPos, Vector3[] vertexs) {
		for (int i = 0; i < vertexs.Length; i++) {
			vertexs[i] = vertexs[i] + newPos;
		}

		return vertexs;
	}

	private Vector3[] getVertexsData() {
		return new Vector3[] {
			// front
			new Vector3(1.0f, 1.0f, 1.0f),
			new Vector3(-1.0f, 1.0f, 1.0f),
			new Vector3(-1.0f, -1.0f, 1.0f),
			new Vector3(1.0f, -1.0f, 1.0f),

			// right
			new Vector3(1.0f, 1.0f, 1.0f),
			new Vector3(1.0f, -1.0f, 1.0f),
			new Vector3(1.0f, -1.0f, -1.0f),
			new Vector3(1.0f, 1.0f, -1.0f),

			// top
			new Vector3(1.0f, 1.0f, 1.0f),
			new Vector3(1.0f, 1.0f, -1.0f),
			new Vector3(-1.0f, 1.0f, -1.0f),
			new Vector3(-1.0f, 1.0f, 1.0f),

			// left
			new Vector3(-1.0f, 1.0f, 1.0f),
			new Vector3(-1.0f, 1.0f, -1.0f),
			new Vector3(-1.0f, -1.0f, -1.0f),
			new Vector3(-1.0f, -1.0f, 1.0f),

			// bottom
			new Vector3(-1.0f, -1.0f, -1.0f),
			new Vector3(1.0f, -1.0f, -1.0f),
			new Vector3(1.0f, -1.0f, 1.0f),
			new Vector3(-1.0f, -1.0f, 1.0f),

			// back
			new Vector3(1.0f, -1.0f, -1.0f),
			new Vector3(-1.0f, -1.0f, -1.0f),
			new Vector3(-1.0f, 1.0f, -1.0f),
			new Vector3(1.0f, 1.0f, -1.0f)
		};
	}

	private Vector2[] getUVData() {
		return new Vector2[] {
			// front
			new Vector2(1.0f, 1.0f),
			new Vector2(0.0f, 1.0f),
			new Vector2(0.0f, 0.0f),
			new Vector2(1.0f, 0.0f),
			// right
			new Vector2(0.0f, 1.0f),
			new Vector2(0.0f, 0.0f),
			new Vector2(1.0f, 0.0f),
			new Vector2(1.0f, 1.0f),
			// top
			new Vector2(1.0f, 0.0f),
			new Vector2(1.0f, 1.0f),
			new Vector2(0.0f, 1.0f),
			new Vector2(0.0f, 0.0f),
			// left
			new Vector2(1.0f, 1.0f),
			new Vector2(0.0f, 1.0f),
			new Vector2(0.0f, 0.0f),
			new Vector2(1.0f, 0.0f),
			// bottom
			new Vector2(0.0f, 1.0f),
			new Vector2(1.0f, 1.0f),
			new Vector2(1.0f, 0.0f),
			new Vector2(0.0f, 0.0f),
			// back
			new Vector2(0.0f, 0.0f),
			new Vector2(1.0f, 0.0f),
			new Vector2(1.0f, 1.0f),
			new Vector2(0.0f, 1.0f)
		};
	}

	private Vector3[] getNormalsData() {
		return new Vector3[] {
			new Vector3 (0.0f, 0.0f, 1.0f),
			new Vector3 (0.0f, 0.0f, 1.0f),
			new Vector3 (0.0f, 0.0f, 1.0f),
			new Vector3 (0.0f, 0.0f, 1.0f),

			new Vector3 (1.0f, 0.0f, 0.0f),
			new Vector3 (1.0f, 0.0f, 0.0f),
			new Vector3 (1.0f, 0.0f, 0.0f),
			new Vector3 (1.0f, 0.0f, 0.0f),

			new Vector3 (0.0f, 1.0f, 0.0f),
			new Vector3 (0.0f, 1.0f, 0.0f),
			new Vector3 (0.0f, 1.0f, 0.0f),
			new Vector3 (0.0f, 1.0f, 0.0f),

			new Vector3 (-1.0f, 0.0f, 0.0f),
			new Vector3 (-1.0f, 0.0f, 0.0f),
			new Vector3 (-1.0f, 0.0f, 0.0f),
			new Vector3 (-1.0f, 0.0f, 0.0f),

			new Vector3 (0.0f, -1.0f, 0.0f),
			new Vector3 (0.0f, -1.0f, 0.0f),
			new Vector3 (0.0f, -1.0f, 0.0f),
			new Vector3 (0.0f, -1.0f, 0.0f),

			new Vector3 (0.0f, 0.0f, -1.0f),
			new Vector3 (0.0f, 0.0f, -1.0f),
			new Vector3 (0.0f, 0.0f, -1.0f),
			new Vector3 (0.0f, 0.0f, -1.0f)
		};
	}

	private int[] getIndexData() {
		return new int[] {
			0, 1, 2, 0, 2, 3,   // front
			4, 5, 6, 4, 6, 7,   // right
			8, 9, 10, 8, 10, 11,    // top
			12, 13, 14, 12, 14, 15, // left
			16, 17, 18, 16, 18, 19, // bottom
			20, 21, 22, 20, 22, 23  // back
		};
	}
}

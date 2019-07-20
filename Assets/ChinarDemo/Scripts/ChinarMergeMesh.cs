using UnityEngine;


/// <summary>
/// 合并网格
/// </summary>
public class ChinarMergeMesh : MonoBehaviour
{

	public Material testMateria;

    void Start() {
        MergeMesh();
    }


    /// <summary>
    /// 合并网格
    /// </summary>
    private void MergeMesh() {
        MeshFilter[]      meshFilters      = GetComponentsInChildren<MeshFilter>();
        CombineInstance[] combineInstances = new CombineInstance[meshFilters.Length];
        for (int i = 0; i < meshFilters.Length; i++) {
            combineInstances[i].mesh      = meshFilters[i].sharedMesh;
            combineInstances[i].transform = meshFilters[i].transform.localToWorldMatrix;
        }
        Mesh newMesh = new Mesh();
        newMesh.CombineMeshes(combineInstances);
        gameObject.AddComponent<MeshFilter>().sharedMesh = newMesh;

        #region 以下是对新模型做的一些处理：添加材质，关闭所有子物体，添加自转脚本和控制相机的脚本

        foreach (Transform t in transform)
        {
            t.gameObject.SetActive(false);
        }

		gameObject.AddComponent<MeshRenderer>().material = testMateria;
        #endregion
    }
}
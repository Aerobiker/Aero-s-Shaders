using UnityEngine;

public class EnableDepth : MonoBehaviour
{
    void Start()
    {
        Camera camera = GetComponent<Camera>();
        camera.depthTextureMode = DepthTextureMode.Depth;
    }
}
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

[ExecuteAlways]

public class SimpleController : MonoBehaviour
{
    [SerializeField] private Material ProximityMaterial;
    [SerializeField] private Material ProximityMaterial2;

    private static int PlayerPosID = Shader.PropertyToID("_PlayerPosition");
    private static int PlayerPosID2 = Shader.PropertyToID("_PlayerPosition2");

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 movement = Vector3.zero;

        if (Input.GetKey(KeyCode.A))
            movement += Vector3.left;

        if (Input.GetKey(KeyCode.W))
            movement += Vector3.forward;

        if (Input.GetKey(KeyCode.D))
            movement += Vector3.right;

        if (Input.GetKey(KeyCode.S))
            movement += Vector3.back;

        transform.Translate(Time.deltaTime * 5 * movement.normalized, Space.World);


        if(ProximityMaterial != null)
            ProximityMaterial.SetVector(PlayerPosID, transform.position);

        if(ProximityMaterial2 != null)
            ProximityMaterial2.SetVector(PlayerPosID2, transform.position);
    }
}

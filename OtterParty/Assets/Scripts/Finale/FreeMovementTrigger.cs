using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FreeMovementTrigger : MonoBehaviour
{
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
            PlayerController p = other.gameObject.GetComponent<PlayerController>();
            var rgd = other.gameObject.GetComponent<Rigidbody>();
            rgd.constraints = RigidbodyConstraints.FreezeRotationX | RigidbodyConstraints.FreezeRotationY | RigidbodyConstraints.FreezeRotationZ;
            if(p.PlayerGun != null)
                p.PlayerGun.SetActive(false);
            p.Transition<MovingState>();
        }
    }
}

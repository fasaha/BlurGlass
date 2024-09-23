using UnityEngine;

public class Move : MonoBehaviour
{
    public float minY = -5f;
    public float maxY = 5f;
    public float moveSpeed = 0.5f;
    private void Update()
    {
        var pos = transform.position;
        pos.y += moveSpeed * Time.deltaTime;
        if(pos.y > maxY)
        {
            pos.y = minY;
        }
        transform.position = pos;
    }
}

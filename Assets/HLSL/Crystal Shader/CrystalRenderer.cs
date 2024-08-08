using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class CrystalRenderer : MonoBehaviour {

    // 1. INTRO
    // Familiarize yourselves with the project:
    // What Scripts do we have?
    // What does CrystalRenderer do?
    // How is our Crystal rendered?

    // 2. SHADER TASKS
    // I) Lets start by giving our Crystal a nice Color Gradient going from Top to Bottom
    // Add 2 Color values that we can adjust from the inspector. You can also make the "horizon" adjustable from the inspector.
    // v

    // II) Our Crystal should be semi-transparent, lets adjust the {Tags} and add an adjustable Value for Transparency
    // ( Hint: Remember what you've learned about the depth buffer and Blending operations )
    // v

    // III) Create the illusion that our crystal is floating a little ~up and down~ in space
    // What is the advantage of doing this in our shader instead of CPU-side?
    // v

    // IV) A Gradient is nice but it can be better. Let's add a little bit of randomness to how we paint our "top color"
    // You can use the Noise Texture in the Textures Folder, to do that you will need to pass the UVs from our vertex to our fragment shader stage
    //v

    // V) It is time for a little bit of ~* mystery *~
    // How could we make our crystal look like there is something "swirling" around in it.
    // ( Hint: We are using a noise texture to sample our color. But what if we would do this multiple times but we change the UVs a little for each? )
    // Don't be scared to play around! You can also use Noise to manipulate our Transparency Value or to add a new Color
    // v
    
    // 3. Bonus Round: CPU-SIDE TASKS
    // I) Our Crystal looks great! We should have more of them. Many, many more... Let's change the Draw Call to DrawMeshInstanced
    // What do we need to change in the Shader?
    // What new Data do we need to give to our function?
    
    // 4. Bonus Bonus Round: EMISSION
    // It would be really nice if our Crystal could create a little bit of *glow*.
    // There are multiple ways to approach this task. ( Hint: You can use one of the PostProcessing Packages for example )
    
    [SerializeField] private Material    _material;
    [SerializeField] private Mesh        _mesh;
    [SerializeField] private CameraEvent _drawInjectionAtCameraEvent = CameraEvent.BeforeForwardOpaque;

    private CommandBuffer                     _commandBuffer;
    private Dictionary<Camera, CommandBuffer> _cameras = new Dictionary<Camera, CommandBuffer>();


    private Matrix4x4 _objectWorldMatrix;


    void Awake() {

        _objectWorldMatrix = transform.localToWorldMatrix;
    }

    // ------------------------------ DRAW CALL ------------------------------
    private void OnWillRenderObject() {

        bool isActive = gameObject.activeInHierarchy && enabled;
        if ( !isActive ) {
            OnDisable();
            return;
        }

        var cam = Camera.current;
        if ( !cam )
            return;

        // PASS
        DrawCrystal( cam );
    }

    private void DrawCrystal( Camera cam ) {

        if ( _cameras.ContainsKey( cam ) ) return;

        // Initialize the CommandBuffer
        _commandBuffer = new CommandBuffer();
        _commandBuffer.name = "CommandBuffer Crystal";
        _cameras[cam] = _commandBuffer;

        // Set Draw Pass
        _material.SetPass( 0 );
        _commandBuffer.DrawMesh( _mesh, _objectWorldMatrix, _material, 0, -1 );

        // Add CommandBuffer to camera
        cam.AddCommandBuffer( _drawInjectionAtCameraEvent, _commandBuffer );
    }
    // ----------------------------------------------------------------------------------------

    private void OnDisable() {

        foreach ( var cam in _cameras ) {
            if ( cam.Key ) cam.Key.RemoveCommandBuffer( _drawInjectionAtCameraEvent, cam.Value );
        }
    }
}
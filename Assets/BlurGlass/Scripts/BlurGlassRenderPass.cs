using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace BlurGlass
{
    public class BlurGlassRenderPass : ScriptableRenderPass
    {
        private Material _blurMat;
        private RenderTexture _blurRt;
        private RenderTargetIdentifier _source;
        private RTHandle _tempRTHandle1;
        private RTHandle _tempRTHandle2;

        private int _iterations;
        private float _blurSize;
        private int _downSample;
        private int _offsetsID;

        public BlurGlassRenderPass(BlurGlassRenderPassFeature.Settings param)
        {
            renderPassEvent = param.renderEvent;
            _blurMat = param.blurMat;
            _iterations = param.blurIterations;
            _downSample = param.blurDownSample;
            _blurSize = param.blurSize;
            _blurRt = param.blurRT;
            _offsetsID = Shader.PropertyToID("offsets");
        }

        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            base.OnCameraSetup(cmd, ref renderingData);
            _source = renderingData.cameraData.renderer.cameraColorTargetHandle;

            float scaleFactor = 1f / Mathf.Pow(2, _downSample);
            RenderTextureDescriptor blitTargetDescriptor = renderingData.cameraData.cameraTargetDescriptor;
            blitTargetDescriptor.depthBufferBits = 0;
            blitTargetDescriptor.colorFormat = RenderTextureFormat.Default;

            RenderingUtils.ReAllocateIfNeeded(ref _tempRTHandle1, new Vector2(scaleFactor, scaleFactor), in blitTargetDescriptor, FilterMode.Bilinear, TextureWrapMode.Clamp);
            RenderingUtils.ReAllocateIfNeeded(ref _tempRTHandle2, new Vector2(scaleFactor, scaleFactor), in blitTargetDescriptor, FilterMode.Bilinear, TextureWrapMode.Clamp);
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get();
            RenderTextureDescriptor opaqueDesc = renderingData.cameraData.cameraTargetDescriptor;
            opaqueDesc.depthBufferBits = 0;
            cmd.Blit(_source, _tempRTHandle1);
            for (int i = 0; i < _iterations; ++i)
            {
                float x = _blurSize / Screen.width;
                float y = _blurSize / Screen.height;
                cmd.SetGlobalVector(_offsetsID, new Vector2(x, 0));
                cmd.Blit(_tempRTHandle1, _tempRTHandle2, _blurMat);
                cmd.SetGlobalVector(_offsetsID, new Vector2(0, y));
                cmd.Blit(_tempRTHandle2, _tempRTHandle1, _blurMat);
            }
            cmd.Blit(_tempRTHandle1, _blurRt);
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
            if(Application.isPlaying)
            {
                _tempRTHandle1.Release();
                _tempRTHandle2.Release();
            }
            
        }


    }

}

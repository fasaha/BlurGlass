using UnityEngine;
using UnityEngine.Rendering.Universal;
namespace BlurGlass
{
    public class GlassBlurRenderPassFeature : ScriptableRendererFeature
    {
        [System.Serializable]
        public class Settings
        {
            public RenderPassEvent renderEvent = RenderPassEvent.BeforeRenderingPostProcessing;
            public LayerMask layerMask = -1;

            public Material blurMat;
            public RenderTexture blurRT;
            public int blurIterations = 3;
            public int blurDownSample = 2;
            public float blurSize = 3f;
        }

        GlassBlurRenderPass m_ScriptablePass;
        public Settings settings;
        public override void Create()
        {
            m_ScriptablePass = new GlassBlurRenderPass(settings);
            m_ScriptablePass.renderPassEvent = settings.renderEvent;
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            renderer.EnqueuePass(m_ScriptablePass);
        }
    }
}


# Aero's Shaders
A repository containing almost all the shaders I have made and their tools, eventually optimized for VRC. (And many useful resources)

> [!IMPORTANT]
> This repository will receive rare updates, since I have other projects in mind

## Files
> [!NOTE]
> All shaders marked with "⨻" do not have VR or instancing support

- Advanced shaders
  - Pseudo Encryption ⇒ Shader pair that allows you to encrypt and decrypt with keys, the screen of the player looking into the object/shader
- Functional shaders
  - Night Vision V3 ⇒ Shader allowing players to see in the dark with depth or
colour.
  - ~~Vertex Repainter ⇒ Shader that allows the mixing of multiple textures and shaders onto a single material, by using multiple UV coordinates or vertex paint masks~~
- Old shaders (No manual/instructions on use)
  - Aer Effects ⨻ ⇒ Multi purpose shader, very capable, not very efficient.
  - Lens Distort ⨻ ⇒ Simulates one side of a lens (facing the camera/player), and emulates the diffraction/refraction of the lens.
  - Super Emitter ⇒ Draws a sprite that always faces the player, and can be customized in various ways. (The object used influences the visibility)
  - Space Distortion ⇒ You can make something that is similar to a black hole, being able to spin, and change
colours. (The object used influences the visibility)
  - Simple Zoom (Not THAT simple) ⇒ Allows you to zoom onto things, with blending options and shading options to make the most unique glasses or magic objects.
  - 7 colour Gradient (prototype) ⨻ ⇒ A simple prototype for a procedurally generated Multicolour Gradient (Failed)
- Universal Tools And Resources
  - ~~Custom UI elements~~
  - ~~Utility Testing V0.1 ⇒ Compilation of many different possible code parts to compute different parts of a shader (somewhat standardised)~~

> Sometimes my naming scheme can confuse people, this may change in the future

## Nice References And Resources
### Links
One of my main resources is the Unity Forum ([example](https://forum.unity.com/threads/world-normal-from-scene-depth.1063625/)), since many of the possible questions have already been answered in the past. Another site to visit a lot, is [ShaderToy](https://www.shadertoy.com/), a platform for shader makers to share their artistic creations. You can easily find inspiration there. And finally, don't forget to know your [Unity documentation](https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html) well before delving too deep (or just have it on another screen).
- [cnlohr's compilation of useful shader tricks](https://github.com/cnlohr/shadertrixx)
- [Official Microsoft performance recommendations for Unity](https://learn.microsoft.com/en-us/windows/mixed-reality/develop/unity/performance-recommendations-for-unity)
- [Unity reference to the VR "problem" of Single Pass Stereo Rendering](https://docs.unity.cn/550/Documentation/Manual/SinglePassStereoRendering.html)
- [Acerola : Content creator of fun Shader related videos, pushing boundaries each time](https://www.youtube.com/c/Acerola_t/videos)
- [Acerola : Github repo, quicker than searching through videos](https://github.com/GarrettGunnell)
- [SimonDev : Content creator for technical videos in shader related topics](https://www.youtube.com/channel/UCEwhtpXrg5MmwlH04ANpL8A)
- [SimonDev : GLSL course on teachables](https://simondev.teachable.com/p/glsl-shaders-from-scratch)
- [Sayiarin's Avatar tools is a collection of optimized and practical tools and shaders for your avatars](https://gitlab.com/sayiarin/sayiavatartools)
- [An Intro into SSS (Sub Surface Scattering)](https://therealmjp.github.io/posts/sss-intro/)
- [VERY good tutorial site for shaders, c# and other stuff related to unity (Catlike Coding)](https://catlikecoding.com/unity/tutorials/)
- [nidorx's huge library of MatCap Textures](https://github.com/nidorx/matcaps)
- [marcozakaria's collection of unique shaders for URP](https://github.com/marcozakaria/URP-LWRP-Shaders)
- [csdjk's huge tutorial on all kinds of shaders (Biggest repo I know of, with so many amazing shaders)](https://github.com/csdjk/LearnUnityShader)
- [Inigo Quilez : The amazing artist of raymarching](https://iquilezles.org/) (ShaderToy : https://www.shadertoy.com/user/iq)
- [Ben Golus (aka "bgolus") : The legend of the unity shader forums](https://bgolus.medium.com/)
- [Neitri's Shaders, a compilation of impressive technical chaders](https://github.com/netri/Neitri-Unity-Shaders)
- [madjin's "One-stop shop" for VRC content creators](https://github.com/madjin/awesome-vrchat)
- [mekanoe's Shaders, just a bunch of different shaders](https://github.com/mekanoe/shaders)
- [RealTimeRendering.com has many books and other good resources](https://www.realtimerendering.com/)

### Books (+link)
I would recommend to check out all the "__On website__" books, since they often have acces to code (you may need to search a bit to find the repos, often on Github).
- ◈"***GPU Gems 1***" ; Nvidia : https://developer.nvidia.com/gpugems/gpugems/ (Has code files, __on website__)
- ◈"***GPU Gems 2***" ; Nvidia : https://developer.nvidia.com/gpugems/gpugems2/ (Has code files, __on website__)
- ◈"***GPU Gems 3***" ; Nvidia : https://developer.nvidia.com/gpugems/gpugems3/ (Has code files, __on website__)
- "***Unity Shaders and Effects Cookbook***" ; Kenny Lammers : https://github.com/PacktPublishing/Unity-2021-Shaders-and-Effects-Cookbook-Fourth-Edition (Alternate Book Link, by John P. Doran)
- "***Real-Time Rendering, Fourth Edition***" ; Tomas Akenine-Möller et al. : https://www.realtimerendering.com/ __(On website)__
- "***Ray Tracing Gems, High-Quality And Real-Time Rendering With DXR and other API's***" ; Nvidia ;  Eric Haines & Tomas Akenine-Möller : https://www.realtimerendering.com/ (Free download)
- "***Ray Tracing Gems 2, Next generation Real-time Rendering With DXR, Vulkan And Optix***" ; Nvidia ; Adam Marrs & Petter Shirley & Ingo Wald : https://www.realtimerendering.com/ (Free download)
- "***Practical Shader Development, Vertex and Fragment Shaders for Game Developers***" ; Kyle Halladay : https://link.springer.com/book/10.1007/978-1-4842-4457-9 (Free for institutions)
- ◈"***Physically Based Rendering, From Theory to Implementation, Third Edition***" ; Matt Pharr & Greg Humphreys : https://www.pbr-book.org/3ed-2018/contents __(On website)__
- "***Physically based shader development for unity 2017, Develop custom lighting systems***" ; Claudia Doppioslash : https://link.springer.com/book/10.1007/978-1-4842-3309-2 (Free for institutions)
- ◈"***HLSL Development Cookbook, Implement stunning 3D rendering techniques using the power of HLSL and DirectX 11***" ; Doron Feinstein : https://www.amazon.com/HLSL-Development-Cookbook-Doron-Feinstein/dp/1849694206 (Couldn't find another link, but I got the PDF through my institution for free)
- "***Foundations of Game engine development, Volume 1, Mathematics***" ; Terathon Software LLC : https://foundationsofgameenginedev.com/ (__On website__, ALL VOLUMES)
- ◈"***Computer graphics through OpenGl, from theory to experiments, Third Edition***" ; Sumanta Guha : https://www.amazon.com/Computer-Graphics-Through-OpenGL%C2%AE-Experiments/dp/1138612642 (Couldn't find another link, but I got the PDF through my institution for free)
- "***Visual Texture, Accurate Material Appearance Measurement, Representation and Modeling***" ; Michal Haindl : https://link.springer.com/book/10.1007/978-1-4471-4902-6 (Free for institutions)
- "***3D Mesh Processing and Character Animation, With Examples using OpenGL, OpenMesh and Assimp***" ; Ramakrishnan Mukundan : https://link.springer.com/book/10.1007/978-3-030-81354-3 (Free for institutions)

> I tried to be as precise as possible, but writing exact references is a skill I have yet to master

>The Little Diamond ◈ Means I recommend it, of course, its a bit subjective, but still.

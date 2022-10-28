# Aero's Shaders
A repository of my own shaders for unity (optimized for VRC)

## Shaders

> ⚠ Some may have problems displaying in vr (since unity now uses a stereo camera)

- 7 Color Gradient (poorly designed)
  + Creates a gradient in the x axis of the UV's, you can choose how many colors to consider for the gradient (the mixing is a bit wonkey)
- Aer Effects
  + Multi purpose shader, very capable, not very efficient. Just a mish mash of a lot of possible implementations
- Lens Distort
  + Simulates only on the visible side of the geometry, a distortion of the space behind it. (It is not ray tracing, so do not expect over realism)

> ✅ VR Supported shaders

- Super Emitter
  + Displays a image as if it was placed in the origin of the object or with an offset, (it renders in the volume of the object and can clip with its borders). The image always looks at the viewer. 
- Space Distortion
  + Using the same technique than the Super Emitter, you can distort space in the volume of an object, and make a black hole like effect, with distortion through time.


## Nice References
- cnlohr's useful shader trix : https://github.com/cnlohr/shadertrixx
- Microsoft Performance Recomendations : https://learn.microsoft.com/en-us/windows/mixed-reality/develop/unity/performance-recommendations-for-unity
- Unity reference to the vr problem : https://docs.unity.cn/550/Documentation/Manual/SinglePassStereoRendering.html
- Fun videos on more in depth shader related topics by Acerola: https://www.youtube.com/c/Acerola_t/videos
- Impressively well implemented shader concepts by SimonDev (has courses and repo) : https://www.youtube.com/channel/UCEwhtpXrg5MmwlH04ANpL8A

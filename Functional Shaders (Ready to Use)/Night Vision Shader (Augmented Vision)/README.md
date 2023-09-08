# Night Vision Shader (Augmented Vision)
## Features
- Different Vision Modes
  - The different Modes :
    - 'None' **⇒** Just makes the object transparent (affected by zoom)
    - 'Luminosity Correction' **⇒** Corrects the luminosity of colours, so they become more visible
    - 'BW Black Compensation' **⇒** Corrects the luminosity only, so it becomes black and white like real Night Vision
    - 'Raw luminosity' **⇒** No correction to the luminosity of the scene, useful for gradients.
    - 'Depth' **⇒** Displays the depth of the scene with a certain period, so it stays visible (If in editor, camera must have the "EnableDepth.cs" script[^scriptsource] on it, and be in play mode, more details bellow)
  - Additional options
    - 'Vision Tint' **⇒** Tints the Vision Mode (Can cause problems with the gradients)
    - 'Depth Period' **⇒** Depth is infinite and relies on the far plane of the camera, but here, you can set the "fake far plane" that will then repeat again and again. So you can get visibility on all the space you see.
    - 'Depth & Vision Mix' **⇒** Depth removes all details from meshes, so here, you are multiplying the vision (ideally, the depth vision), with the environment, gaining its colour, wile adding the depth.
- Different Gradients and Support For Custom Gradients (Colormaps)
   - 'None' **⇒** No transformation of the vision.
   - 'JET' **⇒** Makes a sort of gradient from hot to cold (Dark Blue to Dark Red).
   - 'HSV' **⇒** Makes a sort of gradient from cyan to yellow to magenta, with other colours in the middle, Factor 2 makes it cycle faster through the possible colours.
   - 'Modulo' **⇒** Simple modulo operator on the colour, high values of Factor 1 must be compensated with Factor 2
   - 'Image' **⇒** Use custom images/Gradients, look at the [section bellow](#colormaps)
- Zooming Powers And Modes
  - 'Uniform' **⇒** Zooms the screen uniformly
  - 'UV Gaussian' **⇒** Zooms the screen more in the centre of the UV coordinates than outside.
  - 'Fresnel' **⇒** Zooms in correlation to the angle of the surface, meaning, it acts like a lens.
- Overlay Support In Screen-space And UV-space
  - Allows the user to place an overlay in screen-space or uv-space, change its colour and change the alpha value.
- Graphic Settings
  - Don't touch them if you don't really know what to do, since you can make it not render properly.
  - CullMode and ZwriteMode are the easiest one to see/test. (The rest is a bit more annoying)


## <h2 id="colormaps"> Some Good Colormaps (Gradients) </h2>
Get a bunch of quality (image format) colormaps from [Flimsyhat's WebGl generator post](https://observablehq.com/@flimsyhat/webgl-color-maps) or get a bunch of official colormaps from  the [NCAR Gallery](https://www.ncl.ucar.edu/Document/Graphics/color_table_gallery.shtml) (small images).
- JET (Already Implemented)
- [MPL_gist_ncar](https://www.ncl.ucar.edu/Document/Graphics/ColorTables/MPL_gist_ncar.shtml) (Very segmented, good visibility)
- Inferno
- Plasma
- Viridis

Link to a Visualisation site : https://www.kennethmoreland.com/color-advice/

## Examples and Images
<img src="./README%20Image%20Folder/Lum%20Cor,%20Darkness%20compare.PNG" alt="drawing" height="400"/><img src="./README%20Image%20Folder/Raw Lum, JET, Darkness Visualisation.PNG" alt="drawing" height="400"/>

<img src="./README%20Image%20Folder/VR Camera In Play, Default Example Material.PNG" alt="drawing" width="600"/>
<img src="./README%20Image%20Folder/Default Depth stereoscopic.PNG" alt="drawing" width="600"/>
<img src="./README%20Image%20Folder/Depth With JET.PNG" alt="drawing" width="600"/>
<img src="./README%20Image%20Folder/Jet Stereo Mix Vision.PNG" alt="drawing" width="600"/>
<img src="./README%20Image%20Folder/Good and visible custom setup (example).PNG" alt="drawing" width="600"/>

## Additional Info

⚠ **WARNING** ⚠ Camera depth may not be enabled is some cases, causing the depth view to not work ! The camera must have its "_CameraDepthTexture" declared globally to work even in the editor. For that, you must **add on any main camera**  (normal or stereoscopic) the "EnableDepth.cs" script[^scriptsource].

[^scriptsource]: Source of the script : https://www.youtube.com/watch?v=yUVrtPCsCb0, reply to comment from @matthewmartin8655, from @kpickett9128.

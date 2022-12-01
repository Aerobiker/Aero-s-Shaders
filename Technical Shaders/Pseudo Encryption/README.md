# Encryption and decryption shaders

## Table of Content
 - [Foreword](#foreword)
 - [The Editor](#the-editor)
 - [VR Appearance](#vr-appearance)
 - [Interaction Between Both Shaders](#shader-interaction)
 - [Pixel Data Change With Time](#pixel-change)

> 🌐 All code related credits are inside the code of both shaders, please do look them up for more information.


## <h2 id="foreword"> Foreword </h2>
> **Warning**
> ⚠️ This is by no means a serious shader meant for secretive or illegal use. The security of this project should be quite insignificant, and is relatively easy to reverse (as it uses a cobination of xor opperations and simple hash functions). 

> **Note**
> - The decryption of the rendered image is very noisy, and can make people in VR get sick, this is why you should <ins>**ALWAYS**</ins> set a <ins>**GOOD RANGE**</ins> on the shields of <ins>**BOTH**</ins> shaders !
> - Standalone users should always be wary. People have reported that the compression gets really messy, and the frame time plummets, but there will be denoising of the deciphered image as artefact of the video compression. They found that this could lead to some dizziness if exposed for long period of times. So, please take care of ignorant people by seting <ins>**GOOD RANGES**</ins> on the shields of <ins>**BOTH**</ins> shaders !


## <h2 id="the-editor"> The Editor </h2>

### Parameters
 - Base Settings     
   - `Activate shield`  -> :warning: Toggles the rendering of shaded geometry to avoid seeing the encrypted pixels throught **EVERYTHING**.
   - `Shield Range`     -> :warning: Regulates the distance falloff of the "shield", to make the effect appear.

 - Shading Settings
   - `Shading Mode`     -> Choose between unlit (uses base color), Realistic (Blinn-Phong) and Goosh ( more contrast, stylized). 
   - `Base Color`       -> Base color of the object, used in all shading modes.
   >
   - `Specular Factor`  -> How much light is reflected by the surface of the object (no energy conservation).
   - `Specular Power`   -> Power of the light reflected, must be set with "Specular Factor" to avoid weird behavior.
   - `Diffuse Color`    -> Color of the diffused light reflected by the geometry.
   - `Specular Color`   -> Color of the bounced light (most of the times white, but the light sources affect it.
   >
   - `Goosh Cool Color`  -> Color of the shade.
   - `Goosh Warm Color`  -> Color of the reflection.
   - `Goosh Alpha`       -> Influence of the shade color.
   - `Goosh Betar`       -> Influence of the relfection color.
   - `Goosh Specular`    -> How much light is reflected by the surface of the object (no energy conservation).
   - `Goosh Specular Power` -> Power of the light reflected, must be set with "Goosh Specular" to avoid weird behavior.

 - Encryption/Decryption Keys
   - `Key Selector`      -> Selects one of the 21 available keys (different encryption keys).
   - `Public Key`        -> Unchangeable "public" key (it can't be changed easily, mostly for interaction between players with the shader).
   - `Key 1 -> 20`       -> User assingeable encryption/decrytpion keys (they must match), they must be between -2<sup>32</sup> and 2<sup>32</sup>.

### Editor Images
Encryption Shader Editor   |  Dencryption Shader Editor
:----------------------------------------------------:|:-----------------------------------------------------:
![Encryption Editor](Images/Encryption%20Editor.PNG)  |  ![Decryption Editor](Images/Decryption%20Editor.PNG)

### Full tour of the shader
> **Note**
> I am very sorry about the artefacts, but they do help to see where the mouse cursor has visited !

https://user-images.githubusercontent.com/116542129/204908200-61794d44-316d-4253-8acf-f77cf09b1091.mp4




## <h2 id="vr-appearance"> VR Appearance </h2>
As mentioned before, the images rendered by this shader, stays <ins>**STILL**</ins> on both eyes, and can cause dizziness. This is why i can't stress this enough, please put good shields for the other people and for yourself ! 

https://user-images.githubusercontent.com/116542129/204908190-012bd6b9-7d91-4828-b12e-c1dd4eccc760.mp4




## <h2 id="shader-interaction"> Interaction Between Both Shaders </h2>

With interaction | Without interaction
:-----------------------------------------------------------:|:-----------------------------------------------------------------:
![Layered objects](Images/Merged%20Shading.PNG)              |  ![Side by side objects](Images/Encryption%20and%20decryption.PNG)
![Layered objects](Images/Decryption%20of%20encryption.PNG)  |  ![Side by side objects](Images/Inside%20range%20for%20both.PNG)
![Layered objects](Images/Encryption%20and%20decryption%20anim.gif)  |  ![Side by side objects](Images/Side%20by%20side%20anim.gif)


## <h2 id="pixel-change"> Pixel Data Change With Time </h2>
Pixels have been made to change with time to make a bit of variation to a still easy to decipher image, so using the "shader time" we add a bit of salt to the key, and get every 10 frames more or less, a completely new image !

:warning: Please keep in mind that this can affect greatly the compression on quest or other stand-alone devices that need video compression to work.




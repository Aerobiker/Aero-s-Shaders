# Encryption and decryption shaders

## Table of Content
 - [Foreword](#foreword)
 - [The Editor](#the-editor)
 - [VR Appearance](#vr-appearance)
 - [Interaction Between Both Shaders](#shader-interaction)
 - [Pixel Data Change With Time](#pixel-change)




## <h3 id="foreword"> Foreword </h3>
> **Warning**
> This is by no means a serious shader meant for secretive or illegal use. The security of this project should be quite insignificant, and is relatively easy to reverse. 

> **Note**
> The decryption of the rendered image is very noisy, and can make people in VR get sick, this is why you should <ins>**ALWAYS**</ins> set a <ins>**GOOD RANGE**</ins> on the shields of <ins>**BOTH**</ins> shaders !


## <h3 id="the-editor"> The Editor </h3>

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




## <h3 id="vr-appearance"> VR Appearance </h3>

https://user-images.githubusercontent.com/116542129/204908190-012bd6b9-7d91-4828-b12e-c1dd4eccc760.mp4




## <h3 id="shader-interaction"> Interaction Between Both Shaders </h3>

With interaction | Without interaction
:-----------------------------------------------------------:|:-----------------------------------------------------------------:
![Layered objects](Images/Decryption%20of%20encryption.PNG)  |  ![Side by side objects](Images/Encryption%20and%20decryption.PNG)
/                                                            |  ![Side by side objects](Images/Inside%20range%20for%20both.PNG)



## <h3 id="pixel-change"> Pixel Data Change With Time </h3>

https://user-images.githubusercontent.com/116542129/204908129-1dded560-59ab-4d79-a019-35d8f1fb8660.mp4

https://user-images.githubusercontent.com/116542129/204908174-97164ec5-8b74-46ab-80b4-4ef9d38fc1a3.mp4




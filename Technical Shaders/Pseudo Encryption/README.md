# Encryption and decryption shaders

> **Warning**
> This is by no means a serious shader meant for secretive or illegal use. The security of this project should be quite insignificant, and is easilly possible to reverse it (here are some ideas [^1]). 

> **Note**
> The decryption of the rendered image is very noisy, and can make people in VR get sick, this is why you should **ALWAYS** set a **GOOD RANGE** on the shields of **BOTH** shaders !

Encryption Shader Editor   |  Dencryption Shader Editor
:-------------------------:|:-------------------------:
![Encryption Editor](Images/Encryption%20Editor.PNG)  |  ![Decryption Editor](Images/Decryption%20Editor.PNG)


With interaction           |  Without interaction
:-------------------------:|:-------------------------:
![Encryption Editor](Images/Decryption%20of%20encryption.PNG)  |  ![Decryption Editor](Images/Encryption%20and%20decryption.PNG)
/  |  ![Decryption Editor](Images/Inside%20range%20for%20both.PNG)


<p align="center" width="100%">
    The interaction of both shaders<br>
    <video width="33%" src = "https://user-images.githubusercontent.com/116542129/204908129-1dded560-59ab-4d79-a019-35d8f1fb8660.mp4"></video>
    <img width="33%" src="Images/Decryption%20of%20encryption.PNG">
</p>

https://user-images.githubusercontent.com/116542129/204908129-1dded560-59ab-4d79-a019-35d8f1fb8660.mp4

https://user-images.githubusercontent.com/116542129/204908174-97164ec5-8b74-46ab-80b4-4ef9d38fc1a3.mp4


https://user-images.githubusercontent.com/116542129/204908190-012bd6b9-7d91-4828-b12e-c1dd4eccc760.mp4



https://user-images.githubusercontent.com/116542129/204908200-61794d44-316d-4253-8acf-f77cf09b1091.mp4




Encryption Shader Editor   |  Dencryption Shader Editor
:-------------------------:|:-------------------------:
  |  ![Decryption Editor](Images/Decryption%20Editor.PNG)

[^1]: **Reversing the key** : One approach to find the secret key(s), is to simply know when the picture was taken (in shader time) and just bruteforce the 2^32 possible keys. To check if you have the right key, doing a blur and checking if the color corresponds to the blurred color outside the shape, or any color different to pure black/white/red/green/blue.

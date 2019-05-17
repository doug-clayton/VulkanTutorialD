# Triangle Example with D Language (dlang) and Vulkan 1.1.106.0
May 17th 2019

This example app shows how you can use Vulkan with the D language to create your own applications!
All of the code has been adapted from the wonderful tutorial at: https://vulkan-tutorial.com

The code in this example stops at https://vulkan-tutorial.com/Drawing_a_triangle/Swap_chain_recreation because I didn't want to force anyone to reuse my math libraries or any of my other custom code to get this running.

![Example Image](/example.png)

#Notes
* This has only been tested on Windows 10, as this is the only OS I run. 
* You may need to make some changes in order to get everything working on other platforms. 
    * The static libraries in "libs" and the dynamic libraries in "bin" will definitely need to be swapped out for the platform specific versions.

#Requirements
* DMD 2.086.0 or higher
* DUB 1.11.0 or higher
* Vulkan 1.1.106.0 or higher compatible drivers and a compatible video card

# Third Party Bindings created for this project (using DStep + manual changes):
* GLFW 3.3 https://www.glfw.org
* Vulkan SDK 1.1.106.0 https://vulkan.lunarg.com

#Instructions for use
* Make sure that the GLFW.dll and all of the VK layer files are located in the output directory! (Currently "bin/")
* Make sure that the libglfw3dll.a and vulkan-1.lib files are located in the "libs" directory.
* Update the two strings in resources\shaders\compile.bat to point to glslangValidator.exe on your machine. (E.g., "C:\VulkanSDK\VersionNumber\Bin\glslangValidator.exe") This will allow you to convert GLSL shaders to SPIRV.

* To build the project from command line, at the top level folder, use this command: "dub build --build=debug"
* To debug in Visual Studio Code, please install the "Native Debug" extension and either the "Dlang" or D "Programming Language (code-d)" extension to support debugging with the cppvsdbg.
    * The app already has a launch.json and tasks.json set up to debug.
* Run app.exe in the bin folder and you should hopefully see a window with a triangle in it.
* Happy coding!

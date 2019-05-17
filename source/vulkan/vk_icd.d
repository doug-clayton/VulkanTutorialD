//
// File: vk_icd.h
//
/*
 * Copyright (c) 2015-2016 The Khronos Group Inc.
 * Copyright (c) 2015-2016 Valve Corporation
 * Copyright (c) 2015-2016 LunarG, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */
module vk_icd;

import core.sys.windows.windows;
import vulkan;

extern (System):

// Loadimport core.stdc.stdint;

// Loader-ICD version negotiation API.  Versions add the following features:
//   Version 0 - Initial.  Doesn't support vk_icdGetInstanceProcAddr
//               or vk_icdNegotiateLoaderICDInterfaceVersion.
//   Version 1 - Add support for vk_icdGetInstanceProcAddr.
//   Version 2 - Add Loader/ICD Interface version negotiation
//               via vk_icdNegotiateLoaderICDInterfaceVersion.
//   Version 3 - Add ICD creation/destruction of KHR_surface objects.
//   Version 4 - Add unknown physical device extension qyering via
//               vk_icdGetPhysicalDeviceProcAddr.
//   Version 5 - Tells ICDs that the loader is now paying attention to the
//               application version of Vulkan passed into the ApplicationInfo
//               structure during vkCreateInstance.  This will tell the ICD
//               that if the loader is older, it should automatically fail a
//               call for any API version > 1.0.  Otherwise, the loader will
//               manually determine if it can support the expected version.
enum CURRENT_LOADER_ICD_INTERFACE_VERSION = 5;
enum MIN_SUPPORTED_LOADER_ICD_INTERFACE_VERSION = 0;
enum MIN_PHYS_DEV_EXTENSION_ICD_INTERFACE_VERSION = 4;
alias PFN_vkNegotiateLoaderICDInterfaceVersion = VkResult function(uint* pVersion);

// This is defined in vk_layer.h which will be found by the loader, but if an ICD is building against this
// file directly, it won't be found.

alias PFN_GetPhysicalDeviceProcAddr = void function(VkInstance instance, const(char)* pName) function(VkInstance instance, const(char)* pName);

/*
 * The ICD must reserve space for a pointer for the loader's dispatch
 * table, at the start of <each object>.
 * The ICD must initialize this variable using the SET_LOADER_MAGIC_VALUE macro.
 */

enum ICD_LOADER_MAGIC = 0x01CDC0DE;

union VK_LOADER_DATA
{
    uint* loaderMagic;
    void* loaderData;
}

void set_loader_magic_value(void* pNewObject);

bool valid_loader_magic_value(void* pNewObject);

/*
 * Windows and Linux ICDs will treat VkSurfaceKHR as a pointer to a struct that
 * contains the platform-specific connection and surface information.
 */
alias VkIcdWsiPlatform = uint;
enum : VkIcdWsiPlatform
{
    VK_ICD_WSI_PLATFORM_MIR = 0,
    VK_ICD_WSI_PLATFORM_WAYLAND = 1,
    VK_ICD_WSI_PLATFORM_WIN32 = 2,
    VK_ICD_WSI_PLATFORM_XCB = 3,
    VK_ICD_WSI_PLATFORM_XLIB = 4,
    VK_ICD_WSI_PLATFORM_ANDROID = 5,
    VK_ICD_WSI_PLATFORM_MACOS = 6,
    VK_ICD_WSI_PLATFORM_IOS = 7,
    VK_ICD_WSI_PLATFORM_DISPLAY = 8
}

struct VkIcdSurfaceBase
{
    VkIcdWsiPlatform platform;
}

// VK_USE_PLATFORM_MIR_KHR

// VK_USE_PLATFORM_WAYLAND_KHR

// VK_USE_PLATFORM_WIN32_KHR
struct VkIcdSurfaceWin32
{
    VkIcdSurfaceBase base;
    HINSTANCE hinstance;
    HWND hwnd;
}
// VK_USE_PLATFORM_XCB_KHR

// VK_USE_PLATFORM_XLIB_KHR

// VK_USE_PLATFORM_ANDROID_KHR

// VK_USE_PLATFORM_MACOS_MVK

// VK_USE_PLATFORM_IOS_MVK

struct VkIcdSurfaceDisplay
{
    VkIcdSurfaceBase base;
    VkDisplayModeKHR displayMode;
    uint planeIndex;
    uint planeStackIndex;
    VkSurfaceTransformFlagBitsKHR transform;
    float globalAlpha;
    VkDisplayPlaneAlphaFlagBitsKHR alphaMode;
    VkExtent2D imageExtent;
}

// VKICD_H

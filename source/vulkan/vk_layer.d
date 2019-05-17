//
// File: vk_layer.h
//
/*
 * Copyright (c) 2015-2017 The Khronos Group Inc.
 * Copyright (c) 2015-2017 Valve Corporation
 * Copyright (c) 2015-2017 LunarG, Inc.
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

/* Need to define dispatch table
 * Core struct can then have ptr to dispatch table at the top
 * Along with object ptrs for current and next OBJ
 */
module vk_layer;

import vulkan;

extern (System):

enum MAX_NUM_UNKNOWN_EXTS = 250;

// Loader-Layer version negotiation API.  Versions add the following features:
//   Versions 0/1 - Initial.  Doesn't support vk_layerGetPhysicalDeviceProcAddr
//                  or vk_icdNegotiateLoaderLayerInterfaceVersion.
//   Version 2    - Add support for vk_layerGetPhysicalDeviceProcAddr and
//                  vk_icdNegotiateLoaderLayerInterfaceVersion.
enum CURRENT_LOADER_LAYER_INTERFACE_VERSION = 2;
enum MIN_SUPPORTED_LOADER_LAYER_INTERFACE_VERSION = 1;

enum VK_CURRENT_CHAIN_VERSION = 1;

// Typedef for use in the interfaces below
alias PFN_GetPhysicalDeviceProcAddr = void function (VkInstance instance, const(char)* pName) function (VkInstance instance, const(char)* pName);

// Version negotiation values
enum VkNegotiateLayerStructType
{
    LAYER_NEGOTIATE_UNINTIALIZED = 0,
    LAYER_NEGOTIATE_INTERFACE_STRUCT = 1
}

// Version negotiation structures
struct VkNegotiateLayerInterface
{
    VkNegotiateLayerStructType sType;
    void* pNext;
    uint loaderLayerInterfaceVersion;
    PFN_vkGetInstanceProcAddr pfnGetInstanceProcAddr;
    PFN_vkGetDeviceProcAddr pfnGetDeviceProcAddr;
    PFN_GetPhysicalDeviceProcAddr pfnGetPhysicalDeviceProcAddr;
}

// Version negotiation functions
alias PFN_vkNegotiateLoaderLayerInterfaceVersion = VkResult function (VkNegotiateLayerInterface* pVersionStruct);

// Function prototype for unknown physical device extension command
alias PFN_PhysDevExt = VkResult function (VkPhysicalDevice phys_device);

// ------------------------------------------------------------------------------------------------
// CreateInstance and CreateDevice support structures

/* Sub type of structure for instance and device loader ext of CreateInfo.
 * When sType == VK_STRUCTURE_TYPE_LOADER_INSTANCE_CREATE_INFO
 * or sType == VK_STRUCTURE_TYPE_LOADER_DEVICE_CREATE_INFO
 * then VkLayerFunction indicates struct type pointed to by pNext
 */
enum VkLayerFunction_
{
    VK_LAYER_LINK_INFO = 0,
    VK_LOADER_DATA_CALLBACK = 1
}

alias VkLayerFunction = VkLayerFunction_;

struct VkLayerInstanceLink_
{
    VkLayerInstanceLink_* pNext;
    PFN_vkGetInstanceProcAddr pfnNextGetInstanceProcAddr;
    PFN_GetPhysicalDeviceProcAddr pfnNextGetPhysicalDeviceProcAddr;
}

alias VkLayerInstanceLink = VkLayerInstanceLink_;

/*
 * When creating the device chain the loader needs to pass
 * down information about it's device structure needed at
 * the end of the chain. Passing the data via the
 * VkLayerDeviceInfo avoids issues with finding the
 * exact instance being used.
 */
struct VkLayerDeviceInfo_
{
    void* device_info;
    PFN_vkGetInstanceProcAddr pfnNextGetInstanceProcAddr;
}

alias VkLayerDeviceInfo = VkLayerDeviceInfo_;

alias PFN_vkSetInstanceLoaderData = VkResult function (VkInstance instance, void* object);

alias PFN_vkSetDeviceLoaderData = VkResult function (VkDevice device, void* object);

struct VkLayerInstanceCreateInfo
{
    VkStructureType sType; // VK_STRUCTURE_TYPE_LOADER_INSTANCE_CREATE_INFO
    const(void)* pNext;
    VkLayerFunction function_;

    union _Anonymous_0
    {
        VkLayerInstanceLink* pLayerInfo;
        PFN_vkSetInstanceLoaderData pfnSetInstanceLoaderData;
    }

    _Anonymous_0 u;
}

struct VkLayerDeviceLink_
{
    VkLayerDeviceLink_* pNext;
    PFN_vkGetInstanceProcAddr pfnNextGetInstanceProcAddr;
    PFN_vkGetDeviceProcAddr pfnNextGetDeviceProcAddr;
}

alias VkLayerDeviceLink = VkLayerDeviceLink_;

struct VkLayerDeviceCreateInfo
{
    VkStructureType sType; // VK_STRUCTURE_TYPE_LOADER_DEVICE_CREATE_INFO
    const(void)* pNext;
    VkLayerFunction function_;

    union _Anonymous_1
    {
        VkLayerDeviceLink* pLayerInfo;
        PFN_vkSetDeviceLoaderData pfnSetDeviceLoaderData;
    }

    _Anonymous_1 u;
}

VkResult vkNegotiateLoaderLayerInterfaceVersion (VkNegotiateLayerInterface* pVersionStruct);

enum VkChainType
{
    VK_CHAIN_TYPE_UNKNOWN = 0,
    VK_CHAIN_TYPE_ENUMERATE_INSTANCE_EXTENSION_PROPERTIES = 1,
    VK_CHAIN_TYPE_ENUMERATE_INSTANCE_LAYER_PROPERTIES = 2,
    VK_CHAIN_TYPE_ENUMERATE_INSTANCE_VERSION = 3
}

struct VkChainHeader
{
    VkChainType type;
    uint version_;
    uint size;
}

struct VkEnumerateInstanceExtensionPropertiesChain
{
    VkChainHeader header;
    VkResult function (const(VkEnumerateInstanceExtensionPropertiesChain)*, const(char)*, uint*, VkExtensionProperties*) pfnNextLayer;

    const(VkEnumerateInstanceExtensionPropertiesChain)* pNextLink;
}

struct VkEnumerateInstanceLayerPropertiesChain
{
    VkChainHeader header;
    VkResult function (const(VkEnumerateInstanceLayerPropertiesChain)*, uint*, VkLayerProperties*) pfnNextLayer;
    const(VkEnumerateInstanceLayerPropertiesChain)* pNextLink;
}

struct VkEnumerateInstanceVersionChain
{
    VkChainHeader header;
    VkResult function (const(VkEnumerateInstanceVersionChain)*, uint*) pfnNextLayer;
    const(VkEnumerateInstanceVersionChain)* pNextLink;
}

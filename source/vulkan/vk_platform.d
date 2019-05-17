//
// File: vk_platform.h
//
/*
** Copyright (c) 2014-2017 The Khronos Group Inc.
**
** Licensed under the Apache License, Version 2.0 (the "License");
** you may not use this file except in compliance with the License.
** You may obtain a copy of the License at
**
**     http://www.apache.org/licenses/LICENSE-2.0
**
** Unless required by applicable law or agreed to in writing, software
** distributed under the License is distributed on an "AS IS" BASIS,
** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
** See the License for the specific language governing permissions and
** limitations under the License.
*/
module vk_platform;

import core.stdc.config;
import core.sys.windows.windows;
import vulkan_core;

extern (System):

enum VULKAN_WIN32_H_ = 1;

/*
** Copyright (c) 2015-2019 The Khronos Group Inc.
**
** Licensed under the Apache License, Version 2.0 (the "License");
** you may not use this file except in compliance with the License.
** You may obtain a copy of the License at
**
**     http://www.apache.org/licenses/LICENSE-2.0
**
** Unless required by applicable law or agreed to in writing, software
** distributed under the License is distributed on an "AS IS" BASIS,
** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
** See the License for the specific language governing permissions and
** limitations under the License.
*/

/*
** This header is generated from the Khronos Vulkan XML API Registry.
**
*/

enum VK_KHR_win32_surface = 1;
enum VK_KHR_WIN32_SURFACE_SPEC_VERSION = 6;
enum VK_KHR_WIN32_SURFACE_EXTENSION_NAME = "VK_KHR_win32_surface";
alias VkWin32SurfaceCreateFlagsKHR = uint;

struct VkWin32SurfaceCreateInfoKHR
{
    VkStructureType sType;
    const(void)* pNext;
    VkWin32SurfaceCreateFlagsKHR flags;
    HINSTANCE hinstance;
    HWND hwnd;
}

alias PFN_vkCreateWin32SurfaceKHR = VkResult function(VkInstance instance, const(VkWin32SurfaceCreateInfoKHR)* pCreateInfo, const(VkAllocationCallbacks)* pAllocator, VkSurfaceKHR* pSurface);
alias PFN_vkGetPhysicalDeviceWin32PresentationSupportKHR = uint function(VkPhysicalDevice physicalDevice, uint queueFamilyIndex);

VkResult vkCreateWin32SurfaceKHR(VkInstance instance, const(VkWin32SurfaceCreateInfoKHR)* pCreateInfo, const(VkAllocationCallbacks)* pAllocator, VkSurfaceKHR* pSurface);

VkBool32 vkGetPhysicalDeviceWin32PresentationSupportKHR(VkPhysicalDevice physicalDevice, uint queueFamilyIndex);

enum VK_KHR_external_memory_win32 = 1;
enum VK_KHR_EXTERNAL_MEMORY_WIN32_SPEC_VERSION = 1;
enum VK_KHR_EXTERNAL_MEMORY_WIN32_EXTENSION_NAME = "VK_KHR_external_memory_win32";

struct VkImportMemoryWin32HandleInfoKHR
{
    VkStructureType sType;
    const(void)* pNext;
    VkExternalMemoryHandleTypeFlagBits handleType;
    HANDLE handle;
    LPCWSTR name;
}

struct VkExportMemoryWin32HandleInfoKHR
{
    VkStructureType sType;
    const(void)* pNext;
    const(SECURITY_ATTRIBUTES)* pAttributes;
    DWORD dwAccess;
    LPCWSTR name;
}

struct VkMemoryWin32HandlePropertiesKHR
{
    VkStructureType sType;
    void* pNext;
    uint memoryTypeBits;
}

struct VkMemoryGetWin32HandleInfoKHR
{
    VkStructureType sType;
    const(void)* pNext;
    VkDeviceMemory memory;
    VkExternalMemoryHandleTypeFlagBits handleType;
}

alias PFN_vkGetMemoryWin32HandleKHR = VkResult function(VkDevice device, const(VkMemoryGetWin32HandleInfoKHR)* pGetWin32HandleInfo, HANDLE* pHandle);
alias PFN_vkGetMemoryWin32HandlePropertiesKHR = VkResult function(VkDevice device, VkExternalMemoryHandleTypeFlagBits handleType, HANDLE handle, VkMemoryWin32HandlePropertiesKHR* pMemoryWin32HandleProperties);

VkResult vkGetMemoryWin32HandleKHR(VkDevice device, const(VkMemoryGetWin32HandleInfoKHR)* pGetWin32HandleInfo, HANDLE* pHandle);

VkResult vkGetMemoryWin32HandlePropertiesKHR(VkDevice device, VkExternalMemoryHandleTypeFlagBits handleType, HANDLE handle, VkMemoryWin32HandlePropertiesKHR* pMemoryWin32HandleProperties);

enum VK_KHR_win32_keyed_mutex = 1;
enum VK_KHR_WIN32_KEYED_MUTEX_SPEC_VERSION = 1;
enum VK_KHR_WIN32_KEYED_MUTEX_EXTENSION_NAME = "VK_KHR_win32_keyed_mutex";

struct VkWin32KeyedMutexAcquireReleaseInfoKHR
{
    VkStructureType sType;
    const(void)* pNext;
    uint acquireCount;
    const(VkDeviceMemory)* pAcquireSyncs;
    const(ulong)* pAcquireKeys;
    const(uint)* pAcquireTimeouts;
    uint releaseCount;
    const(VkDeviceMemory)* pReleaseSyncs;
    const(ulong)* pReleaseKeys;
}

enum VK_KHR_external_semaphore_win32 = 1;
enum VK_KHR_EXTERNAL_SEMAPHORE_WIN32_SPEC_VERSION = 1;
enum VK_KHR_EXTERNAL_SEMAPHORE_WIN32_EXTENSION_NAME = "VK_KHR_external_semaphore_win32";

struct VkImportSemaphoreWin32HandleInfoKHR
{
    VkStructureType sType;
    const(void)* pNext;
    VkSemaphore semaphore;
    VkSemaphoreImportFlags flags;
    VkExternalSemaphoreHandleTypeFlagBits handleType;
    HANDLE handle;
    LPCWSTR name;
}

struct VkExportSemaphoreWin32HandleInfoKHR
{
    VkStructureType sType;
    const(void)* pNext;
    const(SECURITY_ATTRIBUTES)* pAttributes;
    DWORD dwAccess;
    LPCWSTR name;
}

struct VkD3D12FenceSubmitInfoKHR
{
    VkStructureType sType;
    const(void)* pNext;
    uint waitSemaphoreValuesCount;
    const(ulong)* pWaitSemaphoreValues;
    uint signalSemaphoreValuesCount;
    const(ulong)* pSignalSemaphoreValues;
}

struct VkSemaphoreGetWin32HandleInfoKHR
{
    VkStructureType sType;
    const(void)* pNext;
    VkSemaphore semaphore;
    VkExternalSemaphoreHandleTypeFlagBits handleType;
}

alias PFN_vkImportSemaphoreWin32HandleKHR = VkResult function(VkDevice device, const(VkImportSemaphoreWin32HandleInfoKHR)* pImportSemaphoreWin32HandleInfo);
alias PFN_vkGetSemaphoreWin32HandleKHR = VkResult function(VkDevice device, const(VkSemaphoreGetWin32HandleInfoKHR)* pGetWin32HandleInfo, HANDLE* pHandle);

VkResult vkImportSemaphoreWin32HandleKHR(VkDevice device, const(VkImportSemaphoreWin32HandleInfoKHR)* pImportSemaphoreWin32HandleInfo);

VkResult vkGetSemaphoreWin32HandleKHR(VkDevice device, const(VkSemaphoreGetWin32HandleInfoKHR)* pGetWin32HandleInfo, HANDLE* pHandle);

enum VK_KHR_external_fence_win32 = 1;
enum VK_KHR_EXTERNAL_FENCE_WIN32_SPEC_VERSION = 1;
enum VK_KHR_EXTERNAL_FENCE_WIN32_EXTENSION_NAME = "VK_KHR_external_fence_win32";

struct VkImportFenceWin32HandleInfoKHR
{
    VkStructureType sType;
    const(void)* pNext;
    VkFence fence;
    VkFenceImportFlags flags;
    VkExternalFenceHandleTypeFlagBits handleType;
    HANDLE handle;
    LPCWSTR name;
}

struct VkExportFenceWin32HandleInfoKHR
{
    VkStructureType sType;
    const(void)* pNext;
    const(SECURITY_ATTRIBUTES)* pAttributes;
    DWORD dwAccess;
    LPCWSTR name;
}

struct VkFenceGetWin32HandleInfoKHR
{
    VkStructureType sType;
    const(void)* pNext;
    VkFence fence;
    VkExternalFenceHandleTypeFlagBits handleType;
}

alias PFN_vkImportFenceWin32HandleKHR = VkResult function(VkDevice device, const(VkImportFenceWin32HandleInfoKHR)* pImportFenceWin32HandleInfo);
alias PFN_vkGetFenceWin32HandleKHR = VkResult function(VkDevice device, const(VkFenceGetWin32HandleInfoKHR)* pGetWin32HandleInfo, HANDLE* pHandle);

VkResult vkImportFenceWin32HandleKHR(VkDevice device, const(VkImportFenceWin32HandleInfoKHR)* pImportFenceWin32HandleInfo);

VkResult vkGetFenceWin32HandleKHR(VkDevice device, const(VkFenceGetWin32HandleInfoKHR)* pGetWin32HandleInfo, HANDLE* pHandle);

enum VK_NV_external_memory_win32 = 1;
enum VK_NV_EXTERNAL_MEMORY_WIN32_SPEC_VERSION = 1;
enum VK_NV_EXTERNAL_MEMORY_WIN32_EXTENSION_NAME = "VK_NV_external_memory_win32";

struct VkImportMemoryWin32HandleInfoNV
{
    VkStructureType sType;
    const(void)* pNext;
    VkExternalMemoryHandleTypeFlagsNV handleType;
    HANDLE handle;
}

struct VkExportMemoryWin32HandleInfoNV
{
    VkStructureType sType;
    const(void)* pNext;
    const(SECURITY_ATTRIBUTES)* pAttributes;
    DWORD dwAccess;
}

alias PFN_vkGetMemoryWin32HandleNV = VkResult function(VkDevice device, VkDeviceMemory memory, VkExternalMemoryHandleTypeFlagsNV handleType, HANDLE* pHandle);

VkResult vkGetMemoryWin32HandleNV(VkDevice device, VkDeviceMemory memory, VkExternalMemoryHandleTypeFlagsNV handleType, HANDLE* pHandle);

enum VK_NV_win32_keyed_mutex = 1;
enum VK_NV_WIN32_KEYED_MUTEX_SPEC_VERSION = 1;
enum VK_NV_WIN32_KEYED_MUTEX_EXTENSION_NAME = "VK_NV_win32_keyed_mutex";

struct VkWin32KeyedMutexAcquireReleaseInfoNV
{
    VkStructureType sType;
    const(void)* pNext;
    uint acquireCount;
    const(VkDeviceMemory)* pAcquireSyncs;
    const(ulong)* pAcquireKeys;
    const(uint)* pAcquireTimeoutMilliseconds;
    uint releaseCount;
    const(VkDeviceMemory)* pReleaseSyncs;
    const(ulong)* pReleaseKeys;
}

enum VK_EXT_full_screen_exclusive = 1;
enum VK_EXT_FULL_SCREEN_EXCLUSIVE_SPEC_VERSION = 3;
enum VK_EXT_FULL_SCREEN_EXCLUSIVE_EXTENSION_NAME = "VK_EXT_full_screen_exclusive";

enum VkFullScreenExclusiveEXT
{
    VK_FULL_SCREEN_EXCLUSIVE_DEFAULT_EXT = 0,
    VK_FULL_SCREEN_EXCLUSIVE_ALLOWED_EXT = 1,
    VK_FULL_SCREEN_EXCLUSIVE_DISALLOWED_EXT = 2,
    VK_FULL_SCREEN_EXCLUSIVE_APPLICATION_CONTROLLED_EXT = 3,
    VK_FULL_SCREEN_EXCLUSIVE_BEGIN_RANGE_EXT = VK_FULL_SCREEN_EXCLUSIVE_DEFAULT_EXT,
    VK_FULL_SCREEN_EXCLUSIVE_END_RANGE_EXT = VK_FULL_SCREEN_EXCLUSIVE_APPLICATION_CONTROLLED_EXT,
    VK_FULL_SCREEN_EXCLUSIVE_RANGE_SIZE_EXT = VK_FULL_SCREEN_EXCLUSIVE_APPLICATION_CONTROLLED_EXT - VK_FULL_SCREEN_EXCLUSIVE_DEFAULT_EXT + 1,
    VK_FULL_SCREEN_EXCLUSIVE_MAX_ENUM_EXT = 0x7FFFFFFF
}

struct VkSurfaceFullScreenExclusiveInfoEXT
{
    VkStructureType sType;
    void* pNext;
    VkFullScreenExclusiveEXT fullScreenExclusive;
}

struct VkSurfaceCapabilitiesFullScreenExclusiveEXT
{
    VkStructureType sType;
    void* pNext;
    VkBool32 fullScreenExclusiveSupported;
}

struct VkSurfaceFullScreenExclusiveWin32InfoEXT
{
    VkStructureType sType;
    const(void)* pNext;
    HMONITOR hmonitor;
}

alias PFN_vkGetPhysicalDeviceSurfacePresentModes2EXT = VkResult function(VkPhysicalDevice physicalDevice, const(VkPhysicalDeviceSurfaceInfo2KHR)* pSurfaceInfo, uint* pPresentModeCount, VkPresentModeKHR* pPresentModes);
alias PFN_vkAcquireFullScreenExclusiveModeEXT = VkResult function(VkDevice device, VkSwapchainKHR swapchain);
alias PFN_vkReleaseFullScreenExclusiveModeEXT = VkResult function(VkDevice device, VkSwapchainKHR swapchain);
alias PFN_vkGetDeviceGroupSurfacePresentModes2EXT = VkResult function(VkDevice device, const(VkPhysicalDeviceSurfaceInfo2KHR)* pSurfaceInfo, VkDeviceGroupPresentModeFlagsKHR* pModes);

VkResult vkGetPhysicalDeviceSurfacePresentModes2EXT(VkPhysicalDevice physicalDevice, const(VkPhysicalDeviceSurfaceInfo2KHR)* pSurfaceInfo, uint* pPresentModeCount, VkPresentModeKHR* pPresentModes);

VkResult vkAcquireFullScreenExclusiveModeEXT(VkDevice device, VkSwapchainKHR swapchain);

VkResult vkReleaseFullScreenExclusiveModeEXT(VkDevice device, VkSwapchainKHR swapchain);

VkResult vkGetDeviceGroupSurfacePresentModes2EXT(VkDevice device, const(VkPhysicalDeviceSurfaceInfo2KHR)* pSurfaceInfo, VkDeviceGroupPresentModeFlagsKHR* pModes);


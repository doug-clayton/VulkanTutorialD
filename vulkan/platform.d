module vulkan.platform;

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

import core.stdc.config;
import vulkan.core;

extern (System):

version (Windows)
{
    import core.sys.windows.windows;

    enum VK_KHR_win32_surface = 1;
    enum VK_KHR_WIN32_SURFACE_SPEC_VERSION = 6;
    enum VK_KHR_WIN32_SURFACE_EXTENSION_NAME = "VK_KHR_win32_surface";
    alias VkWin32SurfaceCreateFlagsKHR = VkFlags;
    struct VkWin32SurfaceCreateInfoKHR
    {
        VkStructureType sType;
        const(void)* pNext;
        VkWin32SurfaceCreateFlagsKHR flags;
        HINSTANCE hinstance;
        HWND hwnd;
    }

    alias PFN_vkCreateWin32SurfaceKHR = VkResult function(VkInstance instance, const(VkWin32SurfaceCreateInfoKHR)* pCreateInfo, const(VkAllocationCallbacks)* pAllocator, VkSurfaceKHR* pSurface);
    alias PFN_vkGetPhysicalDeviceWin32PresentationSupportKHR = VkBool32 function(VkPhysicalDevice physicalDevice, uint queueFamilyIndex);

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
    enum VK_NV_WIN32_KEYED_MUTEX_SPEC_VERSION = 2;
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
    enum VK_EXT_FULL_SCREEN_EXCLUSIVE_SPEC_VERSION = 4;
    enum VK_EXT_FULL_SCREEN_EXCLUSIVE_EXTENSION_NAME = "VK_EXT_full_screen_exclusive";

    alias VkFullScreenExclusiveEXT = uint;
    enum : VkFullScreenExclusiveEXT
    {
        VK_FULL_SCREEN_EXCLUSIVE_DEFAULT_EXT = 0,
        VK_FULL_SCREEN_EXCLUSIVE_ALLOWED_EXT = 1,
        VK_FULL_SCREEN_EXCLUSIVE_DISALLOWED_EXT = 2,
        VK_FULL_SCREEN_EXCLUSIVE_APPLICATION_CONTROLLED_EXT = 3,
        VK_FULL_SCREEN_EXCLUSIVE_BEGIN_RANGE_EXT = VK_FULL_SCREEN_EXCLUSIVE_DEFAULT_EXT,
        VK_FULL_SCREEN_EXCLUSIVE_END_RANGE_EXT = VK_FULL_SCREEN_EXCLUSIVE_APPLICATION_CONTROLLED_EXT,
        VK_FULL_SCREEN_EXCLUSIVE_RANGE_SIZE_EXT = (VK_FULL_SCREEN_EXCLUSIVE_APPLICATION_CONTROLLED_EXT - VK_FULL_SCREEN_EXCLUSIVE_DEFAULT_EXT + 1),
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
}

version (Android)
{
    enum VK_KHR_android_surface = 1;
    struct ANativeWindow;
    enum VK_KHR_ANDROID_SURFACE_SPEC_VERSION = 6;
    enum VK_KHR_ANDROID_SURFACE_EXTENSION_NAME = "VK_KHR_android_surface";
    VkFlags VkAndroidSurfaceCreateFlagsKHR;

    struct VkAndroidSurfaceCreateInfoKHR
    {
        VkStructureType sType;
        const(void)* pNext;
        VkAndroidSurfaceCreateFlagsKHR flags;
        ANativeWindow* window;
    }

    alias PFN_vkCreateAndroidSurfaceKHR = VkResult function(VkInstance instance, const(VkAndroidSurfaceCreateInfoKHR)* pCreateInfo, const(VkAllocationCallbacks)* pAllocator, VkSurfaceKHR* pSurface);
    VkResult vkCreateAndroidSurfaceKHR(VkInstance instance, const(VkAndroidSurfaceCreateInfoKHR)* pCreateInfo, const(VkAllocationCallbacks)* pAllocator, VkSurfaceKHR* pSurface);

    enum VK_ANDROID_external_memory_android_hardware_buffer = 1;
    struct AHardwareBuffer;
    enum VK_ANDROID_EXTERNAL_MEMORY_ANDROID_HARDWARE_BUFFER_SPEC_VERSION = 3;
    enum VK_ANDROID_EXTERNAL_MEMORY_ANDROID_HARDWARE_BUFFER_EXTENSION_NAME = "VK_ANDROID_external_memory_android_hardware_buffer";

    struct VkAndroidHardwareBufferUsageANDROID
    {
        VkStructureType sType;
        void* pNext;
        ulong androidHardwareBufferUsage;
    }

    struct VkAndroidHardwareBufferPropertiesANDROID
    {
        VkStructureType sType;
        void* pNext;
        VkDeviceSize allocationSize;
        uint memoryTypeBits;
    }

    struct VkAndroidHardwareBufferFormatPropertiesANDROID
    {
        VkStructureType sType;
        void* pNext;
        VkFormat format;
        ulong externalFormat;
        VkFormatFeatureFlags formatFeatures;
        VkComponentMapping samplerYcbcrConversionComponents;
        VkSamplerYcbcrModelConversion suggestedYcbcrModel;
        VkSamplerYcbcrRange suggestedYcbcrRange;
        VkChromaLocation suggestedXChromaOffset;
        VkChromaLocation suggestedYChromaOffset;
    }

    struct VkImportAndroidHardwareBufferInfoANDROID
    {
        VkStructureType sType;
        const(void)* pNext;
        AHardwareBuffer* buffer;
    }

    struct VkMemoryGetAndroidHardwareBufferInfoANDROID
    {
        VkStructureType sType;
        const(void)* pNext;
        VkDeviceMemory memory;
    }

    struct VkExternalFormatANDROID
    {
        VkStructureType sType;
        void* pNext;
        ulong externalFormat;
    }

    alias PFN_vkGetAndroidHardwareBufferPropertiesANDROID = VkResult function(VkDevice device, const(AHardwareBuffer)* buffer, VkAndroidHardwareBufferPropertiesANDROID* pProperties);
    alias PFN_vkGetMemoryAndroidHardwareBufferANDROID = VkResult function(VkDevice device, const(VkMemoryGetAndroidHardwareBufferInfoANDROID)* pInfo, AHardwareBuffer** pBuffer);

    VkResult vkGetAndroidHardwareBufferPropertiesANDROID(VkDevice device, const(AHardwareBuffer)* buffer, VkAndroidHardwareBufferPropertiesANDROID* pProperties);
    VkResult vkGetMemoryAndroidHardwareBufferANDROID(VkDevice device, const(VkMemoryGetAndroidHardwareBufferInfoANDROID)* pInfo, AHardwareBuffer** pBuffer);
}

version (IOS)
{
    enum VK_MVK_ios_surface = 1;
    enum VK_MVK_IOS_SURFACE_SPEC_VERSION = 2;
    enum VK_MVK_IOS_SURFACE_EXTENSION_NAME = "VK_MVK_ios_surface";
    VkFlags VkIOSSurfaceCreateFlagsMVK;
    struct VkIOSSurfaceCreateInfoMVK
    {
        VkStructureType sType;
        const(void)* pNext;
        VkIOSSurfaceCreateFlagsMVK flags;
        const(void)* pView;
    }

    alias PFN_vkCreateIOSSurfaceMVK = VkResult function(VkInstance instance, const(VkIOSSurfaceCreateInfoMVK)* pCreateInfo, const(VkAllocationCallbacks)* pAllocator, VkSurfaceKHR* pSurface);
    VkResult vkCreateIOSSurfaceMVK(VkInstance instance, const(VkIOSSurfaceCreateInfoMVK)* pCreateInfo, const(VkAllocationCallbacks)* pAllocator, VkSurfaceKHR* pSurface);
}

version (OSX)
{
    enum VK_MVK_macos_surface = 1;
    enum VK_MVK_MACOS_SURFACE_SPEC_VERSION = 2;
    enum VK_MVK_MACOS_SURFACE_EXTENSION_NAME = "VK_MVK_macos_surface";
    VkFlags VkMacOSSurfaceCreateFlagsMVK;
    struct VkMacOSSurfaceCreateInfoMVK
    {
        VkStructureType sType;
        const(void)* pNext;
        VkMacOSSurfaceCreateFlagsMVK flags;
        const(void)* pView;
    }

    alias PFN_vkCreateMacOSSurfaceMVK = VkResult function(VkInstance instance, const(VkMacOSSurfaceCreateInfoMVK)* pCreateInfo, const(VkAllocationCallbacks)* pAllocator, VkSurfaceKHR* pSurface);
    VkResult vkCreateMacOSSurfaceMVK(VkInstance instance, const(VkMacOSSurfaceCreateInfoMVK)* pCreateInfo, const(VkAllocationCallbacks)* pAllocator, VkSurfaceKHR* pSurface);
}

version (Posix)
{
    import core.sys.posix;

    enum VK_KHR_xlib_surface = 1;
    enum VK_KHR_XLIB_SURFACE_SPEC_VERSION = 6;
    enum VK_KHR_XLIB_SURFACE_EXTENSION_NAME = "VK_KHR_xlib_surface";
    VkFlags VkXlibSurfaceCreateFlagsKHR;
    struct VkXlibSurfaceCreateInfoKHR
    {
        VkStructureType sType;
        const(void)* pNext;
        VkXlibSurfaceCreateFlagsKHR flags;
        Display* dpy;
        Window window;
    }

    alias PFN_vkCreateXlibSurfaceKHR = VkResult function(VkInstance instance, const(VkXlibSurfaceCreateInfoKHR)* pCreateInfo, const(VkAllocationCallbacks)* pAllocator, VkSurfaceKHR* pSurface);
    alias PFN_vkGetPhysicalDeviceXlibPresentationSupportKHR = VkBool32 function(VkPhysicalDevice physicalDevice, uint queueFamilyIndex, Display* dpy, VisualID visualID);

    VkResult vkCreateXlibSurfaceKHR(VkInstance instance, const(VkXlibSurfaceCreateInfoKHR)* pCreateInfo, const(VkAllocationCallbacks)* pAllocator, VkSurfaceKHR* pSurface);
    VkBool32 vkGetPhysicalDeviceXlibPresentationSupportKHR(VkPhysicalDevice physicalDevice, uint queueFamilyIndex, Display* dpy, VisualID visualID);

    enum VK_EXT_acquire_xlib_display = 1;
    enum VK_EXT_ACQUIRE_XLIB_DISPLAY_SPEC_VERSION = 1;
    enum VK_EXT_ACQUIRE_XLIB_DISPLAY_EXTENSION_NAME = "VK_EXT_acquire_xlib_display";
    VkResult function(VkPhysicalDevice physicalDevice, Display* dpy, VkDisplayKHR display) PFN_vkAcquireXlibDisplayEXT;
    VkResult function(VkPhysicalDevice physicalDevice, Display* dpy, RROutput rrOutput, VkDisplayKHR* pDisplay) PFN_vkGetRandROutputDisplayEXT;

    VkResult vkAcquireXlibDisplayEXT(VkPhysicalDevice physicalDevice, Display* dpy, VkDisplayKHR display);
    VkResult vkGetRandROutputDisplayEXT(VkPhysicalDevice physicalDevice, Display* dpy, RROutput rrOutput, VkDisplayKHR* pDisplay);

    enum VK_KHR_xcb_surface = 1;
    enum VK_KHR_XCB_SURFACE_SPEC_VERSION = 6;
    enum VK_KHR_XCB_SURFACE_EXTENSION_NAME = "VK_KHR_xcb_surface";
    VkFlags VkXcbSurfaceCreateFlagsKHR;
    struct VkXcbSurfaceCreateInfoKHR
    {
        VkStructureType sType;
        const(void)* pNext;
        VkXcbSurfaceCreateFlagsKHR flags;
        xcb_connection_t* connection;
        xcb_window_t window;
    }

    alias PFN_vkCreateXcbSurfaceKHR = VkResult function(VkInstance instance, const(VkXcbSurfaceCreateInfoKHR)* pCreateInfo, const(VkAllocationCallbacks)* pAllocator, VkSurfaceKHR* pSurface);
    alias PFN_vkGetPhysicalDeviceXcbPresentationSupportKHR = VkBool32 function(VkPhysicalDevice physicalDevice, uint queueFamilyIndex, xcb_connection_t* connection, xcb_visualid_t visual_id);

    VkResult vkCreateXcbSurfaceKHR(VkInstance instance, const(VkXcbSurfaceCreateInfoKHR)* pCreateInfo, const(VkAllocationCallbacks)* pAllocator, VkSurfaceKHR* pSurface);
    VkBool32 vkGetPhysicalDeviceXcbPresentationSupportKHR(VkPhysicalDevice physicalDevice, uint queueFamilyIndex, xcb_connection_t* connection, xcb_visualid_t visual_id);
}

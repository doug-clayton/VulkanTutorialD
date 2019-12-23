module app;

import std.exception;
import std.string;
import std.stdio;

import glfw;
import vulkan;

const int WIDTH = 800;
const int HEIGHT = 600;
const char* TITLE = "Vulkan";

const int MAX_FRAMES_IN_FLIGHT = 2;

string[] validationLayers = ["VK_LAYER_KHRONOS_validation"];
string[] deviceExtensions  = [VK_KHR_SWAPCHAIN_EXTENSION_NAME];
static int validationError = 0;

debug
{
    enum enableValidationLayers = true;
}
else
{
    enum enableValidationLayers = false;
}

struct QueueFamilyIndices
{
    import std.typecons : Nullable;

    Nullable!uint graphicsFamily;
    Nullable!uint presentFamily;

    bool isComplete()
    {
        return !graphicsFamily.isNull && !presentFamily.isNull;
    }
}

struct SwapChainSupportDetails
{
    VkSurfaceCapabilitiesKHR capabilities;
    VkSurfaceFormatKHR[] formats;
    VkPresentModeKHR[] presentModes;
}

class HelloTriangleApplication
{
public:
    void run()
    {
        initWindow();
        initVulkan();
        mainLoop();
        cleanup();
    }

private:
    GLFWwindow* window;

    VkInstance instance;
    VkDebugUtilsMessengerEXT debugMessenger;
    VkSurfaceKHR surface;

    VkPhysicalDevice physicalDevice = null;
    VkDevice device;

    VkQueue graphicsQueue;
    VkQueue presentQueue;

    VkSwapchainKHR swapChain;
    VkImage[] swapChainImages;
    VkFormat swapChainImageFormat;
    VkExtent2D swapChainExtent;
    VkImageView[] swapChainImageViews;
    VkFramebuffer[] swapChainFramebuffers;

    VkRenderPass renderPass;
    VkPipelineLayout pipelineLayout;
    VkPipeline graphicsPipeline;

    VkCommandPool commandPool;
    VkCommandBuffer[] commandBuffers;

    VkSemaphore[] imageAvailableSemaphores;
    VkSemaphore[] renderFinishedSemaphores;
    VkFence[] inFlightFences;
    size_t currentFrame = 0;

    bool framebufferResized = false;

    void initWindow()
    {
        glfwInit();

        debug
        {
            int major, minor, rev;
            glfwGetVersion(&major, &minor, &rev);
            writefln("GLFW version %d.%d.%d", major, minor, rev);
            writefln("GLFW Vulkan Supported? %d", glfwVulkanSupported());
        }

        glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);

        window = glfwCreateWindow(WIDTH, HEIGHT, TITLE, null, null);
        glfwSetWindowUserPointer(window, cast(void*) this);
        glfwSetFramebufferSizeCallback(window, &framebufferResizeCallback);
    }

    void initVulkan()
    {
        createInstance();
        setupDebugMessenger();
        createSurface();
        pickPhysicalDevice();
        createLogicalDevice();
        createSwapChain();
        createImageViews();
        createRenderPass();
        createGraphicsPipeline();
        createFramebuffers();
        createCommandPool();
        createCommandBuffers();
        createSyncObjects();
    }

    void mainLoop()
    {
        while (!glfwWindowShouldClose(window))
        {
            glfwPollEvents();
            drawFrame();
        }

        vkDeviceWaitIdle(device);
    }

    void cleanup()
    {
        cleanupSwapChain();

        for(size_t i = 0;i < MAX_FRAMES_IN_FLIGHT; i++)
        {
            vkDestroySemaphore(device, renderFinishedSemaphores[i], null);
            vkDestroySemaphore(device, imageAvailableSemaphores[i], null);
            vkDestroyFence(device, inFlightFences[i], null);
        }

        vkDestroyCommandPool(device, commandPool, null);
        vkDestroyDevice(device, null);

        if (enableValidationLayers)
        {
            DestroyDebugUtilsMessengerEXT(instance, debugMessenger, null);
        }

        vkDestroySurfaceKHR(instance, surface, null);
        vkDestroyInstance(instance, null);

        glfwDestroyWindow(window);
        glfwTerminate();
    }

    void drawFrame()
    {
        vkWaitForFences(device, 1, &inFlightFences[currentFrame], VK_TRUE, ulong.max);

        uint imageIndex;
        VkResult result = vkAcquireNextImageKHR(device, swapChain, ulong.max, imageAvailableSemaphores[currentFrame], null, &imageIndex);

        if (result == VK_ERROR_OUT_OF_DATE_KHR)
        {
            recreateSwapChain();
            return;
        }
        else if (result != VK_SUCCESS && result != VK_SUBOPTIMAL_KHR)
        {
            throw new Exception("failed to acquire swap chain image!");
        }

        VkSubmitInfo submitInfo;
        submitInfo.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO;

        VkSemaphore[] waitSemaphores = [imageAvailableSemaphores[currentFrame]];
        VkPipelineStageFlags[] waitStages = [VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT];
        submitInfo.waitSemaphoreCount = 1;
        submitInfo.pWaitSemaphores = waitSemaphores.ptr;
        submitInfo.pWaitDstStageMask = waitStages.ptr;
        submitInfo.commandBufferCount = 1;
        submitInfo.pCommandBuffers = &commandBuffers[imageIndex];

        VkSemaphore[] signalSemaphores = [renderFinishedSemaphores[currentFrame]];
        submitInfo.signalSemaphoreCount = 1;
        submitInfo.pSignalSemaphores = signalSemaphores.ptr;

        vkResetFences(device, 1, &inFlightFences[currentFrame]);
        ThrowIfFailed(vkQueueSubmit(graphicsQueue, 1, &submitInfo, inFlightFences[currentFrame]), "failed to submit draw command buffer!");

        VkPresentInfoKHR presentInfo;
        presentInfo.sType = VK_STRUCTURE_TYPE_PRESENT_INFO_KHR;

        presentInfo.waitSemaphoreCount = 1;
        presentInfo.pWaitSemaphores = signalSemaphores.ptr;

        VkSwapchainKHR[] swapChains = [swapChain];
        presentInfo.swapchainCount = 1;
        presentInfo.pSwapchains = swapChains.ptr;
        presentInfo.pImageIndices = &imageIndex;
        presentInfo.pResults = null;

        result = vkQueuePresentKHR(presentQueue, &presentInfo);
        if(result == VK_ERROR_OUT_OF_DATE_KHR || result == VK_SUBOPTIMAL_KHR || framebufferResized)
        {
            framebufferResized = false;
            recreateSwapChain();
        }
        ThrowIfFailed(result, "failed to present swap chain image!");

        currentFrame = (currentFrame + 1) % MAX_FRAMES_IN_FLIGHT;
    }

    void cleanupSwapChain()
    {
        for(size_t i = 0; i < swapChainFramebuffers.length; i++)
        {
            vkDestroyFramebuffer(device, swapChainFramebuffers[i], null);
        }

        vkFreeCommandBuffers(device, commandPool, cast(uint) commandBuffers.length, commandBuffers.ptr);

        vkDestroyPipeline(device, graphicsPipeline, null);
        vkDestroyPipelineLayout(device, pipelineLayout, null);
        vkDestroyRenderPass(device, renderPass, null);

        for(size_t i = 0; i < swapChainImageViews.length; i++)
        {
            vkDestroyImageView(device, swapChainImageViews[i], null);
        }

        vkDestroySwapchainKHR(device, swapChain, null);
    }

    void recreateSwapChain()
    {
        int width = 0, height = 0;
        while (width == 0 || height == 0)
        {
            glfwGetFramebufferSize(window, &width, &height);
            glfwWaitEvents();
        }

        vkDeviceWaitIdle(device);

        cleanupSwapChain();

        createSwapChain();
        createImageViews();
        createRenderPass();
        createGraphicsPipeline();
        createFramebuffers();
        createCommandBuffers();
    }

    void createInstance()
    {
        if (enableValidationLayers && !checkValidationLayerSupport)
        {
            throw new Exception("validation layers requested, but not available!");
        }

        VkApplicationInfo appInfo;
        appInfo.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO;
        appInfo.pApplicationName = "Hello Triangle";
        appInfo.applicationVersion = VK_MAKE_VERSION(1, 0, 0);
        appInfo.pEngineName = "No Engine";
        appInfo.engineVersion = VK_MAKE_VERSION(1, 0, 0);
        appInfo.apiVersion = VK_API_VERSION_1_0;

        VkInstanceCreateInfo createInfo;
        createInfo.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
        createInfo.pApplicationInfo = &appInfo;

        string[] extensions = getRequiredExtensions();
        createInfo.enabledExtensionCount = cast(uint) extensions.length;
        createInfo.ppEnabledExtensionNames = toCStringList(extensions).ptr;

        if (enableValidationLayers)
        {
            createInfo.enabledLayerCount = cast(uint) validationLayers.length;
            createInfo.ppEnabledLayerNames = toCStringList(validationLayers).ptr;
        }
        else
        {
            createInfo.enabledLayerCount = 0;
        }

        debug
        {
            writeln("Supported Extensions: ");
            foreach (ext; extensions)
            {
                writeln(ext);
            }
        }

        ThrowIfFailed(vkCreateInstance(&createInfo, null, &instance), "failed to create instance!");
        debug writeln("created Vulkan instance!");
    }

    void setupDebugMessenger()
    {
        if (!enableValidationLayers)
        {
            return;
        }

        VkDebugUtilsMessengerCreateInfoEXT createInfo;
        createInfo.sType = VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT;
        createInfo.messageSeverity = VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT;
        createInfo.messageType = VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT;
        createInfo.pfnUserCallback = &debugCallback;

        ThrowIfFailed(CreateDebugUtilsMessengerEXT(instance, &createInfo, null, &debugMessenger), "failed to set up debug messenger!");
        debug writeln("set up debug messenger!");
    }

    void createSurface()
    {
        ThrowIfFailed(glfwCreateWindowSurface(instance, window, null, &surface), "failed to create window surface!");
        debug writeln("created window surface!");
    }

    void pickPhysicalDevice()
    {
        uint deviceCount = 0;
        vkEnumeratePhysicalDevices(instance, &deviceCount, null);

        if (deviceCount == 0)
        {
            throw new Exception("failed to find GPUs with Vulkan support!");
        }

        VkPhysicalDevice[] devices;
        devices.length = deviceCount;
        ThrowIfFailed(vkEnumeratePhysicalDevices(instance, &deviceCount, devices.ptr), "failed to set devices!");

        foreach (device; devices)
        {
            if (isDeviceSuitable(device))
            {
                writeln("found a suitable GPU!");
                physicalDevice = device;
                break;
            }
        }

        if (physicalDevice == null)
        {
            throw new Exception("failed to find a suitable GPU!");
        }

        debug writeln("picked physical device!");
    }

    void createLogicalDevice()
    {
        QueueFamilyIndices indices = findQueueFamilies(physicalDevice);

        VkDeviceQueueCreateInfo[] queueCreateInfos;
        uint[uint] uniqueQueueFamilies;
        uniqueQueueFamilies[indices.graphicsFamily.get] = indices.graphicsFamily.get;
        uniqueQueueFamilies[indices.presentFamily.get] = indices.presentFamily.get;

        float queuePriority = 1.0f;

        foreach(queueFamily; uniqueQueueFamilies)
        {
            VkDeviceQueueCreateInfo queueCreateInfo;
            queueCreateInfo.sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
            queueCreateInfo.queueFamilyIndex = queueFamily;
            queueCreateInfo.queueCount = 1;
            queueCreateInfo.pQueuePriorities = &queuePriority;
            queueCreateInfos ~= queueCreateInfo;
        }

        VkPhysicalDeviceFeatures deviceFeatures;

        VkDeviceCreateInfo createInfo;
        createInfo.sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO;
        createInfo.queueCreateInfoCount = cast(uint)queueCreateInfos.length;
        createInfo.pQueueCreateInfos = queueCreateInfos.ptr;
        createInfo.pEnabledFeatures = &deviceFeatures;
        createInfo.enabledExtensionCount = cast(uint)deviceExtensions.length;
        createInfo.ppEnabledExtensionNames = toCStringList(deviceExtensions).ptr;

        if (enableValidationLayers)
        {
            createInfo.enabledLayerCount = cast(uint) validationLayers.length;
            createInfo.ppEnabledLayerNames = toCStringList(validationLayers).ptr;
        }
        else
        {
            createInfo.enabledLayerCount = 0;
        }

        ThrowIfFailed(vkCreateDevice(physicalDevice, &createInfo, null, &device), "failed to create logical device!");

        vkGetDeviceQueue(device, indices.graphicsFamily.get, 0, &graphicsQueue);
        vkGetDeviceQueue(device, indices.presentFamily.get, 0, &presentQueue);
        debug writeln("created logical Device!");
    }

    void createSwapChain()
    {
        SwapChainSupportDetails swapChainSupport = querySwapChainSupport(physicalDevice);

        VkSurfaceFormatKHR surfaceFormat = chooseSwapSurfaceFormat(swapChainSupport.formats);
        VkPresentModeKHR presentMode = chooseSwapPresentMode(swapChainSupport.presentModes);
        VkExtent2D extent = chooseSwapExtent(swapChainSupport.capabilities);

        uint imageCount = swapChainSupport.capabilities.minImageCount + 1;

        if (swapChainSupport.capabilities.maxImageCount > 0 && imageCount > swapChainSupport.capabilities.maxImageCount)
        {
            imageCount = swapChainSupport.capabilities.maxImageCount;
        }

        VkSwapchainCreateInfoKHR createInfo;
        createInfo.sType = VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR;
        createInfo.surface = surface;
        createInfo.minImageCount = imageCount;
        createInfo.imageFormat = surfaceFormat.format;
        createInfo.imageColorSpace = surfaceFormat.colorSpace;
        createInfo.imageExtent = extent;
        createInfo.imageArrayLayers = 1; // Always 1 unless making stereoscopic 3D app.
        createInfo.imageUsage = VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT;

        QueueFamilyIndices indices = findQueueFamilies(physicalDevice);
        uint[] queueFamilyIndices = [indices.graphicsFamily.get, indices.presentFamily.get];

        if (indices.graphicsFamily.get != indices.presentFamily.get)
        {
            createInfo.imageSharingMode = VK_SHARING_MODE_CONCURRENT;
            createInfo.queueFamilyIndexCount = 2;
            createInfo.pQueueFamilyIndices = queueFamilyIndices.ptr;
        }
        else
        {
            createInfo.imageSharingMode = VK_SHARING_MODE_EXCLUSIVE;
            createInfo.queueFamilyIndexCount = 0; // Optional
            createInfo.pQueueFamilyIndices = null; // Optional
        }

        createInfo.preTransform = swapChainSupport.capabilities.currentTransform;
        createInfo.compositeAlpha = VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR;
        createInfo.presentMode = presentMode;
        createInfo.clipped = VK_TRUE;
        createInfo.oldSwapchain = null;

        ThrowIfFailed(vkCreateSwapchainKHR(device, &createInfo, null, &swapChain), "failed to create swap chain!");

        vkGetSwapchainImagesKHR(device, swapChain, &imageCount, null);
        swapChainImages.length = imageCount;
        ThrowIfFailed(vkGetSwapchainImagesKHR(device, swapChain, &imageCount, swapChainImages.ptr), "failed to set swapChainImages!");

        swapChainImageFormat = surfaceFormat.format;
        swapChainExtent = extent;

        debug writeln("created swapchain!");
    }

    void createImageViews()
    {
        swapChainImageViews.length = swapChainImages.length;

        for(size_t i = 0; i < swapChainImages.length; i++)
        {
            VkImageViewCreateInfo createInfo;
            createInfo.sType = VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO;
            createInfo.image = swapChainImages[i];
            createInfo.viewType = VK_IMAGE_VIEW_TYPE_2D;
            createInfo.format = swapChainImageFormat;
            createInfo.components.r = VK_COMPONENT_SWIZZLE_IDENTITY;
            createInfo.components.g = VK_COMPONENT_SWIZZLE_IDENTITY;
            createInfo.components.b = VK_COMPONENT_SWIZZLE_IDENTITY;
            createInfo.components.a = VK_COMPONENT_SWIZZLE_IDENTITY;
            createInfo.subresourceRange.aspectMask = VK_IMAGE_ASPECT_COLOR_BIT;
            createInfo.subresourceRange.baseMipLevel = 0;
            createInfo.subresourceRange.levelCount = 1;
            createInfo.subresourceRange.baseArrayLayer = 0;
            createInfo.subresourceRange.layerCount = 1;

            ThrowIfFailed(vkCreateImageView(device, &createInfo, null, &swapChainImageViews[i]), "failed to create image view!");
        }
        debug writefln("created image views!");
    }

    void createGraphicsPipeline()
    {
        char[] vertShaderCode = readFile("../resources/shaders/vert.spv");
        char[] fragShaderCode = readFile("../resources/shaders/frag.spv");

        VkShaderModule vertShaderModule = createShaderModule(vertShaderCode);
        VkShaderModule fragShaderModule = createShaderModule(fragShaderCode);

        VkPipelineShaderStageCreateInfo vertShaderStageInfo;
        vertShaderStageInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
        vertShaderStageInfo.stage = VK_SHADER_STAGE_VERTEX_BIT;
        vertShaderStageInfo.module_ = vertShaderModule;
        vertShaderStageInfo.pName = "main";

        VkPipelineShaderStageCreateInfo fragShaderStageInfo;
        fragShaderStageInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO;
        fragShaderStageInfo.stage = VK_SHADER_STAGE_FRAGMENT_BIT;
        fragShaderStageInfo.module_ = fragShaderModule;
        fragShaderStageInfo.pName = "main";

        VkPipelineShaderStageCreateInfo[] shaderStages = [vertShaderStageInfo, fragShaderStageInfo];

        VkPipelineVertexInputStateCreateInfo vertexInputInfo;
        vertexInputInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO;
        vertexInputInfo.vertexBindingDescriptionCount = 0;
        vertexInputInfo.vertexAttributeDescriptionCount = 0;

        VkPipelineInputAssemblyStateCreateInfo inputAssembly;
        inputAssembly.sType = VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO;
        inputAssembly.topology = VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST;
        inputAssembly.primitiveRestartEnable = VK_FALSE;

        VkViewport viewport;
        viewport.x = 0.0f;
        viewport.y = 0.0f;
        viewport.width = cast(float) swapChainExtent.width;
        viewport.height = cast(float) swapChainExtent.height;
        viewport.minDepth = 0.0f;
        viewport.maxDepth = 1.0f;

        VkRect2D scissor;
        scissor.offset.x = 0;
        scissor.offset.y = 0;
        scissor.extent = swapChainExtent;

        VkPipelineViewportStateCreateInfo viewportState;
        viewportState.sType = VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO;
        viewportState.viewportCount = 1;
        viewportState.pViewports = &viewport;
        viewportState.scissorCount = 1;
        viewportState.pScissors = &scissor;

        VkPipelineRasterizationStateCreateInfo rasterizer;
        rasterizer.sType = VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO;
        rasterizer.depthClampEnable = VK_FALSE;
        rasterizer.rasterizerDiscardEnable = VK_FALSE;
        rasterizer.polygonMode = VK_POLYGON_MODE_FILL;
        rasterizer.lineWidth = 1.0f;
        rasterizer.cullMode = VK_CULL_MODE_BACK_BIT;
        rasterizer.frontFace = VK_FRONT_FACE_CLOCKWISE;
        rasterizer.depthBiasEnable = VK_FALSE;
        rasterizer.depthBiasConstantFactor = 0.0f; // Optional
        rasterizer.depthBiasClamp = 0.0f; // Optional
        rasterizer.depthBiasSlopeFactor = 0.0f; // Optional

        VkPipelineMultisampleStateCreateInfo multisampling;
        multisampling.sType = VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO;
        multisampling.sampleShadingEnable = VK_FALSE;
        multisampling.rasterizationSamples = VK_SAMPLE_COUNT_1_BIT;
        multisampling.minSampleShading = 1.0f; // Optional
        multisampling.pSampleMask = null; // Optional
        multisampling.alphaToCoverageEnable = VK_FALSE; // Optional
        multisampling.alphaToOneEnable = VK_FALSE; // Optional

        VkPipelineColorBlendAttachmentState colorBlendAttachment;
        colorBlendAttachment.colorWriteMask = VK_COLOR_COMPONENT_R_BIT | VK_COLOR_COMPONENT_G_BIT | VK_COLOR_COMPONENT_B_BIT | VK_COLOR_COMPONENT_A_BIT;
        colorBlendAttachment.blendEnable = VK_FALSE;
        colorBlendAttachment.srcColorBlendFactor = VK_BLEND_FACTOR_ONE; // Optional
        colorBlendAttachment.dstColorBlendFactor = VK_BLEND_FACTOR_ZERO; // Optional
        colorBlendAttachment.colorBlendOp = VK_BLEND_OP_ADD; // Optional
        colorBlendAttachment.srcAlphaBlendFactor = VK_BLEND_FACTOR_ONE; // Optional
        colorBlendAttachment.dstAlphaBlendFactor = VK_BLEND_FACTOR_ZERO; // Optional
        colorBlendAttachment.alphaBlendOp = VK_BLEND_OP_ADD; // Optional

        VkPipelineColorBlendStateCreateInfo colorBlending;
        colorBlending.sType = VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO;
        colorBlending.logicOpEnable = VK_FALSE;
        colorBlending.logicOp = VK_LOGIC_OP_COPY; // Optional
        colorBlending.attachmentCount = 1;
        colorBlending.pAttachments = &colorBlendAttachment;
        colorBlending.blendConstants[0] = 0.0f; // Optional
        colorBlending.blendConstants[1] = 0.0f; // Optional
        colorBlending.blendConstants[2] = 0.0f; // Optional
        colorBlending.blendConstants[3] = 0.0f; // Optional

        VkPipelineLayoutCreateInfo pipelineLayoutInfo;
        pipelineLayoutInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO;
        pipelineLayoutInfo.setLayoutCount = 0; // Optional
        pipelineLayoutInfo.pSetLayouts = null; // Optional
        pipelineLayoutInfo.pushConstantRangeCount = 0; // Optional
        pipelineLayoutInfo.pPushConstantRanges = null; // Optional

        ThrowIfFailed(vkCreatePipelineLayout(device, &pipelineLayoutInfo, null, &pipelineLayout), "failed to create pipeline layout!");
        debug writeln("created pipeline layout!");

        VkGraphicsPipelineCreateInfo pipelineInfo;
        pipelineInfo.sType = VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO;
        pipelineInfo.stageCount = 2;
        pipelineInfo.pStages = shaderStages.ptr;
        pipelineInfo.pVertexInputState = &vertexInputInfo;
        pipelineInfo.pInputAssemblyState = &inputAssembly;
        pipelineInfo.pViewportState = &viewportState;
        pipelineInfo.pRasterizationState = &rasterizer;
        pipelineInfo.pMultisampleState = &multisampling;
        pipelineInfo.pDepthStencilState = null; // Optional
        pipelineInfo.pColorBlendState = &colorBlending;
        pipelineInfo.pDynamicState = null; // Optional
        pipelineInfo.layout = pipelineLayout;
        pipelineInfo.renderPass = renderPass;
        pipelineInfo.subpass = 0;
        pipelineInfo.basePipelineHandle = null; // Optional
        pipelineInfo.basePipelineIndex = -1; // Optional

        ThrowIfFailed(vkCreateGraphicsPipelines(device, null, 1, &pipelineInfo, null, &graphicsPipeline), "failed to create graphics pipeline!");

        vkDestroyShaderModule(device, fragShaderModule, null);
        vkDestroyShaderModule(device, vertShaderModule, null);

        debug writeln("created graphics pipeline!");
    }

    void createFramebuffers()
    {
        swapChainFramebuffers.length = swapChainImageViews.length;

        for(size_t i = 0; i < swapChainImageViews.length; i++)
        {
            VkImageView[] attachments = [swapChainImageViews[i]];

            VkFramebufferCreateInfo framebufferInfo;
            framebufferInfo.sType = VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO;
            framebufferInfo.renderPass = renderPass;
            framebufferInfo.attachmentCount = 1;
            framebufferInfo.pAttachments = attachments.ptr;
            framebufferInfo.width = swapChainExtent.width;
            framebufferInfo.height = swapChainExtent.height;
            framebufferInfo.layers = 1;

            ThrowIfFailed(vkCreateFramebuffer(device, &framebufferInfo, null, &swapChainFramebuffers[i]), "failed to create framebuffer!");
        }
        debug writeln("created framebuffers!");
    }

    void createCommandPool()
    {
        QueueFamilyIndices queueFamilyIndices = findQueueFamilies(physicalDevice);

        VkCommandPoolCreateInfo poolInfo;
        poolInfo.sType = VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO;
        poolInfo.queueFamilyIndex = queueFamilyIndices.graphicsFamily.get;
        poolInfo.flags = 0; // Optional

        ThrowIfFailed(vkCreateCommandPool(device, &poolInfo, null, &commandPool), "failed to create command pool!");
        debug writeln("created command pool!");
    }

    void createCommandBuffers()
    {
        commandBuffers.length = swapChainFramebuffers.length;

        VkCommandBufferAllocateInfo allocInfo;
        allocInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO;
        allocInfo.commandPool = commandPool;
        allocInfo.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY;
        allocInfo.commandBufferCount = cast(uint) commandBuffers.length;

        ThrowIfFailed(vkAllocateCommandBuffers(device, &allocInfo, commandBuffers.ptr), "failed to allocate command buffers!");
        debug writeln("allocated command buffers!");

        for (size_t i = 0; i < commandBuffers.length; i++)
        {
            VkCommandBufferBeginInfo beginInfo;
            beginInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO;
            beginInfo.flags = VK_COMMAND_BUFFER_USAGE_SIMULTANEOUS_USE_BIT;

            ThrowIfFailed(vkBeginCommandBuffer(commandBuffers[i], &beginInfo), "failed to begin recording command buffer!");

            VkRenderPassBeginInfo renderPassInfo;
            renderPassInfo.sType = VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO;
            renderPassInfo.renderPass = renderPass;
            renderPassInfo.framebuffer = swapChainFramebuffers[i];
            renderPassInfo.renderArea.offset.x = 0;
            renderPassInfo.renderArea.offset.y = 0;
            renderPassInfo.renderArea.extent = swapChainExtent;

            VkClearValue clearColor;
            clearColor.color.float32 = [0.0f, 0.0f, 0.0f, 1.0f];
            renderPassInfo.clearValueCount = 1;
            renderPassInfo.pClearValues = &clearColor;

            vkCmdBeginRenderPass(commandBuffers[i], &renderPassInfo, VK_SUBPASS_CONTENTS_INLINE);

            vkCmdBindPipeline(commandBuffers[i], VK_PIPELINE_BIND_POINT_GRAPHICS, graphicsPipeline);
            vkCmdDraw(commandBuffers[i], 3, 1, 0, 0);
            
            vkCmdEndRenderPass(commandBuffers[i]);

            ThrowIfFailed(vkEndCommandBuffer(commandBuffers[i]), "failed to record command buffer!");
        }
        debug writeln("created command buffers!");
    }

    void createSyncObjects()
    {
        imageAvailableSemaphores.length = MAX_FRAMES_IN_FLIGHT;
        renderFinishedSemaphores.length = MAX_FRAMES_IN_FLIGHT;
        inFlightFences.length = MAX_FRAMES_IN_FLIGHT;

        VkSemaphoreCreateInfo semaphoreInfo;
        semaphoreInfo.sType = VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO;

        VkFenceCreateInfo fenceInfo;
        fenceInfo.sType = VK_STRUCTURE_TYPE_FENCE_CREATE_INFO;
        fenceInfo.flags = VK_FENCE_CREATE_SIGNALED_BIT;

        for(size_t i = 0; i < MAX_FRAMES_IN_FLIGHT; i++)
        {
            ThrowIfFailed(vkCreateSemaphore(device, &semaphoreInfo, null, &imageAvailableSemaphores[i]), "failed to create image available semaphore!");
            ThrowIfFailed(vkCreateSemaphore(device, &semaphoreInfo, null, &renderFinishedSemaphores[i]), "failed to create render finished semaphore!");
            ThrowIfFailed(vkCreateFence(device, &fenceInfo, null, &inFlightFences[i]), "failed to create synchronization objects for a frame!");
        }
        
        debug writeln("created sync objects!");
    }

    void createRenderPass()
    {
        VkAttachmentDescription colorAttachment;
        colorAttachment.format = swapChainImageFormat;
        colorAttachment.samples = VK_SAMPLE_COUNT_1_BIT;
        colorAttachment.loadOp = VK_ATTACHMENT_LOAD_OP_CLEAR;
        colorAttachment.storeOp = VK_ATTACHMENT_STORE_OP_STORE;
        colorAttachment.stencilLoadOp = VK_ATTACHMENT_LOAD_OP_DONT_CARE;
        colorAttachment.stencilStoreOp = VK_ATTACHMENT_STORE_OP_DONT_CARE;
        colorAttachment.initialLayout = VK_IMAGE_LAYOUT_UNDEFINED;
        colorAttachment.finalLayout = VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;

        VkAttachmentReference colorAttachmentRef;
        colorAttachmentRef.attachment = 0;
        colorAttachmentRef.layout = VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL;

        VkSubpassDescription subpass;
        subpass.pipelineBindPoint = VK_PIPELINE_BIND_POINT_GRAPHICS;
        subpass.colorAttachmentCount = 1;
        subpass.pColorAttachments = &colorAttachmentRef;

        VkSubpassDependency dependency;
        dependency.srcSubpass = VK_SUBPASS_EXTERNAL;
        dependency.dstSubpass = 0;
        dependency.srcStageMask = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
        dependency.srcAccessMask = 0;
        dependency.dstStageMask = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
        dependency.dstAccessMask = VK_ACCESS_COLOR_ATTACHMENT_READ_BIT | VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT;

        VkRenderPassCreateInfo renderPassInfo;
        renderPassInfo.sType = VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO;
        renderPassInfo.attachmentCount = 1;
        renderPassInfo.pAttachments = &colorAttachment;
        renderPassInfo.subpassCount = 1;
        renderPassInfo.pSubpasses = &subpass;
        renderPassInfo.dependencyCount = 1;
        renderPassInfo.pDependencies = &dependency;

        ThrowIfFailed(vkCreateRenderPass(device, &renderPassInfo, null, &renderPass), "failed to create render pass!");
        debug writeln("created render pass!");
    }

    VkShaderModule createShaderModule(const ref char[] code)
    {
        VkShaderModuleCreateInfo createInfo;
        createInfo.sType = VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO;
        createInfo.codeSize = code.length;
        createInfo.pCode = cast(uint*) code.ptr;

        VkShaderModule shaderModule;
        ThrowIfFailed(vkCreateShaderModule(device, &createInfo, null, &shaderModule), "failed to create shader module!");
        debug writeln("created shader module!");
        return shaderModule;
    }

    bool isDeviceSuitable(VkPhysicalDevice device)
    {
        QueueFamilyIndices indices = findQueueFamilies(device);

        bool extensionsSupported = checkDeviceExtensionSupport(device);
        bool swapChainAdequate = false;

        if(extensionsSupported)
        {
            debug writeln("all extensions supported!");
            SwapChainSupportDetails swapChainSupport = querySwapChainSupport(device);
            swapChainAdequate = swapChainSupport.formats.length != 0 && swapChainSupport.presentModes.length != 0;
        }

        return indices.isComplete() && extensionsSupported && swapChainAdequate;
    }

    bool checkDeviceExtensionSupport(VkPhysicalDevice device)
    {
        import core.stdc.string : strcmp;

        uint extensionCount;
        vkEnumerateDeviceExtensionProperties(device, null, &extensionCount, null);

        VkExtensionProperties[] availableExtensions;
        availableExtensions.length = extensionCount;
        ThrowIfFailed(vkEnumerateDeviceExtensionProperties(device, null, &extensionCount, availableExtensions.ptr), "failed to enumerate available device extensions!");

        string[] requiredExtensions;
        requiredExtensions.length = deviceExtensions.length;
        
        for(size_t i = 0; i < deviceExtensions.length; i++)
        {
            requiredExtensions[i] = deviceExtensions[i];
        }

        for(size_t i = 0; i < availableExtensions.length; i++)
        {
            for(size_t j = 0; j < requiredExtensions.length; j++)
            {
                if(strcmp(cast(char*) availableExtensions[i].extensionName, cast(char*) requiredExtensions[j]) == 0)
                {
                    requiredExtensions[j] = "Extension Found";
                    break;
                }
            }
        }

        foreach(requiredExtension; requiredExtensions)
        {
            if(requiredExtension != "Extension Found")
            {
                writeln("required extension not found! extension: ", requiredExtension);
                return false;
            }
        }

        debug writeln("found all required extensions!");
        return true;
    }

    QueueFamilyIndices findQueueFamilies(VkPhysicalDevice device)
    {
        QueueFamilyIndices indices;
        uint queueFamilyCount = 0;
        vkGetPhysicalDeviceQueueFamilyProperties(device, &queueFamilyCount, null);

        VkQueueFamilyProperties[] queueFamilies;
        queueFamilies.length = queueFamilyCount;
        vkGetPhysicalDeviceQueueFamilyProperties(device, &queueFamilyCount, queueFamilies.ptr);

        int i = 0;
        foreach (queueFamily; queueFamilies)
        {
            if (queueFamily.queueCount > 0 && queueFamily.queueFlags & VK_QUEUE_GRAPHICS_BIT)
            {
                indices.graphicsFamily = i;
            }

            VkBool32 presentSupport = false;
            ThrowIfFailed(vkGetPhysicalDeviceSurfaceSupportKHR(device, i, surface, &presentSupport), "physical device does not support KHR!");

            if (queueFamily.queueCount > 0 && presentSupport)
            {
                indices.presentFamily = i;
            }

            if (indices.isComplete())
            {
                break;
            }

            i++;
        }

        return indices;
    }

    bool checkValidationLayerSupport()
    {
        uint layerCount;
        vkEnumerateInstanceLayerProperties(&layerCount, null);

        VkLayerProperties[] availableLayers;
        availableLayers.length = layerCount;
        ThrowIfFailed(vkEnumerateInstanceLayerProperties(&layerCount, availableLayers.ptr), "failed to enumerate available layers!");

        foreach (layerName; validationLayers)
        {
            bool layerFound = false;

            foreach (layerProperties; availableLayers)
            {
                import core.stdc.string : strcmp;

                if (strcmp(cast(char*) layerName, cast(char*) layerProperties.layerName) == 0)
                {
                    layerFound = true;
                    break;
                }
            }

            if (!layerFound)
            {
                return false;
            }
        }

        return true;
    }

    string[] getRequiredExtensions()
    {
        import std.conv : to;

        uint glfwExtensionCount = 0;
        char** glfwExtensions;
        glfwExtensions = cast(char**) glfwGetRequiredInstanceExtensions(&glfwExtensionCount);
        
        string[] extensions;
        extensions.length = glfwExtensionCount;

        auto tempExtensions = glfwExtensions[0 .. glfwExtensionCount]; // converting char** to char*

        for(size_t i = 0; i < tempExtensions.length; i++)
        {
            extensions[i] = to!string(tempExtensions[i]);
        }

        if (enableValidationLayers)
        {
            extensions ~= VK_EXT_DEBUG_UTILS_EXTENSION_NAME; // append final extension to string array
        }

        return extensions;
    }

    SwapChainSupportDetails querySwapChainSupport(VkPhysicalDevice device)
    {
        SwapChainSupportDetails details;
        ThrowIfFailed(vkGetPhysicalDeviceSurfaceCapabilitiesKHR(device, surface, &details.capabilities), "failed to get physical device surface capabilities!");
        uint formatCount;
        ThrowIfFailed(vkGetPhysicalDeviceSurfaceFormatsKHR(device, surface, &formatCount, null), "failed to get physical device surface format count!");

        if (formatCount != 0)
        {
            details.formats.length = formatCount;
            ThrowIfFailed(vkGetPhysicalDeviceSurfaceFormatsKHR(device, surface, &formatCount, details.formats.ptr), "failed to get physical device surface formats!");
        }

        uint presentModeCount;
        ThrowIfFailed(vkGetPhysicalDeviceSurfacePresentModesKHR(device, surface, &presentModeCount, null), "failed to get physical device surface present mode count!");

        if (presentModeCount != 0)
        {
            details.presentModes.length = presentModeCount;
            ThrowIfFailed(vkGetPhysicalDeviceSurfacePresentModesKHR(device, surface, &presentModeCount, details.presentModes.ptr), "failed to get physical device surface present modes!");
        }

        return details;
    }

    VkSurfaceFormatKHR chooseSwapSurfaceFormat(ref VkSurfaceFormatKHR[] availableFormats)
    {
        VkSurfaceFormatKHR result;

        if(availableFormats.length == 1 && availableFormats[0].format == VK_FORMAT_UNDEFINED)
        {
            result.format = VK_FORMAT_B8G8R8A8_UNORM;
            result.colorSpace = VK_COLOR_SPACE_SRGB_NONLINEAR_KHR;

            return result;
        }

        foreach(availableFormat; availableFormats)
        {
            if(availableFormat.format == VK_FORMAT_B8G8R8A8_UNORM && availableFormat.colorSpace == VK_COLOR_SPACE_SRGB_NONLINEAR_KHR)
            {
                return availableFormat;
            }
        }

        return availableFormats[0];
    }

    VkPresentModeKHR chooseSwapPresentMode(ref VkPresentModeKHR[] availablePresentModes)
    {
        VkPresentModeKHR bestMode = VK_PRESENT_MODE_FIFO_KHR;

        foreach(availablePresentMode; availablePresentModes)
        {
            if(availablePresentMode == VK_PRESENT_MODE_MAILBOX_KHR)
            {
                return availablePresentMode;
            }
            else if(availablePresentMode == VK_PRESENT_MODE_IMMEDIATE_KHR)
            {
                bestMode = availablePresentMode;
            }
        }

        return bestMode;
    }

    VkExtent2D chooseSwapExtent(const ref VkSurfaceCapabilitiesKHR capabilities)
    {
        if (capabilities.currentExtent.width != uint.max)
        {
            return capabilities.currentExtent;
        }
        else
        {
            int width, height;
            glfwGetFramebufferSize(window, &width, &height);

            VkExtent2D actualExtent;
            actualExtent.width = cast(uint) width;
            actualExtent.height = cast(uint) height;

            import std.algorithm : max, min;

            actualExtent.width = max(capabilities.minImageExtent.width, min(capabilities.maxImageExtent.width, actualExtent.width));
            actualExtent.height = max(capabilities.minImageExtent.height, min(capabilities.maxImageExtent.height, actualExtent.height));

            return actualExtent;
        }
    }

    extern (Windows) static void framebufferResizeCallback(GLFWwindow* window, int width, int height)
    {
        auto app = cast(HelloTriangleApplication*) glfwGetWindowUserPointer(window);
        app.framebufferResized = true;
    }

    uint findMemoryType(uint typeFilter, VkMemoryPropertyFlags properties)
    {
        VkPhysicalDeviceMemoryProperties memProperties;
        vkGetPhysicalDeviceMemoryProperties(physicalDevice, &memProperties);

        for (uint i = 0; i < memProperties.memoryTypeCount; i++)
        {
            if ((typeFilter & (1 << i)) && (memProperties.memoryTypes[i].propertyFlags & properties) == properties)
            {
                return i;
            }
        }

        throw new Exception("failed to find suitable memory type!");
    }

    extern (Windows) static VkBool32 debugCallback(VkDebugUtilsMessageSeverityFlagBitsEXT messageSeverity, VkDebugUtilsMessageTypeFlagsEXT messageType, const VkDebugUtilsMessengerCallbackDataEXT* pCallbackData, void* pUserData)
    {
        import core.stdc.string : strlen;

        string prefix;

        if (messageSeverity & VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT)
        {
            prefix = "VERBOSE : ";
        }
        else if (messageSeverity & VK_DEBUG_UTILS_MESSAGE_SEVERITY_INFO_BIT_EXT)
        {
            prefix = "INFO : ";
        }
        else if (messageSeverity & VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT)
        {
            prefix = "WARNING : ";
        }
        else if (messageSeverity & VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT)
        {
            prefix = "ERROR : ";
        }
         
        if (messageType & VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT)
        {
            prefix ~= "GENERAL";
        }
        else
        {
            if (messageType & VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT)
            {
                prefix ~= "VALIDATION";
                validationError = 1;
            }
            if (messageType & VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT)
            {
                if (messageType & VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT)
                {
                    prefix ~= "|";
                }
                prefix ~= "PERFORMANCE";
            }
        }

		writeln("debug messages: ");
        writefln("%s - Message Id Number: %d | Message Id Name: %s", prefix, pCallbackData.messageIdNumber, pCallbackData.pMessageIdName);
		size_t messageLength = strlen(pCallbackData.pMessage);
		auto message = pCallbackData.pMessage[0 .. messageLength];
        writeln("MESSAGE : ", message);

        if (pCallbackData.objectCount > 0)
        {
            writefln("\tObjects - %d", pCallbackData.objectCount);

            for (uint i = 0; i < pCallbackData.objectCount; ++i)
            {
                if (pCallbackData.pObjects[i].pObjectName != null && strlen(pCallbackData.pObjects[i].pObjectName) > 0)
                {
                    writefln("\t\tObject[%d] - %s, Handle %d, Name \"%s\"", i, GetVkObjectTypeString(pCallbackData.pObjects[i].objectType), pCallbackData.pObjects[i].objectHandle, pCallbackData.pObjects[i].pObjectName);
                }
                else
                {
                    writefln("\t\tObject[%d] - %s, Handle %d", i, GetVkObjectTypeString(pCallbackData.pObjects[i].objectType), pCallbackData.pObjects[i].objectHandle);
                }
            }
        }

        if (pCallbackData.cmdBufLabelCount > 0)
        {
            writefln("\n\tCommand Buffer Labels - %d\n", pCallbackData.cmdBufLabelCount);

            for (uint i = 0; i < pCallbackData.cmdBufLabelCount; ++i)
            {
                writefln("\t\tLabel[%d] - %s { %f, %f, %f, %f}\n", i, pCallbackData.pCmdBufLabels[i].pLabelName, pCallbackData.pCmdBufLabels[i].color[0], pCallbackData.pCmdBufLabels[i].color[1],
                        pCallbackData.pCmdBufLabels[i].color[2], pCallbackData.pCmdBufLabels[i].color[3]);
            }
        }
        return VK_FALSE;
    }
}

int main()
{
    HelloTriangleApplication app = new HelloTriangleApplication();

    try
    {
        app.run();
    }

    catch (Exception e)
    {
        writefln("Exception thrown %s", e.msg);
        return 1;
    }

    return 0;
}

VkResult CreateDebugUtilsMessengerEXT(VkInstance instance, const VkDebugUtilsMessengerCreateInfoEXT* pCreateInfo, const VkAllocationCallbacks* pAllocator, VkDebugUtilsMessengerEXT* pDebugMessenger)
{
    auto func = cast(PFN_vkCreateDebugUtilsMessengerEXT) vkGetInstanceProcAddr(instance, "vkCreateDebugUtilsMessengerEXT");
    
    if (func != null)
    {
        return func(instance, pCreateInfo, pAllocator, pDebugMessenger);
    }
    else
    {
        return VK_ERROR_EXTENSION_NOT_PRESENT;
    }
}

void DestroyDebugUtilsMessengerEXT(VkInstance instance, VkDebugUtilsMessengerEXT debugMessenger, const VkAllocationCallbacks* pAllocator)
{
    auto func = cast(PFN_vkDestroyDebugUtilsMessengerEXT) vkGetInstanceProcAddr(instance, "vkDestroyDebugUtilsMessengerEXT");
    if (func != null)
    {
        func(instance, debugMessenger, pAllocator);
    }
}

const (char*)[] toCStringList(string[] list)
{
    import std.string : toStringz; // toStringz() - adds null terminator, allocates using GC if necessary
    import std.array : array; // array() - eagerly converts range to array, allocates using GC
    import std.algorithm : map; // map() - apply function to range
    return list.map!(toStringz).array();
}

static char[] readFile(const string filename)
{
    auto file = File(filename, "r");
    if (!file.isOpen())
    {
        throw new Exception("failed to open file!");
    }
    size_t fileSize = file.size;
    debug writeln("Reading ", file, " of size ", fileSize, " bytes.");

    auto buffer = new char[fileSize];
    buffer = file.rawRead(buffer);
    return buffer;
}

void ThrowIfFailed(VkResult result, string exceptionMessage)
{
    if(result != VK_SUCCESS)
    {
        writeln("Error: ", GetVulkanResultString(result));
        throw new Exception(exceptionMessage);
    }
}

string GetVkObjectTypeString(VkObjectType object)
{
    switch(object)
    {
        case VK_OBJECT_TYPE_QUERY_POOL:
            return "VK_OBJECT_TYPE_QUERY_POOL";
        case VK_OBJECT_TYPE_OBJECT_TABLE_NVX:
            return "VK_OBJECT_TYPE_OBJECT_TABLE_NVX";
        case VK_OBJECT_TYPE_SAMPLER_YCBCR_CONVERSION:
            return "VK_OBJECT_TYPE_SAMPLER_YCBCR_CONVERSION";
        case VK_OBJECT_TYPE_SEMAPHORE:
            return "VK_OBJECT_TYPE_SEMAPHORE";
        case VK_OBJECT_TYPE_SHADER_MODULE:
            return "VK_OBJECT_TYPE_SHADER_MODULE";
        case VK_OBJECT_TYPE_SWAPCHAIN_KHR:
            return "VK_OBJECT_TYPE_SWAPCHAIN_KHR";
        case VK_OBJECT_TYPE_SAMPLER:
            return "VK_OBJECT_TYPE_SAMPLER";
        case VK_OBJECT_TYPE_INDIRECT_COMMANDS_LAYOUT_NVX:
            return "VK_OBJECT_TYPE_INDIRECT_COMMANDS_LAYOUT_NVX";
        case VK_OBJECT_TYPE_DEBUG_REPORT_CALLBACK_EXT:
            return "VK_OBJECT_TYPE_DEBUG_REPORT_CALLBACK_EXT";
        case VK_OBJECT_TYPE_IMAGE:
            return "VK_OBJECT_TYPE_IMAGE";
        case VK_OBJECT_TYPE_UNKNOWN:
            return "VK_OBJECT_TYPE_UNKNOWN";
        case VK_OBJECT_TYPE_DESCRIPTOR_POOL:
            return "VK_OBJECT_TYPE_DESCRIPTOR_POOL";
        case VK_OBJECT_TYPE_COMMAND_BUFFER:
            return "VK_OBJECT_TYPE_COMMAND_BUFFER";
        case VK_OBJECT_TYPE_BUFFER:
            return "VK_OBJECT_TYPE_BUFFER";
        case VK_OBJECT_TYPE_SURFACE_KHR:
            return "VK_OBJECT_TYPE_SURFACE_KHR";
        case VK_OBJECT_TYPE_INSTANCE:
            return "VK_OBJECT_TYPE_INSTANCE";
        case VK_OBJECT_TYPE_VALIDATION_CACHE_EXT:
            return "VK_OBJECT_TYPE_VALIDATION_CACHE_EXT";
        case VK_OBJECT_TYPE_IMAGE_VIEW:
            return "VK_OBJECT_TYPE_IMAGE_VIEW";
        case VK_OBJECT_TYPE_DESCRIPTOR_SET:
            return "VK_OBJECT_TYPE_DESCRIPTOR_SET";
        case VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT:
            return "VK_OBJECT_TYPE_DESCRIPTOR_SET_LAYOUT";
        case VK_OBJECT_TYPE_COMMAND_POOL:
            return "VK_OBJECT_TYPE_COMMAND_POOL";
        case VK_OBJECT_TYPE_PHYSICAL_DEVICE:
            return "VK_OBJECT_TYPE_PHYSICAL_DEVICE";
        case VK_OBJECT_TYPE_DISPLAY_KHR:
            return "VK_OBJECT_TYPE_DISPLAY_KHR";
        case VK_OBJECT_TYPE_BUFFER_VIEW:
            return "VK_OBJECT_TYPE_BUFFER_VIEW";
        case VK_OBJECT_TYPE_DEBUG_UTILS_MESSENGER_EXT:
            return "VK_OBJECT_TYPE_DEBUG_UTILS_MESSENGER_EXT";
        case VK_OBJECT_TYPE_FRAMEBUFFER:
            return "VK_OBJECT_TYPE_FRAMEBUFFER";
        case VK_OBJECT_TYPE_DESCRIPTOR_UPDATE_TEMPLATE:
            return "VK_OBJECT_TYPE_DESCRIPTOR_UPDATE_TEMPLATE";
        case VK_OBJECT_TYPE_PIPELINE_CACHE:
            return "VK_OBJECT_TYPE_PIPELINE_CACHE";
        case VK_OBJECT_TYPE_PIPELINE_LAYOUT:
            return "VK_OBJECT_TYPE_PIPELINE_LAYOUT";
        case VK_OBJECT_TYPE_DEVICE_MEMORY:
            return "VK_OBJECT_TYPE_DEVICE_MEMORY";
        case VK_OBJECT_TYPE_FENCE:
            return "VK_OBJECT_TYPE_FENCE";
        case VK_OBJECT_TYPE_QUEUE:
            return "VK_OBJECT_TYPE_QUEUE";
        case VK_OBJECT_TYPE_DEVICE:
            return "VK_OBJECT_TYPE_DEVICE";
        case VK_OBJECT_TYPE_RENDER_PASS:
            return "VK_OBJECT_TYPE_RENDER_PASS";
        case VK_OBJECT_TYPE_DISPLAY_MODE_KHR:
            return "VK_OBJECT_TYPE_DISPLAY_MODE_KHR";
        case VK_OBJECT_TYPE_EVENT:
            return "VK_OBJECT_TYPE_EVENT";
        case VK_OBJECT_TYPE_PIPELINE:
            return "VK_OBJECT_TYPE_PIPELINE";
        default:
            return "Unhandled VkObjectType";
    }
}

string GetVulkanResultString(VkResult result)
{
    switch (result)
    {
        case VK_SUCCESS:
            return "Success";
        case VK_NOT_READY:
            return "A fence or query has not yet completed";
        case VK_TIMEOUT:
            return "A wait operation has not completed in the specified time";
        case VK_EVENT_SET:
            return "An event is signaled";
        case VK_EVENT_RESET:
            return "An event is unsignaled";
        case VK_INCOMPLETE:
            return "A return array was too small for the result";
        case VK_ERROR_OUT_OF_HOST_MEMORY:
            return "A host memory allocation has failed";
        case VK_ERROR_OUT_OF_DEVICE_MEMORY:
            return "A device memory allocation has failed";
        case VK_ERROR_INITIALIZATION_FAILED:
            return "Initialization of an object could not be completed for implementation-specific reasons";
        case VK_ERROR_DEVICE_LOST:
            return "The logical or physical device has been lost";
        case VK_ERROR_MEMORY_MAP_FAILED:
            return "Mapping of a memory object has failed";
        case VK_ERROR_LAYER_NOT_PRESENT:
            return "A requested layer is not present or could not be loaded";
        case VK_ERROR_EXTENSION_NOT_PRESENT:
            return "A requested extension is not supported";
        case VK_ERROR_FEATURE_NOT_PRESENT:
            return "A requested feature is not supported";
        case VK_ERROR_INCOMPATIBLE_DRIVER:
            return "The requested version of Vulkan is not supported by the driver or is otherwise incompatible";
        case VK_ERROR_TOO_MANY_OBJECTS:
            return "Too many objects of the type have already been created";
        case VK_ERROR_FORMAT_NOT_SUPPORTED:
            return "A requested format is not supported on this device";
        case VK_ERROR_SURFACE_LOST_KHR:
            return "A surface is no longer available";
        case VK_SUBOPTIMAL_KHR:
            return "A swapchain no longer matches the surface properties exactly, but can still be used";
        case VK_ERROR_OUT_OF_DATE_KHR:
            return "A surface has changed in such a way that it is no longer compatible with the swapchain";
        case VK_ERROR_INCOMPATIBLE_DISPLAY_KHR:
            return "The display used by a swapchain does not use the same presentable image layout";
        case VK_ERROR_NATIVE_WINDOW_IN_USE_KHR:
            return "The requested window is already connected to a VkSurfaceKHR, or to some other non-Vulkan API";
        case VK_ERROR_VALIDATION_FAILED_EXT:
            return "A validation layer found an error";
        default:
            return "ERROR: UNKNOWN VULKAN ERROR";
    }
}
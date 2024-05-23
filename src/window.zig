const std = @import("std");
const glfw = @cImport({
    @cDefine("GLFW_INCLUDE_VULKAN", {});
    @cInclude("GLFW/glfw3.h");
});

const cStd = @cImport({
    @cInclude("stdio.h");
});

const validationLayers = [_][]const u8{
    "VK_LAYER_KHRONOS_validation",
};

const WindowError = error{
    GlfwInitWindowError,
    GlfwCreateWindowError,
    VulkanInitError,
    VulkanMissingExtensionSupport,
    OutOfMemory,
};

pub fn createWindow() WindowError!Window {
    const window = try initWindow();

    try initVulkan();

    return Window{
        .window = window,
    };
}

pub const Window = struct {
    window: *glfw.GLFWwindow,
    shouldClose: bool = false,

    pub fn update(self: *Window) void {
        self.shouldClose = glfw.glfwWindowShouldClose(self.window) == 0;

        glfw.glfwPollEvents();
    }

    pub fn destroy(self: Window) void {
        glfw.glfwDestroyWindow(self.window);
        glfw.glfwTerminate();
    }
};

export fn glfwErrorCallback(errorCode: c_int, description: [*c]const u8) void {
    const stdout = std.io.getStdOut().writer();
    stdout.print("Error {}: {s}\n", .{ errorCode, description }) catch |err| {
        std.debug.print("Error: {}", .{err});
    };
}

fn initWindow() WindowError!*glfw.struct_GLFWwindow {
    _ = glfw.glfwSetErrorCallback(glfwErrorCallback);

    const init = glfw.glfwInit();

    if (init == 0) {
        return WindowError.GlfwInitWindowError;
    }

    glfw.glfwWindowHint(glfw.GLFW_CLIENT_API, glfw.GLFW_NO_API);
    const window = glfw.glfwCreateWindow(640, 480, "Test", null, null) orelse {
        glfw.glfwTerminate();
        return WindowError.GlfwCreateWindowError;
    };

    return window;
}

fn initVulkan() WindowError!void {
    var appInfo = try createVulkanInstance();
    var createInfo = glfw.struct_VkInstanceCreateInfo{
        .sType = glfw.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
        .pApplicationInfo = &appInfo,
    };

    var glfwExtensionCount: c_uint = 0;
    const glfwExtensions = glfw.glfwGetRequiredInstanceExtensions(&glfwExtensionCount);
    createInfo.enabledLayerCount = glfwExtensionCount;
    createInfo.ppEnabledExtensionNames = glfwExtensions;

    createInfo.enabledLayerCount = 0;

    var instance: glfw.VkInstance = undefined;

    const result: glfw.VkResult = glfw.vkCreateInstance(&createInfo, null, &instance);

    if (result == glfw.VK_SUCCESS) return;

    return WindowError.VulkanInitError;
}

fn createVulkanInstance() WindowError!glfw.VkApplicationInfo {
    if (!try checkValidationLayerSuport()) {
        return WindowError.VulkanMissingExtensionSupport;
    }

    const appInfo = glfw.VkApplicationInfo{
        .sType = glfw.VK_STRUCTURE_TYPE_APPLICATION_INFO,
        .pApplicationName = "Zig Vulkan Test",
        .applicationVersion = glfw.VK_MAKE_VERSION(0, 0, 1),
        .pEngineName = "No engine",
        .engineVersion = glfw.VK_MAKE_VERSION(0, 0, 1),
        .apiVersion = glfw.VK_API_VERSION_1_0,
    };

    return appInfo;
}

fn checkValidationLayerSuport() WindowError!bool {
    var layerCount: c_uint = 0;
    _ = glfw.vkEnumerateInstanceLayerProperties(&layerCount, null);

    const allocator = std.heap.page_allocator;
    const properties = allocator.alloc(glfw.VkLayerProperties, layerCount) catch return WindowError.OutOfMemory;
    defer allocator.free(properties);

    _ = glfw.vkEnumerateInstanceLayerProperties(&layerCount, properties.ptr);

    for (validationLayers) |layerName| {
        var found = false;

        for (properties) |property| {
            const propertyName = std.mem.span(@as([*:0]const u8, @ptrCast(&property.layerName)));
            std.debug.print("A: {s}, B: {s}\n", .{ property.layerName, layerName });
            if (std.mem.eql(u8, layerName, propertyName)) {
                found = true;
                break;
            }
        }

        if (found == false) {
            std.debug.print("ValidationLayer not supported: {s}\n", .{layerName});
            return false;
        }
    }

    return true;
}

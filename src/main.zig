const std = @import("std");
const glfw = @cImport({
    @cInclude("GLFW/glfw3.h");
});
const cStd = @cImport({
    @cInclude("stdio.h");
});

export fn glfwErrorCallback(errorCode: c_int, description: [*c]const u8) void {
    const stdout = std.io.getStdOut().writer();
    stdout.print("Error {}: {s}\n", .{ errorCode, description }) catch |err| {
        std.debug.print("Error: {}", .{err});
    };
}

pub fn main() !void {
    _ = glfw.glfwSetErrorCallback(glfwErrorCallback);

    const init = glfw.glfwInit();

    if (init == 0) {
        std.debug.print("Failed to init\n", .{});
        return;
    }

    const window = glfw.glfwCreateWindow(640, 480, "Test", null, null);

    if (window == null) {
        glfw.glfwTerminate();
        std.debug.print("failed to create window\n", .{});
        return;
    }

    glfw.glfwMakeContextCurrent(window);

    while (glfw.glfwWindowShouldClose(window) == 0) {
        glfw.glfwPollEvents();
    }

    glfw.glfwTerminate();
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

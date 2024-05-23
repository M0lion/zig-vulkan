const std = @import("std");
const w = @import("./window.zig");
pub fn main() !void {
    std.debug.print("Vulkan init success\n", .{});

    var window = try w.createWindow();
    defer window.destroy();

    while (!window.shouldClose) {
        window.update();
    }
}

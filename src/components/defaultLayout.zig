const std = @import("std");

pub fn DefaultLayout(comptime component: type) type {
    return struct {
        content: component,

        pub fn format(
            value: @This(),
            comptime fmt: []const u8,
            options: std.fmt.FormatOptions,
            writer: anytype,
        ) !void {
            _ = fmt;
            _ = options;

            try writer.print(
                \\<!doctype html>
                \\<html lang="en">
                \\  <head>
                \\      <title>Contact App</title>
                \\      <link rel="stylesheet" href="https://unpkg.com/missing.css@1.1.1">
                \\      <style>
                \\          :root{{
                \\              --accent: var(--teal-10);
                \\          }}
                \\      </style>
                \\  </head>
                \\  <body>
                \\      <main>
                \\          <header>
                \\              <h1>
                \\                  <span class="allcaps">contacts.app</span>
                \\                  <span class="sub-title">A Demo Contacts Application</span>
                \\              </h1>
                \\          </header>
                \\          {}
                \\      </main>
                \\  </body>
                \\</html>
            , .{value.content});
        }
    };
}

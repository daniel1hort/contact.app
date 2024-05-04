const std = @import("std");
const Contact = @import("../models/contact.zig");

contacts: []const Contact,
query: ?[]const u8,

pub fn format(
    value: @This(),
    comptime fmt: []const u8,
    options: std.fmt.FormatOptions,
    writer: anytype,
) !void {
    _ = fmt;
    _ = options;

    try writer.print(
        \\<form method="get" action="/contacts" class="tool-bar">
        \\  <label for="search">Search Term</label>
        \\  <input id="search" type="text" name="q" value="{s}" autofocus />
        \\  <input type="submit" value="Search" />
        \\</form>
        \\
        \\<table style="margin-top: 12px;">
        \\  <thead>
        \\      <tr>
        \\          <td>Firstname</td>
        \\          <td>Lastname</td>
        \\          <td>Phone</td>
        \\          <td>Email</td>
        \\          <td></td>
        \\      </tr>
        \\  </thead>
        \\  <tbody>
        \\
    , .{value.query orelse ""});
    for (value.contacts) |contact| {
        if (value.query == null or value.query.?.len <= 0 or std.mem.containsAtLeast(
            u8,
            contact.email,
            1,
            value.query.?,
        ))
            try writer.print(
                \\      <tr>
                \\          <td>{s}</td>
                \\          <td>{s}</td>
                \\          <td>{s}</td>
                \\          <td>{s}</td>
                \\          <td>
                \\              <a href="/contacts/{d}/edit">Edit</a>
                \\              <a href="/contacts/{d}">View</a>
                \\          </td>
                \\      </tr>
                \\
            , .{
                contact.firstname,
                contact.lastname,
                contact.phone,
                contact.email,
                contact.id,
                contact.id,
            });
    }
    try writer.print(
        \\  </tbody>
        \\</table>
        \\
        \\<p>
        \\  <a href="/contacts/new">Add Contact</a>
        \\</p>
        \\
    , .{});
}

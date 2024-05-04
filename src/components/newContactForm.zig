const std = @import("std");
const Contact = @import("../models/contact.zig");

contact: ?Contact = null,

pub fn format(
    value: @This(),
    comptime fmt: []const u8,
    options: std.fmt.FormatOptions,
    writer: anytype,
) !void {
    _ = fmt;
    _ = options;

    try writer.print(
        \\<form action="/contacts/new" method="post">
        \\  <fieldset>
        \\      <legend>Contact Values</legend>
        \\      
        \\      <p>
        \\          <label for="email">Email</label>
        \\          <input name="email" id="email" type="email" placeholder="Email" value="{s}" />
        \\      </p>
        \\      <p>
        \\          <label for="first_name">First Name</label>
        \\          <input name="first_name" id="first_name" type="text" placeholder="First Name" value="{s}" />
        \\      </p>
        \\      <p>
        \\          <label for="last_name">Last Name</label>
        \\          <input name="last_name" id="first_name" type="text" placeholder="Last Name" value="{s}" />
        \\      </p>
        \\      <p>
        \\          <label for="phone">Phone</label>
        \\          <input name="phone" id="phone" type="text" placeholder="Phone" value="{s}" />
        \\      </p>
        \\      
        \\      <input type="submit" value="Save" />
        \\  </fieldset>
        \\</form>
        \\
        \\<p>
        \\  <a href="/contacts">Back</a>
        \\</p>
        \\
    , .{
        if (value.contact) |c| c.email else "",
        if (value.contact) |c| c.firstname else "",
        if (value.contact) |c| c.lastname else "",
        if (value.contact) |c| c.phone else "",
    });
}

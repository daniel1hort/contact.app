const std = @import("std");
const Contact = @import("./models/contact.zig");
const ContractsList = @import("./components/contractsList.zig");
const NewContactForm = @import("./components//newContactForm.zig");
const DefaultLayout = @import("./components/defaultLayout.zig").DefaultLayout;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const address = try std.net.Address.parseIp4("0.0.0.0", 5000);
    var server = try address.listen(.{});
    defer server.deinit();

    var read_buffer: [1024 * 8]u8 = undefined;
    var write_buffer: [1024 * 8]u8 = undefined;
    var stream = std.io.fixedBufferStream(&write_buffer);
    const writer = stream.writer();

    var contacts = try initContacts(allocator);
    defer contacts.deinit();

    //TODO(daniel): arena allocator for each request
    while (true) {
        const conn = try server.accept();
        defer conn.stream.close();
        stream.reset();

        var http = std.http.Server.init(conn, &read_buffer);
        var request = http.receiveHead() catch |err| switch (err) {
            error.HttpHeadersOversize => continue,
            else => continue,
        };

        var target_it = std.mem.splitScalar(u8, request.head.target, '?');
        const path = target_it.next().?;
        const query_string = target_it.next();
        var query_params = try parseQueryParams(allocator, query_string);
        defer query_params.deinit();

        var context: std.http.Server.Request.RespondOptions = .{};

        //TODO(daniel): abstraction 
        //  if(matchPath(GET, "/contacts/{int}/new", path))
        //  redirect(.permanent_redirect, "/contacts");
        //  page(DefaultLayout, ContractsList, content, mime_type) though almost always mime_type = "text/html"
        //  staticPage(path) mime_type is determined from the file extension
        //  errorPage(.not_found)
        switch (request.head.method) {
            .GET => {
                if (std.mem.eql(u8, "/", path)) {
                    context.status = .permanent_redirect;
                    context.extra_headers = &.{
                        .{ .name = "Location", .value = "/contacts" },
                    };
                } else if (std.mem.eql(u8, path, "/contacts")) {
                    const page = DefaultLayout(ContractsList){
                        .content = .{
                            .contacts = contacts.items,
                            .query = query_params.get("q"),
                        },
                    };
                    try writer.print("{any}", .{page});

                    context.extra_headers = &.{
                        .{ .name = "Content-Type", .value = "text/html" },
                    };
                } else if (std.mem.eql(u8, path, "/contacts/new")) {
                    const page = DefaultLayout(NewContactForm){
                        .content = .{},
                    };
                    try writer.print("{any}", .{page});

                    context.extra_headers = &.{
                        .{ .name = "Content-Type", .value = "text/html" },
                    };
                } else {
                    context.status = .not_found;
                }
            },
            .POST => {
                if (std.mem.eql(u8, path, "/contacts/new")) {
                    var buffer: [1024 * 8]u8 = undefined;
                    const reader = try request.reader();
                    const read_count = try reader.readAll(&buffer);
                    var form_data = try parseQueryParams(
                        allocator,
                        buffer[0..read_count],
                    );
                    defer form_data.deinit();

                    const contact: Contact = .{
                        .id = 0,
                        .email = form_data.get("email") orelse "",
                        .firstname = form_data.get("first_name") orelse "",
                        .lastname = form_data.get("last_name") orelse "",
                        .phone = form_data.get("phone") orelse "",
                    };

                    const valid = contact.Valid();

                    if (valid) {
                        try contacts.append(try contact.copyAlloc(allocator));
                        context.status = .see_other;
                        context.extra_headers = &.{
                            .{ .name = "Location", .value = "/contacts" },
                        };
                    } else {
                        const page = DefaultLayout(NewContactForm){
                            .content = .{
                                .contact = contact,
                            },
                        };
                        try writer.print("{any}", .{page});

                        context.extra_headers = &.{
                            .{ .name = "Content-Type", .value = "text/html" },
                        };
                    }
                }
            },
            else => {
                try writer.print("<h1>Haha Muie</h1>\n", .{});
                context.status = .method_not_allowed;
                context.extra_headers = &.{
                    .{ .name = "Content-Type", .value = "text/html" },
                };
            },
        }

        //TODO(daniel): catch err
        try request.respond(stream.getWritten(), context);
    }
}

//TODO(daniel): don't assume it's well-formed
//TODO(daniel): replace escaped characters like %20
fn parseQueryParams(
    allocator: std.mem.Allocator,
    query_string: ?[]const u8,
) !std.StringArrayHashMap([]const u8) {
    if (query_string) |query| {
        var query_params_it = std.mem.splitScalar(u8, query, '&');
        var query_params_map = std.StringArrayHashMap([]const u8).init(allocator);
        while (query_params_it.next()) |query_param| {
            var query_param_it = std.mem.splitScalar(u8, query_param, '=');
            const name = query_param_it.next().?;
            const value = query_param_it.next().?;
            try query_params_map.put(name, value);
        }
        return query_params_map;
    } else {
        return std.StringArrayHashMap([]const u8).init(allocator);
    }
}

//TODO(daniel): extract "persistence" away
fn initContacts(allocator: std.mem.Allocator) !std.ArrayList(Contact) {
    var list = std.ArrayList(Contact).init(allocator);
    try list.append(.{
        .id = 1,
        .firstname = "John",
        .lastname = "Doe",
        .phone = "0123456789",
        .email = "my.email@hotmail.com",
    });
    try list.append(.{
        .id = 2,
        .firstname = "John",
        .lastname = "Deer",
        .phone = "0123456789",
        .email = "sexyman69@hotmail.com",
    });
    return list;
}

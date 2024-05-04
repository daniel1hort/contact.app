const std = @import("std");

id: u32,
firstname: []const u8,
lastname: []const u8,
phone: []const u8,
email: []const u8,

//TODO(daniel): fix memory leak
pub fn copyAlloc(self: @This(), allocator: std.mem.Allocator) !@This() {
    const email = try allocator.alloc(u8, self.email.len);
    std.mem.copyForwards(u8, email, self.email);

    const firstname = try allocator.alloc(u8, self.firstname.len);
    std.mem.copyForwards(u8, firstname, self.firstname);

    const lastname = try allocator.alloc(u8, self.lastname.len);
    std.mem.copyForwards(u8, lastname, self.lastname);

    const phone = try allocator.alloc(u8, self.phone.len);
    std.mem.copyForwards(u8, phone, self.phone);

    return .{
        .id = self.id,
        .email = email,
        .firstname = firstname,
        .lastname = lastname,
        .phone = phone,
    };
}

//TODO(daniel): more validations
//TODO(daniel): return error messages
pub fn Valid(self: @This()) bool {
    if (self.email.len == 0 or std.mem.trim(u8, self.email, &std.ascii.whitespace).len == 0) {
        return false;
    }

    if (self.firstname.len == 0 or std.mem.trim(u8, self.firstname, &std.ascii.whitespace).len == 0) {
        return false;
    }

    if (self.lastname.len == 0 or std.mem.trim(u8, self.lastname, &std.ascii.whitespace).len == 0) {
        return false;
    }

    if (self.phone.len == 0 or std.mem.trim(u8, self.phone, &std.ascii.whitespace).len == 0) {
        return false;
    }

    return true;
}

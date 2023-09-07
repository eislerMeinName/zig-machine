const builtin = @import("builtin");
const std = @import("std");
const io = std.io;
const fmt = std.fmt;
const StateMachine = @import("states.zig").StateMachine;
const State = @import("states.zig").State;

pub fn main() !void {
    const stdout = io.getStdOut().writer();
    const stdin = io.getStdIn();
    var statemachine = StateMachine{ .last_state = State.s0, .curr_state = State.s0, .command = 'i', .info = 0 };
    statemachine.getStateInfo();

    while (true) {
        try stdout.print("\nInput: ", .{});
        var line_buf: [20]u8 = undefined;

        const amt = try stdin.read(&line_buf);
        if (amt == line_buf.len) {
            try stdout.print("Input too long.\n", .{});
            continue;
        }
        const line = std.mem.trimRight(u8, line_buf[0..amt], "\r\n");
        statemachine.multipletransition(line);
    }
}

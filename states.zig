const std = @import("std");
const print = @import("std").debug.print;

pub const State = enum { s0, s1, s2, s3, s4, s5, s6, s7, s8 };

pub const StateMachine = struct {
    last_state: State,
    curr_state: State,
    command: u8,
    info: u8,

    pub fn transition(self: *StateMachine, input: u8) void {
        switch (self.curr_state) {
            State.s0 => {
                self.last_state = State.s0;
                if (input == 's') {
                    self.curr_state = State.s1;
                    self.command = 's';
                } else if (input == 'p') {
                    self.curr_state = State.s2;
                    self.command = 'p';
                } else if (input == 'a') {
                    self.curr_state = State.s3;
                    self.command = 'a';
                } else {
                    self.curr_state = State.s4;
                }
            },
            State.s1 => {
                self.last_state = State.s1;
                const number: u8 = input - 48;
                self.curr_state = if (0 <= number and number <= 9) State.s6 else State.s4;
                self.info += 10 * number;
            },
            State.s2 => {
                self.last_state = State.s2;
                const number: u8 = input - 48;
                self.curr_state = if (0 <= number and number <= 9) State.s6 else State.s4;
                self.info += 10 * number;
            },
            State.s3 => {
                self.last_state = State.s3;
                const number: u8 = input - 48;
                if (input == 0) {
                    self.curr_state = State.s7;
                }
                if (input == 1) {
                    self.curr_state = State.s8;
                } else {
                    self.curr_state = State.s4;
                }
                self.info += 2 * number;
            },
            State.s4 => {
                self.last_state = State.s4;
            },
            State.s5 => {
                self.last_state = State.s5;
            },
            State.s6 => {
                self.last_state = State.s6;
                const number: u8 = input - 48;
                self.curr_state = if (0 <= number and number <= 9) State.s5 else State.s4;
                self.info += number;
            },
            State.s7 => {
                self.last_state = State.s7;
                const number: u8 = input - 48;
                self.curr_state = if (0 <= number and number <= 1) State.s5 else State.s4;
                self.info += number;
            },
            State.s8 => {
                self.last_state = State.s8;
                const number: u8 = input - 48;
                self.curr_state = if (0 == number) State.s5 else State.s4;
            },
        }
        self.writeTransition(input);
    }

    pub fn multipletransition(self: *StateMachine, input: anytype) void {
        for (input) |c| {
            self.transition(c);
            self.getStateInfo();
        }

        if (self.curr_state == State.s4 or self.curr_state == State.s5) {
            self.reset();
        }
    }

    pub fn writeTransition(self: *StateMachine, input: u8) void {
        print("Transitioning from state {s} to state {s} with input {c}.\n", .{ @tagName(self.last_state), @tagName(self.curr_state), input });
    }

    pub fn getStateInfo(self: *StateMachine) void {
        switch (self.curr_state) {
            State.s0 => print("Currently in starting state ({s}) and awaiting input.", .{@tagName(self.curr_state)}),
            State.s1 => print("Currently sending starting command (state {s}). Waiting for time tag.", .{@tagName(self.curr_state)}),
            State.s2 => print("Currently sending solar panel command (state {s}). Waiting for time tag.", .{@tagName(self.curr_state)}),
            State.s3 => print("Currently sending attitude command (state {s}). Waiting for code of subsystem.", .{@tagName(self.curr_state)}),
            State.s4 => print("Command Failed (state {s}).", .{@tagName(self.curr_state)}),
            State.s5 => {
                if (self.last_state == State.s7 or self.last_state == State.s8) {
                    if (self.info == 0) {
                        print("Command succeeded (state {s}, command {c}, subsystem: cpu).", .{ @tagName(self.curr_state), self.command });
                    } else if (self.info == 1) {
                        print("Command succeeded (state {s}, command {c}, subsystem: camera).", .{ @tagName(self.curr_state), self.command });
                    } else if (self.info == 2) {
                        print("Command succeeded (state {s}, command {c}, subsystem: reaction wheels).", .{ @tagName(self.curr_state), self.command });
                    }
                } else {
                    print("Command succeeded (state {s}, command {c}, info {}s).", .{ @tagName(self.curr_state), self.command, self.info });
                }
            },
            State.s6 => print("Currently sending {} command (state {s}). Waiting for last digit of time tag.", .{ self.command, @tagName(self.curr_state) }),
            State.s7 => print("Currently sending attitude command (state {s}). Waiting for last digit of code.", .{@tagName(self.curr_state)}),
            State.s8 => print("Currently sending attitude command (state {s}). Waiting for last digit of code.", .{@tagName(self.curr_state)}),
        }
        print("\n", .{});
    }

    pub fn reset(self: *StateMachine) void {
        self.last_state = State.s0;
        self.curr_state = State.s0;
        self.command = 'i';
        self.info = 0;
        print("Resetting Statemachine.", .{});
    }
};

pub fn main() void {
    var statemachine = StateMachine{ .last_state = State.s0, .curr_state = State.s0, .command = 'i', .info = 0 };
    statemachine.multipletransition("s37");
}

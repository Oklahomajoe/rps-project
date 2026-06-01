-- rps_dissector.lua
-- Custom Wireshark Lua dissector for the Rock Paper Scissors TCP protocol.
--
-- Protocol examples:
-- HELO:Alice
-- PLAY:Alice:ROCK
-- STAT:Server:WIN:PAPER beats ROCK
-- ERROR:INVALID_MOVE:SPOCK

-- Create a new protocol object.
local rps_proto = Proto("rps", "Rock Paper Scissors Protocol")

-- Define protocol fields shown in Wireshark.
local f_raw         = ProtoField.string("rps.raw", "Raw Message")
local f_command     = ProtoField.string("rps.command", "Command")
local f_username    = ProtoField.string("rps.username", "Username")
local f_move        = ProtoField.string("rps.move", "Move")
local f_sender      = ProtoField.string("rps.sender", "Sender")
local f_verdict     = ProtoField.string("rps.verdict", "Verdict")
local f_description = ProtoField.string("rps.description", "Description")
local f_error_type  = ProtoField.string("rps.error_type", "Error Type")

-- Register fields with the protocol.
rps_proto.fields = {
    f_raw,
    f_command,
    f_username,
    f_move,
    f_sender,
    f_verdict,
    f_description,
    f_error_type
}

-- Helper function: split a string by colon.
local function split_colon(input)
    local fields = {}

    for part in string.gmatch(input, "([^:]+)") do
        table.insert(fields, part)
    end

    return fields
end

-- Main dissector function.
function rps_proto.dissector(buffer, pinfo, tree)
    local length = buffer:len()

    -- Do nothing for empty TCP payloads.
    if length == 0 then
        return
    end

    -- Convert packet payload to string.
    local payload = buffer(0, length):string()

    -- Only dissect packets that look like our protocol.
    if not (
        payload:match("^HELO:") or
        payload:match("^PLAY:") or
        payload:match("^STAT:") or
        payload:match("^ERROR:")
    ) then
        return
    end

    -- Set protocol column in Wireshark.
    pinfo.cols.protocol = "RPS"

    -- Create the main protocol tree.
    local subtree = tree:add(rps_proto, buffer(), "Rock Paper Scissors Protocol")
    subtree:add(f_raw, buffer(0, length), payload)

    -- Remove line endings.
    payload = payload:gsub("\r", "")
    payload = payload:gsub("\n", "")

    -- Split protocol fields.
    local fields = split_colon(payload)
    local command = fields[1] or ""

    subtree:add(f_command, buffer(0, 0), command):set_generated(true)

    -- Parse HELO:Username
    if command == "HELO" then
        local username = fields[2] or ""
        subtree:add(f_username, buffer(0, 0), username):set_generated(true)
        pinfo.cols.info = "RPS HELO from " .. username

    -- Parse PLAY:Username:MOVE
    elseif command == "PLAY" then
        local username = fields[2] or ""
        local move = fields[3] or ""
        subtree:add(f_username, buffer(0, 0), username):set_generated(true)
        subtree:add(f_move, buffer(0, 0), move):set_generated(true)
        pinfo.cols.info = "RPS PLAY " .. username .. " -> " .. move

    -- Parse STAT:Server:VERDICT:Description
    elseif command == "STAT" then
        local sender = fields[2] or ""
        local verdict = fields[3] or ""
        local description = fields[4] or ""
        subtree:add(f_sender, buffer(0, 0), sender):set_generated(true)
        subtree:add(f_verdict, buffer(0, 0), verdict):set_generated(true)
        subtree:add(f_description, buffer(0, 0), description):set_generated(true)
        pinfo.cols.info = "RPS STAT " .. verdict .. " - " .. description

    -- Parse ERROR:Type:Description
    elseif command == "ERROR" then
        local error_type = fields[2] or ""
        local description = fields[3] or ""
        subtree:add(f_error_type, buffer(0, 0), error_type):set_generated(true)
        subtree:add(f_description, buffer(0, 0), description):set_generated(true)
        pinfo.cols.info = "RPS ERROR " .. error_type .. " - " .. description
    end
end

-- Bind this dissector to TCP port 12345.
local tcp_port_table = DissectorTable.get("tcp.port")
tcp_port_table:add(12345, rps_proto)

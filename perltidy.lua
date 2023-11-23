-- mod-version:3
local core = require "core"
local command = require "core.command"
local keymap = require "core.keymap"

local PERLTIDY_EXECUTABLE = "perltidy"

local function exec(cmd)
  local file_handle = io.popen(cmd, "r")
  local res = file_handle:read("*a")
  local success = file_handle:close()
  return res:gsub("%\n$", ""), success
end

local function get_doc_name(doc)
  return doc and system.absolute_path(doc.filename or "")
end

local function update_doc(doc)
  local cmd = string.format("%s --standard-output %s", PERLTIDY_EXECUTABLE, get_doc_name(doc))

  local text, success = exec(cmd)

  if success == nil then
    core.error("Perltidy is not on your path, you can edit perltidy.lua to change to an absolute path")
    return
  end

  local selection = { doc:get_selection() }
  doc:remove(1, 1, math.huge, math.huge)
  doc:insert(1, 1, text)
  doc:set_selection(table.unpack(selection))
  command.perform "doc:save"
end

command.add("core.docview!", {
  ["perltidy:perltidy"] = function(dv)
    update_doc(dv.doc)
  end
})

keymap.add {
  ["ctrl+i"] = "perltidy:perltidy"
}

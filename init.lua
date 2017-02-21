-- contact/init.lua

contact         = {}
local modpath   = minetest.get_modpath("contact")
local worldpath = minetest.get_worldpath()

-- Formspec GUI related stuff
contact.gui_bg = "bgcolor[#080808BB;true]background[5,5;1,1;gui_formbg.png;true]"

-- [function] Logger
function contact.log(content, log_type)
  assert(content, "contact.log: content nil")
  if log_type == nil then log_type = "action" end
  minetest.log(log_type, "[contact] "..content)
end

-- [function] Load
function contact.load()
  local res = io.open(worldpath.."/mod_contact.txt", "r")
  if res then
    res = minetest.deserialize(res:read("*all"))
    if type(res) == "table" then
      contact.reports = res.reports
      contact.msg     = res.msg
    end
  end

  -- Initialize sub-tables
  if not contact.reports then
    contact.reports = {}
  end
  if not contact.msg then
    contact.msg = {}
  end
end

-- [function] Save
function contact.save()
  local data = {
    reports = contact.reports,
    msg     = contact.msg
  }

  io.open(worldpath.."/mod_contact.txt", "w"):write(minetest.serialize(data))
end

-- Save on shutdown
minetest.register_on_shutdown(contact.save)

-- Load on start
contact.load()

-- Load Resources

dofile(modpath.."/contact.lua") -- Contact Functionality
dofile(modpath.."/report.lua")  -- Report Functionality

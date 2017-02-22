-- contact/report.lua

local reasons = {
  "Breaking Rules",
  "Hacking",
  "Other",
}

local function formspec(target, err)
  -- Require 'target' parameter
  if not target or target == "" then
    return
  end

  local e   = minetest.formspec_escape
  local err = err or {}

  local fields  = err.fields or {}
  fields.reason = fields.reason or 1
  fields.info   = fields.info or ""

  err.msg = err.msg or ""

  local reasons = table.concat(reasons, ",")

  return [[
    size[9,8.9]
    ]]..contact.gui_bg..[[
    label[0.25,0.5;Target Player: ]]..e(target)..[[]
    field[100,100;1,1;target;;]]..e(target)..[[]
    button_exit[7.7,0.38;1,1;exit;X]
    tooltip[exit;Discard and Close]
    dropdown[0.2,1.5;9.05;reason;Reason,]]..reasons..[[;]]..fields.reason..[[]
    textarea[0.5,2.7;8.5,6;info;Information (optional);]]..e(fields.info)..[[]
    button[0.21,8;8.5,1;file;File Report]
    label[0.25,8.8;]]..e(err.msg)..[[]
  ]]
end

-- [function] Toggle Report Formspec
function contact.toggle_report(name, target, show, err)
  -- Check if name is valid
  if not minetest.get_player_by_name(name) then
    return
  end

  if show ~= false then
    -- Check if target is valid
    if not minetest.get_player_by_name(target) then
      return
    end

    minetest.show_formspec(name, "contact:main", formspec(target, err))
  else
    minetest.close_formspec(name, "contact:main")
  end
end

-- [event] Handle Form Input
minetest.register_on_player_receive_fields(function(player, formname, fields)
  if formname ~= "contact:main" then return end -- Check formname

  local name = player:get_player_name()

  if fields.file then
    -- Check for missing fields
    if not fields.reason or fields.reason == "Reason" then
      contact.toggle_report(name, "", true, { msg = "Must select reason", fields = fields })
    else -- else, Send message
      local report = {
        from    = name,
        reason  = fields.reason,
        target  = fields.target,
        info    = fields.info,
        dtime   = contact.date(),
      }

      -- Insert Data
      table.insert(contact.reports, report)
      -- Close form
      contact.toggle_report(name, "", false)
      -- Print to chat
      minetest.chat_send_player(name, "Report filed!")
    end
  end
end)

-- [register] Report Chatcommand
minetest.register_chatcommand("report", {
  params = "<target name>",
  description = "Report a player to an admin",
  func = function(name, target)
    -- Validate target player name
    if not minetest.get_player_by_name(target) then
      return false, "Invalid target player (/report <target name>)"
    end
    -- Prevent from targeting themself
    if name == target then
      return false, "Unable to file a report for yourself, use /contact instead"
    end

    -- Show formspec
    contact.toggle_report(name, target, true)

    return true, "Preparing report form"
  end,
})

contact.log("Loaded Report Functionality", "info")

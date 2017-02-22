-- contact/contact.lua

-- Formspec
local function formspec(error, fields)
  local error  = error or ""
  local fields = fields or {}
  local e      = minetest.formspec_escape

  fields.subject = fields.subject or ""
  fields.msg     = fields.msg or ""

  return [[
    size[9,8.9]
    ]]..contact.gui_bg..[[
    field[0.5,0.7;7.5,1;subject;Message Subject;]]..e(fields.subject)..[[]
    button_exit[7.7,0.38;1,1;exit;X]
    tooltip[exit;Discard Message and Close]
    textarea[0.5,1.6;8.5,7.1;msg;Message;]]..e(fields.msg)..[[]
    button[0.21,8;8.5,1;send;Send Message]
    label[0.25,8.8;]]..e(error)..[[]
  ]]
end

-- [function] Toggle Contact Formspec
function contact.toggle_main(name, show, error, fields)
  if not minetest.get_player_by_name(name) then
    return
  end

  if show ~= false then
    minetest.show_formspec(name, "contact:main", formspec(error, fields))
  else
    minetest.close_formspec(name, "contact:main")
  end
end

-- [event] Handle Form Input
minetest.register_on_player_receive_fields(function(player, formname, fields)
  if formname ~= "contact:main" then return end -- Check formname

  local name = player:get_player_name()

  if fields.send then
    -- Check for missing fields
    if not fields.subject or fields.subject == "" then
      contact.toggle_main(name, true, "Subject Required", fields)
    elseif not fields.msg or fields.msg == "" then
      contact.toggle_main(name, true, "Message Required", fields)
    else -- else, Send message
      local msgdata = {
        from    = name,
        subject = fields.subject,
        msg     = fields.msg,
        dtime   = contact.date(),
      }

      -- Insert Data
      table.insert(contact.msg, msgdata)
      -- Close form
      contact.toggle_main(name, false)
      -- Print to chat
      minetest.chat_send_player(name, "Message sent!")
    end
  end
end)

-- [register] Main Chatcommand
minetest.register_chatcommand("contact", {
  description = "Contact an admin",
  func = function(name)
    -- Show formspec
    contact.toggle_main(name, true)

    return true, "Opening Contact Form"
  end,
})

contact.log("Loaded Contact Functionality", "info")

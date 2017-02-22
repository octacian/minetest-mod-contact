-- contact/dash.lua

-- [register] Contact Admin Privilege
minetest.register_privilege("contact", "Access admin dashboard of the contact mod")

-- [table] Tabs
local tabs = {
  "dashboard",
  "messages",
  "reports"
}

-- [local function] handle tabs
function handle_tabs(name, fields)
  if fields.tabs then
    contact.show_dash(name, tabs[tonumber(fields.tabs)])
    return true
  end
end

-- [table] Forms
local forms = {
  dashboard = {
    get = function()
      return [[
        size[10,5]
        ]]..contact.gui_bg..[[
        tabheader[0,0;tabs;Dashboard,Messages,Reports;1]
        image_button[0.5,0.5;4,4;contact_flag.png;reports;]
        tooltip[reports;Reported Players]
        image_button[5.5,0.5;4,4;contact_msg.png;msg;]
        tooltip[msg;Messages]
      ]]
    end,
    handle = function(name, fields)
      if handle_tabs(name, fields) then return end

      if fields.msg then
        contact.show_dash(name, "messages", true)
      elseif fields.reports then
        contact.show_dash(name, "reports", true)
      end
    end,
  },
  messages = {
    get = function()
      local list = ""

      for _,i in ipairs(contact.msg) do
        local c
        if _ ~= 1 then c = "," else c = "" end

        list = list..c..i.subject.." - from: "..i.from.." - date: "..i.dtime
      end

      return [[
        size[10,11]
        ]]..contact.gui_bg..[[
        tabheader[0,0;tabs;Dashboard,Messages,Reports;2]
        table[0.25,0.25;9.4,10.5;list;]]..list..[[;1]
      ]]
    end,
    handle = function(name, fields)
      if handle_tabs(name, fields) then return end

      if fields.list then
        local s = fields.list:split(":")
        if s[1] == "DCL" and tonumber(s[3]) ~= 0 then
          contact.show_dash(name, "view_msg", true, tonumber(s[2]))
        end
      end
    end,
  },
  view_msg = {
    cache_name = false,
    get = function(name, id)
      local e   = minetest.formspec_escape
      local msg = contact.msg[id]

      local body = msg.msg:split("\n", true)
      for i, line in ipairs(body) do
        body[i] = e(line)
      end

      return [[
        size[10,11]
        ]]..contact.gui_bg..[[
        field[100,100;1,1;id;;]]..e(id)..[[]
        button[0.1,0.1;1,1;back;Back]
        button[1,0.1;1.2,1;del;Delete]
        label[2.5,0.1;From: ]]..e(msg.from)..[[]
        label[2.5,0.45;Date: ]]..e(msg.dtime)..[[]
        label[0.1,1.3;Subject: ]]..e(msg.subject)..[[]
        tableoptions[background=#343434;highlight=#00000000;border=false]
        table[0,1.8;9.68,7;msg;]]..table.concat(body, ",")..[[;1]
      ]]
    end,
    handle = function(name, fields)
      if fields.back then
        contact.show_dash(name, "messages", true)
      elseif fields.del then
        table.remove(contact.msg, tonumber(fields.id))
        contact.show_dash(name, "messages", true)
      end
    end,
  },
  reports = {
    get = function()
      local list = ""

      for _,i in ipairs(contact.reports) do
        local c
        if _ ~= 1 then c = "," else c = "" end

        list = list..c..i.target.." - from: "..i.from.." - date: "..i.dtime
      end

      return [[
        size[10,11]
        ]]..contact.gui_bg..[[
        tabheader[0,0;tabs;Dashboard,Messages,Reports;3]
        table[0.25,0.25;9.4,10.5;list;]]..list..[[;1]
      ]]
    end,
    handle = function(name, fields)
      if handle_tabs(name, fields) then return end

      if fields.list then
        local s = fields.list:split(":")
        if s[1] == "DCL" and tonumber(s[3]) ~= 0 then
          contact.show_dash(name, "view_report", true, tonumber(s[2]))
        end
      end
    end,
  },
  view_report = {
    cache_name = false,
    get = function(name, id)
      local e   = minetest.formspec_escape
      local rep = contact.reports[id]

      local info = rep.info:split("\n", true)
      for i, line in ipairs(info) do
        info[i] = e(line)
      end

      return [[
        size[10,11]
        ]]..contact.gui_bg..[[
        field[100,100;1,1;id;;]]..e(id)..[[]
        button[0.1,0.1;1,1;back;Back]
        button[1,0.1;1.2,1;del;Delete]
        label[0.1,0.92;Target: ]]..e(rep.target)..[[]
        label[2.5,0.1;From: ]]..e(rep.from)..[[]
        label[2.5,0.45;Date: ]]..e(rep.dtime)..[[]
        label[0.1,1.3;Reason: ]]..e(rep.reason)..[[]
        tableoptions[background=#343434;highlight=#00000000;border=false]
        table[0,1.8;9.68,7;info;]]..table.concat(info, ",")..[[;1]
      ]]
    end,
    handle = function(name, fields)
      if fields.back then
        contact.show_dash(name, "reports", true)
      elseif fields.del then
        table.remove(contact.reports, tonumber(fields.id))
        contact.show_dash(name, "reports", true)
      end
    end,
  },
}

-- [function] Show/Hide Formspecs
function contact.show_dash(pname, fname, show, ...)
  if forms[fname] then
    if not minetest.get_player_by_name(pname) then
      return
    end

    if show ~= false then
      minetest.show_formspec(pname, "contact:"..fname, forms[fname].get(pname, ...))

      -- Update player attribute
      if forms[fname].cache_name ~= false then
        minetest.get_player_by_name(pname):set_attribute("contact_formname", fname)
      end
    else
      minetest.close_formspec(pname, "contact:"..fname)
    end
  end
end

-- [event] on receive fields
minetest.register_on_player_receive_fields(function(player, formname, fields)
  local formname = formname:split(":")

  if formname[1] == "contact" and forms[formname[2]] then
    local handle = forms[formname[2]].handle
    if handle then
      handle(player:get_player_name(), fields)
    end
  end
end)

-- [register] Dashboard Chatcommand
minetest.register_chatcommand("contact_admin", {
  description = "Show admin panel for contact mod",
  privs = {contact=true},
  func = function(name)
    -- Get player attribute
    local fname = minetest.get_player_by_name(name):get_attribute("contact_formname")

    if not forms[fname] then
      fname = "dashboard"
    end

    contact.show_dash(name, fname, true)

    return true, "Opening admin "..fname
  end,
})

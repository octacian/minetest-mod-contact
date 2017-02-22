API
===

The Contact mod provides a rather simple yet comprehensive API for use by other mods. After all, the mod itself is not overly complex, so neither is its API. All functions available outside of the mod are documented below in sections.

__Note:__ all the functions documented below should be prefixed by `contact.`, however, it has been removed from the headers for simplicity.

## Main

#### `log`
__Usage:__ `contact.log(<content (string)>, <type (string)>)`

Prints to the log just like `minetest.log`. This automatically inserts `[contact]` before each log message and defaults the log type to `action`. See the [documentation](http://dev.minetest.net/minetest.log) for available log types.

#### `load`
__Usage:__ `contact.load()`

Loads everything stored in the contact world-files to the global `contact` table storing information in the proper sub-tables. No parameters are required. __Note:__ this is automatically called at load and will rarely (if ever) be used elsewhere.

#### `save`
__Usage:__ `contact.save()`

Gathers specific data from the global `contact` table and saves it in `<worldname>/mod_contact.txt`. __Note:__ this is automatically called at shutdown and whenever specific actions take place.

## Contact

#### `toggle_main`
__Usage:__ `contact.toggle_main(<player name (string)>, <show/hide (boolean)>, <error message (string)>, <form fields (table)>`

This allows an external mod to show the contact form to any specific player. By default, the formspec is shown when a player uses the `/contact` command. Only the `name` string is required, and should be the name of a player. The second parameter allows toggling between showing/updating the formspec or hiding it with `true`/`false` (default: `true`). The third parameter allows one to specify a message to show at the bottom, typically used for errors. The final parameter is used to pre-fill the form fields (see below for structure).

__Example:__
```lua
contact.toggle_main("singleplayer", true, "Warning!", {
  subject = "Test",
  msg = "Hello World!",
})
```

## Report

#### `toggle_report`
__Usage:__ `contact.toggle_report(<name (string)>, <target (string)>, <show/hide (boolean)>, <error (table)>)`

This allows an external mod to show the report form to any specific player (specified by `name`). By default, the formspec is shown when a player uses the `/report <target>` command. Only the `name` and `target` strings are required, and should be the names of a player and a target player. The third parameter allows toggling between showing/updating the formspec or hiding it with `true`/`false` (default: `true`). The fourth parameter is a table allowing an error message to be shown at the bottom of the form. It should contain two values, `msg`, and the form `fields` (see example below). __Note:__ `name` and `target` cannot be the same.

__Example:__
```lua
contact.toggle_report("singleplayer", "otherplayer", true, {
  msg = "Test",
  fields = {
    reason = "Breaking Rules",
    info = "This is the information field",
  }
})
```

## Dash
The dashboard is composed of several different formspecs to allow tabs and views. Only one API function is available to other mods, as documented below. However, it is important to know that if you wish to customize the formspecs, you should modify the `forms` table in `dash.lua`.

#### `show_dash`
__Usage:__ `contact.show_dash(<player name (string)>, <form name (string)>, <show/hide (boolean)>, <...>)`

This allows an external mod to show the dashboard to any specific player (specified by `name`). By default, the formspec is shown when a player uses the `/contact_admin` command which requires the `contact` privilege. The player name and form name parameters are the only ones required. If not specified, show/hide will default to show (`true`). Finally, any other parameters can be passed to the `get` function of each form by adding them after show/hide like normal parameters.

__Example:__
```lua
contact.show_dash("singleplayer", "view_msg", true, 12})
```

In the example, `12` is the message ID being passed to the `view_msg` formspec `get` function.
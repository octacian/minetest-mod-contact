API
===

The Contact mod provides a rather simple yet comprehensive API for use by other mods. After all, the mod itself is not overly complex, so neither is its API. All functions available outside of the mod are documented below.

__Note:__ all the functions documented below should be prefixed by `contact.`, however, it has been removed from the headers for simplicity.

#### `log`
__Usage:__ `contact.log(<content (string)>, <type (string)>)`

Prints to the log just like `minetest.log`. This automatically inserts `[contact]` before each log message and defaults the log type to `action`. See the [documentation](http://dev.minetest.net/minetest.log) for available log types.

#### `load`
__Usage:__ `contact.load()`

Loads everything stored in the contact world-files to the global `contact` table storing information in the proper sub-tables. No parameters are required. __Note:__ this is automatically called at load and will rarely (if ever) be used elsewhere.

#### `save`
__Usage:__ `contact.save()`

Gathers specific data from the global `contact` table and saves it in `<worldname>/mod_contact.txt`. __Note:__ this is automatically called at shutdown and whenever specific actions take place.
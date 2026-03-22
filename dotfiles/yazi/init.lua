

-- ~/.config/yazi/init.lua
th.git = th.git or {}
th.git.unknown_sign = " "
th.git.modified_sign = "M"
th.git.deleted_sign = "D"
th.git.clean_sign = ""
th.git.untracked_sign = "U"
th.git.clean = ui.Style():fg("green"):bold()

require("git"):setup {
	-- Order of status signs showing in the linemode
	order = 1500,
}

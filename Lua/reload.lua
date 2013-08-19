function reload(data)
	if PermRegistry.HasPerm(data.Nick, "lua_reload") then
		sendNotice(data.Nick, "Reloading...")
		Octotribble.ResetLua()
		plugins = {}
	else
		sendNotice(data.Nick, "You do not have the permissions required.")
	end
end
create_plugin("reload", reload, "channel_message")
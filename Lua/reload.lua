function reload(data)
	if PermRegistry.HasPerm(data.Nick, "lua_reload") then
		sendNotice(data.Nick, "Reloading...")
		reset()
		Octotribble.ResetLua()
	else
		sendNotice(data.Nick, "You do not have the permissions required.")
	end
end
create_plugin("reload", reload, "channel_message")

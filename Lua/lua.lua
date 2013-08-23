function lua(data)
	if PermRegistry.HasPerm(data.Nick, "lua_run") then
		f, e = pcall(loadstring(string.sub(data.Message, 6)))
		if not f then
			sendNotice(data.Nick, "Exception raised: "..tostring(e))
		end
	else
		sendNotice("You do not have the permissions required.")
	end
end

create_plugin("lua", lua, "channel_message")

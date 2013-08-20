function cmd_list(data)
	if PermRegistry.HasPerm(data.Nick, "io_list") and data.MessageArray.Length==2 then
		sendNotice(data.Nick, list(data.MessageArray[1]))
	elseif data.MessageArray.Length~=2 then
		sendNotice(data.Nick, "Usage: list <dir>")
	else
		sendNotice(data.Nick, "You do not have the required permissions.")
	end
end

create_plugin("list",cmd_list,"channel_message")
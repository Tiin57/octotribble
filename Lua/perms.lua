function perm_mod(data)
	if PermRegistry.HasPerm(data.Nick, "perm_modify") and data.MessageArray.Length==4 then
		if data.MessageArray[1]=="add" then
			PermRegistry.AddPerm(data.MessageArray[2], data.MessageArray[3])
			sendNotice(data.Nick, "Permission added.")
		elseif data.MessageArray[1]=="remove" then
			PermRegistry.RemovePerm(data.MessageArray[2], data.MessageArray[3])
			sendNotice(data.Nick, "Permission removed.")
		end
	elseif data.MessageArray.Length ~= 4 then
		sendNotice(data.Nick, "Usage: botperm <add | remove> <nick> <perm>")
	else
		sendNotice(data.Nick, "You do not have the permissions required.")
	end
end

create_plugin("botperm", perm_mod, "channel_message")
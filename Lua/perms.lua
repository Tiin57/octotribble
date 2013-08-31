function perm_mod(data)
	if PermRegistry.HasPerm(data.Nick, "perm_modify") and data.MessageArray.Length==4 then
		usr = get_nickserv_user(data.MessageArray[3])
		if usr==nil then
			sendNotice(data.Nick, data.MessageArray[3].." is not identified with NickServ.")
			return
		end
		if data.MessageArray[1]=="add" then
			PermRegistry.AddPerm(data.MessageArray[2], usr)
			sendNotice(data.Nick, "Permission added.")
		elseif data.MessageArray[1]=="remove" then
			PermRegistry.RemovePerm(data.MessageArray[2], usr)
			sendNotice(data.Nick, "Permission removed.")
		end
	elseif data.MessageArray.Length ~= 4 then
		sendNotice(data.Nick, "Usage: botperm <add | remove> <nick> <perm>")
	else
		sendNotice(data.Nick, "You do not have the permissions required.")
	end
end

cplugin("botperm", perm_mod, c_message)
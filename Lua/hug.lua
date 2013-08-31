 function hug(data)
 	if PermRegistry.HasPerm(data.Nick, "action_hug") then
 		sendAction(data.Channel, "hugs "..data.MessageArray[1])
 	end
 end
 cplugin("hug", hug, c_message)
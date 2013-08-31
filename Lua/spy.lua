 spy_channels = {}
 function spy(data)
 	if spy_channels[data.Channel] then
 		for k in pairs(spy_channels[data.Channel]) do
 			sendNotice(tostring(k), "["..data.Channel.."] ["..data.Nick.."]: "..data.Message)
 		end
 	end
 end
 cplugin("spychan", spy, c_message, true)
 function add_spy(data)
 	if PermRegistry.HasPerm(data.Nick, "gen_spy") then
 		if not spy_channels[data.MessageArray[1]] then
 			spy_channels[data.MessageArray[1]]={}
 		end
 		spy_channels[data.MessageArray[1]][data.Nick]=true
 	end
 end
 cplugin('spy', add_spy, c_message)
 function rem_spy(data)
 	if PermRegistry.HasPerm(data.Nick, "gen_spy") then
 		if not spy_channels[data.MessageArray[1]] then
 			return nil
 		end
 		spy_channels[data.MessageArray[1]][data.Nick]=nil
 	end
 end
 cplugin('unspy', rem_spy, c_message)
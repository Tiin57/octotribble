function evt_ai(data)
	if PermRegistry.HasPerm(data.Nick, "ai_talk") then
		print(ai:GetOutput(string.sub(data.Message,5), data.Nick))
	else
		sendNotice(data.Nick, "You aren't allowed to interface with the AI!")
	end
end

--create_plugin("ai", evt_ai, "channel_message")

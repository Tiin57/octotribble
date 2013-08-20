function pong(sender, evt)
	irc:RfcPong(evt.Data.Message)
end
pong_event_handler = irc.OnPing:Add(pong)

AddEventHandler('recordstart', function()
	StartRecording(1)
end)

AddEventHandler('recordstop', function()
	StopRecordingAndSaveClip()
end)

AddEventHandler('recorddiscard', function()
	StopRecordingAndDiscardClip()
end)

AddEventHandler('rockstareditor', function()
	NetworkSessionLeaveSinglePlayer()
	ActivateRockstarEditor()
end)
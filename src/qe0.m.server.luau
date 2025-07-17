local rs = game:GetService('RunService')
local chs = game:GetService("ChangeHistoryService")

if rs:IsRunning() then return end

local toolbar = plugin:CreateToolbar('QuickEdit')

toolbar:SetAttribute('__wlft', os.time())


local qe:PluginToolbarButton = toolbar:FindFirstChild("QuickEdit") or toolbar:CreateButton("qe-select","Select an object with a text surface to edit it","http://www.roblox.com/asset/?id=122628245132562", 'Select Text')

qe.Name = "QuickEdit"
qe:SetAttribute("version", 0)
qe:SetAttribute("load_metadata", `\{"name":\{"full":"QuickEdit","initialism":"QE"},"version":0\,"loaded_at":{os.time()},"is_local":{tostring(plugin.Name:match('(%.rbxmx?)$') ~= nil or false)}}`)
toolbar:SetAttribute("pl__qe", `\{"name":\{"full":"QuickEdit","initialism":"QE"},"loading_completed":{os.time()}}`)
qe.Parent = toolbar
qe.ClickableWhenViewportHidden = true

---

local widget_info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, true, 300, 400, 300, 400 --[[3:4]])  -- standard position, enabled when Studio opens, if the widget goes back to the last position when opened again, standard horizontal size, standard vertical size, minimum horizontal size, minimum vertical size.
local widget = plugin:CreateDockWidgetPluginGui("QE0", widget_info)
widget.Name = 'QuickEdit'
widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
widget.Enabled = false

local app = script.Parent.r.ui.app:Clone()
app.Position = UDim2.fromScale(0,0)
app.Size = UDim2.fromScale(1,1)
app.Parent = widget

app.confirm.c.hitbox.MouseButton1Click:Connect(function()
	widget.Enabled = false
end)


local mouse = plugin:GetMouse()
local on = false
local lt
local la
local rthread : thread?

local conn
local tbrid
conn = mouse.Button1Down:Connect(function()
	if on and lt ~= nil and typeof(lt) == 'Instance' and lt:IsA('BasePart') then
		on = false
		if rthread then task.cancel(rthread) end
		mouse.Icon = 'rbxasset://SystemCursors/Arrow'
		plugin:Deactivate()
		local l = (lt :: BasePart):FindFirstChildWhichIsA('TextLabel', true)
		lt = nil
		if la then la:Destroy() end
		widget.Enabled = true
		app.edit.input.m.Text = l.Text
		repeat task.wait() until not widget.Enabled

		if l.Text ~= app.edit.input.m.Text then
			tbrid = chs:TryBeginRecording('qe0-edit', "QuickEdit TextLabel")

			l.Text = app.edit.input.m.Text

			if typeof(tbrid) == 'string' then
				chs:FinishRecording(tbrid, Enum.FinishRecordingOperation.Commit)
			end
		end
	end
end)



qe.Click:Connect(function()
	plugin:Activate(false)
	on = not on
	
	if on then
		mouse.Icon = 'rbxasset://SystemCursors/Cross'
		
		rthread = task.spawn(function()
			while task.wait(.05) do
				local t = mouse.Target

				if t and t ~= lt and t:IsA('BasePart') and t:FindFirstChildWhichIsA('TextLabel', true) then
					lt = t
					if la then la:Destroy() end

					la = Instance.new('SelectionBox', workspace.Camera)
					la.Adornee = t
				elseif not t or not t:FindFirstChildWhichIsA('TextLabel', true) then
					if la then la:Destroy() end
				end
			end
		end)
	else
		mouse.Icon = 'rbxasset://SystemCursors/Arrow'
	end
end)

plugin.Unloading:Connect(function()
	if la then la:Destroy() end
	conn:Disconnect()
	plugin:Deactivate()
	if rthread then task.cancel(rthread) end
end)
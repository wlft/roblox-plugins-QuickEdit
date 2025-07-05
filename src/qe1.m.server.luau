local rs = game:GetService('RunService')
local cg = game:GetService('CoreGui')
local http = game:GetService('HttpService')

if rs:IsRunning() then return end

local toolbar = plugin:CreateToolbar('QuickEdit')

toolbar:SetAttribute('__wlft', os.time())


local qe:PluginToolbarButton = toolbar:FindFirstChild("QuickEdit") or toolbar:CreateButton("qe-select","QuickEdit a TextLabel","http://www.roblox.com/asset/?id=122628245132562", 'QuickEdit')

qe.Name = "QuickEdit"
qe:SetAttribute("version", 4)
qe:SetAttribute("load_metadata", `\{"name":\{"full":"QuickEdit","initialism":"QE"},"version":4\,"loaded_at":{os.time()},"is_local":{tostring(plugin.Name:match('(%.rbxmx?)$') ~= nil or false)}}`)
toolbar:SetAttribute("pl__qe", `\{"name":\{"full":"QuickEdit","initialism":"QE"},"loading_completed":{os.time()}}`)
qe.Parent = toolbar
qe.ClickableWhenViewportHidden = true

---

local widget_info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, true, 300, 400, 300, 400 --[[1:1]])  -- standard position, enabled when Studio opens, if the widget goes back to the last position when opened again, standard horizontal size, standard vertical size, minimum horizontal size, minimum vertical size.
local widget = plugin:CreateDockWidgetPluginGui("QE1", widget_info)
widget.Name = 'QuickEdit'
widget.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
widget.Enabled = false

--local txtl = Instance.new('TextBox', widget)
--txtl.Parent = widget
--txtl.Size = UDim2.fromScale(1,1)

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
conn = mouse.Button1Down:Connect(function()
	print('click')
	print(on, lt, la, typeof(lt))
	if on and lt ~= nil and typeof(lt) == 'Instance' and lt:IsA('BasePart') then
		on = false
		task.cancel(rthread)
		mouse.Icon = 'rbxasset://SystemCursors/Arrow'
		plugin:Deactivate()
		print('selected : ', lt)
		local l = (lt :: BasePart):FindFirstChildWhichIsA('TextLabel', true)
		lt = nil
		if la then la:Destroy() end
		widget.Enabled = true
		app.edit.input.m.Text = l.Text
		--task.wait(3)
		repeat task.wait() until not widget.Enabled
		l.Text = app.edit.input.m.Text
	end
end)



qe.Click:Connect(function()
	plugin:Activate(false)
	on = not on
	
	if on then
		print('mode activated!!!!')
		mouse.Icon = 'rbxasset://SystemCursors/Cross'
		
		--task.wait(1)
		
		--print(mouse.Target)
		
		--mouse:GetPropertyChangedSignal('Target'):Connect(function()
		--	print(mouse.Target)
		--end)
		
		
		--mouse.Button1Down:Connect(function()
		--	print('click')
		--	if lt then
		--		print('selected')
		--		on = false
		--	end
		--end)
		
		--while task.wait(.05) do
		--	--mouse.Icon = 'rbxasset://SystemCursors/Cross'
		--	if not on then break end
			
		--	local t = mouse.Target
			
		--	if t and t ~= lt and t:IsA('BasePart') and t:FindFirstChildWhichIsA('TextLabel', true) then
		--		lt = t
		--		if la then la:Destroy() end
				
		--		la = Instance.new('SelectionBox', workspace.Camera)
		--		la.Adornee = t
				
				
		--		print('real one right there') 
		--	elseif not t or not t:FindFirstChildWhichIsA('TextLabel', true) then
		--		if la then la:Destroy() end
		--	end
		--end
		
		rthread = task.spawn(function()
			while task.wait(.05) do
				--mouse.Icon = 'rbxasset://SystemCursors/Cross'
				--if not on then break end

				local t = mouse.Target

				if t and t ~= lt and t:IsA('BasePart') and t:FindFirstChildWhichIsA('TextLabel', true) then
					lt = t
					if la then la:Destroy() end

					la = Instance.new('SelectionBox', workspace.Camera)
					la.Adornee = t


					print('real one right there') 
				elseif not t or not t:FindFirstChildWhichIsA('TextLabel', true) then
					if la then la:Destroy() end
				end
			end
		end)
		
		
	else
		print('mode off !!!')
	end
	
end)

plugin.Unloading:Connect(function()
	if la then la:Destroy() end
	conn:Disconnect()
	plugin:Deactivate()
	if rthread then task.cancel(rthread) end
	print('deactivated')
end)
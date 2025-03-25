

if game:GetService("RunService"):IsStudio() == true then
	function gethui() return game:GetService("Players").LocalPlayer.PlayerGui end
	function cloneref(a) return a end
end

local LocalPlayer,Camera,Character,CoreGui = game:GetService("Players").LocalPlayer,game:GetService("Workspace").CurrentCamera,nil,game:GetService("Players").LocalPlayer.PlayerGui--gethui() or game:GetService("CoreGui") or cloneref(game:GetService("Players").LocalPlayer.PlayerGui)

if LocalPlayer.Character ~= nil then 
	Character = LocalPlayer.Character
else
	print("Custom Character Detected.")
end

--Tables
local SettingsTable = {
	Boxes = {Enabled = true,Outline = true,Filled = false,Color=Color3.fromRGB(255, 255, 255),FilledColor=Color3.fromRGB(0, 0, 0)};
	Distances = {Enabled = true,Color = Color3.fromRGB(255,255,255),Conversion="studs"};
	Names= {Enabled=true,Color=Color3.fromRGB(255,255,255)};
	Tools = {Enabled=true,Color=Color3.fromRGB(255,255,255)};
	HealthBars = {Enabled=true};
	HealthText = {Enabled=true,Color=Color3.fromRGB(255, 255, 255),UseHealthColor=true};
	ItemDistances = {Enabled = true,Color = Color3.fromRGB(255,255,255),Conversion="studs"};
	ItemNames= {Enabled=true,Color=Color3.fromRGB(255,255,255)};
	GeneralSettings = {TextSize=11,IgnoreHumanoid=true,RenderDistance=1000,ItemRenderDistance=1000};
	IgnoreList={};ObjectIgnoreList={};
	ItemCache={};PlayerCache={};
}
local Conversions = {
	["km"] = (3.5714285714 * 1000),
	["m"] = (3.5714285714),
	["cm"] = (3.5714285714 / 100),
	["mm"] = (3.5714285714 / 1000),
	["inch"] = (3.5714285714 / 39.3700787),
	["studs"] = (1)
};
local PlayerCache = SettingsTable.PlayerCache;local ItemCache = SettingsTable.ItemCache;
local Functions = {};
local RandomVars = {};
local PlayerEspData={};local ItemEspData = {}

if game.PlaceId == 13253735473 then
	for i,v in pairs(game:GetService("ReplicatedStorage").HandModels:GetChildren()) do
		if v:FindFirstChild("Handle") then
			RandomVars[v.Handle.MeshId] = v.Name
		end
	end
	SettingsTable["SleepingText"] = {Enabled = false,Color=Color3.fromRGB(255,255,255)}
end

function Functions:Create(Inst,Props)
	assert(Inst,"[Functions:Create] Instance Provided Was Nil.");assert(Props,"[Functions:Create] Properties Provided Was Nil.")
	if Instance.new(Inst) == nil then print("[Functions:Create] Instance Provided Was Invalid.");return; end
	local NewInst = Instance.new(Inst)
	for i,v in pairs(Props) do
		NewInst[i] = v
	end
	return NewInst
end
function Functions:GetBoundingBox(Model)
	local cf, size = Model:GetBoundingBox()
	local halfSizeX, halfSizeY, halfSizeZ = size.X / 2, size.Y / 2, size.Z / 2

	local left, right = math.huge, -math.huge
	local top, bottom = math.huge, -math.huge

	for _, xSign in ipairs({1, -1}) do
		for _, ySign in ipairs({1, -1}) do
			for _, zSign in ipairs({1, -1}) do
				local corner = cf * CFrame.new(halfSizeX * xSign, halfSizeY * ySign, halfSizeZ * zSign)
				local screenPos, onScreen = Camera:WorldToScreenPoint(corner.Position)
				if onScreen then
					left = math.min(left, screenPos.X)
					right = math.max(right, screenPos.X)
					top = math.min(top, screenPos.Y)
					bottom = math.max(bottom, screenPos.Y)
				end
			end
		end
	end
	return math.floor(left), math.floor(right), math.floor(top), math.floor(bottom), size
end
if game.PlaceId == 13253735473 then
	for i,v in pairs(game:GetService("ReplicatedStorage").HandModels:GetChildren()) do
		if v:FindFirstChild("Handle") then
			RandomVars[v.Handle.MeshId] = v.Name
		end
	end
end
function Functions:GetTool(Player)
	if game.PlaceId == 13253735473 then
		if Player:FindFirstChild("HandModel") and Player.HandModel:FindFirstChild("Meshes/Bow") then
			return "Bow"
		elseif Player:FindFirstChild("HandModel") and Player.HandModel:FindFirstChild("FrontNails") then
			return "CrossBow"
		elseif Player:FindFirstChild("HandModel") and Player.HandModel:FindFirstChild("thing") and Player.HandModel.thing.MeshId == "rbxassetid://11351055921" then
			return "Blunderbuss"
		elseif Player:FindFirstChild("HandModel") and Player.HandModel:FindFirstChild("Handle") and RandomVars[Player.HandModel.Handle.MeshId] then
			if RandomVars[Player.HandModel.Handle.MeshId] == "SCAR" and Player.HandModel:FindFirstChild("Muzzle") then
				Player.HandModel.Muzzle:Destroy()
			end
			return RandomVars[Player.HandModel.Handle.MeshId]
		else
			return "None"
		end
	end

	if Player:FindFirstChildOfClass("Tool") then
		return Player:FindFirstChildOfClass("Tool").Name
	end
	return "None"
end

do
	local ScreenGui = Functions:Create("ScreenGui", {Parent = CoreGui, Name = "ScreenEsp"})

	function Functions:Unload()
		ScreenGui:Destroy()
	end

	function Functions:CreateEsp(Model)
		if table.find(PlayerCache,Model) then return end
		table.insert(PlayerCache,Model)
		if PlayerEspData[Model] then return end

		local Drawings = {}
		Drawings.FilledBox = Functions:Create("Frame", {Parent = ScreenGui,BackgroundColor3 = Color3.fromRGB(0, 0, 0),BackgroundTransparency = 0.75,BorderSizePixel = 0})
		Drawings.OutlineBox = Functions:Create("Frame", {Parent = Drawings.FilledBox,BackgroundColor3 = Color3.fromRGB(0, 0, 0),BackgroundTransparency = 0.75,BorderSizePixel = 0})
		Drawings.InnerBox = Functions:Create("UIStroke", {Parent = Drawings.FilledBox, Transparency = 0, Color = Color3.fromRGB(0, 0, 0), LineJoinMode = Enum.LineJoinMode.Miter,Thickness=2})
		Drawings.OuterBox = Functions:Create("UIStroke", {Parent = Drawings.OutlineBox, Transparency = 0, Color = Color3.fromRGB(255, 255, 255), LineJoinMode = Enum.LineJoinMode.Miter,Thickness=1})
		Drawings.Name = Functions:Create("TextLabel", {Parent = ScreenGui, Size = UDim2.new(0, 50, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = SettingsTable.GeneralSettings.TextSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0)})
		Drawings.Distance = Functions:Create("TextLabel", {Parent = ScreenGui, Size = UDim2.new(0, 50, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = SettingsTable.GeneralSettings.TextSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0)})
		Drawings.Tools = Functions:Create("TextLabel", {Parent = ScreenGui, Size = UDim2.new(0, 50, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = SettingsTable.GeneralSettings.TextSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0)})
		Drawings.OuterHealthBar = Functions:Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0,BorderColor3=Color3.fromRGB(0,0,0)})
		Drawings.InnerHealthBar = Functions:Create("Frame", {Parent = Drawings.OuterHealthBar, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BackgroundTransparency = 0, BorderSizePixel = 0})
		Drawings.OuterHealthGradient = Functions:Create("UIGradient", {Parent = Drawings.InnerHealthBar, Rotation = 90, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0, 1, 0)), ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))}), Enabled = true})
		Drawings.GradientHolder = Functions:Create("Frame", {Parent = Drawings.InnerHealthBar, Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 0, BorderSizePixel = 0})
		Drawings.GradientHolderGradient = Functions:Create("UIGradient", {Parent = Drawings.GradientHolder, Rotation = 90, Enabled = true, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.564, 0.8), NumberSequenceKeypoint.new(1, 0)}), Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)), ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))})})
		Drawings.HealthText = Functions:Create("TextLabel", {Parent = ScreenGui, Size = UDim2.new(0, 50, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = SettingsTable.GeneralSettings.TextSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0)})
		Drawings.SleepingText = nil
		if game.PlaceId == 13253735473 then
			Drawings.SleepingText = Functions:Create("TextLabel", {Parent = ScreenGui, Size = UDim2.new(0, 50, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = SettingsTable.GeneralSettings.TextSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0)})
		end

		function Drawings.Hide()
			Drawings.FilledBox.Visible = false
			Drawings.Name.Visible = false
			Drawings.Distance.Visible = false
			Drawings.Tools.Visible = false
			Drawings.OuterHealthBar.Visible = false
			Drawings.HealthText.Visible = false
			if Drawings.SleepingText ~= nil then
				Drawings.SleepingText.Visible = false
			end
		end
		
		PlayerEspData[Model] = Drawings
	end
	
	Connection = game:GetService("RunService").RenderStepped:Connect(function()
		for i, v in pairs(PlayerEspData) do
			local Model = i
			if ScreenGui ~= nil and Model ~= nil and Model:IsDescendantOf(game:GetService("Workspace")) then
				if Model:FindFirstChild("HumanoidRootPart") and (SettingsTable.GeneralSettings.IgnoreHumanoid or (Model:FindFirstChild("Humanoid") and Model.Humanoid.Health > 0)) and not table.find(SettingsTable.IgnoreList,Model) then

					local Position, OnScreen = Camera:WorldToScreenPoint(Model:GetPivot().p)
					local left, right, top, bottom,size = Functions:GetBoundingBox(Model)
					local distance = LocalPlayer:DistanceFromCharacter(Model:GetPivot().p)

					if SettingsTable.GeneralSettings.IgnoreHumanoid then
						distance = (Camera.CFrame.p - Model:GetPivot().p).Magnitude
					end

					if distance <= SettingsTable.GeneralSettings.RenderDistance and OnScreen and v ~= nil then
						do
							v.FilledBox.Position = UDim2.new(0, left, 0, top)
							if SettingsTable.Boxes.Enabled then
								v.FilledBox.Size = UDim2.new(0, right-left, 0, bottom-top)
								v.OutlineBox.Size = UDim2.new(1, 0, 1, 0)
								v.OutlineBox.Position =  UDim2.new(0, 0, 0, 0)
								v.OutlineBox.BackgroundTransparency = 1
								v.FilledBox.Visible = true
								v.FilledBox.BackgroundColor3 = SettingsTable.Boxes.FilledColor
								v.OuterBox.Color = SettingsTable.Boxes.Color
								if SettingsTable.Boxes.Filled == true then
									v.FilledBox.BackgroundTransparency = .75
								else
									v.FilledBox.BackgroundTransparency = 1
								end
							else
								v.FilledBox.Visible = false
							end
						end
						do 
							if SettingsTable.Names.Enabled then
								if game:GetService("Players"):FindFirstChild(Model.Name) then
									v.Name.Text = game:GetService("Players")[Model.Name].Name
								elseif game.PlaceId == 13253735473 then 
									if #Model.Armor:GetChildren() == 4 and (Model.Armor:FindFirstChild("CamoPants") and Model.Armor:FindFirstChild("CamoShirt") and Model.Armor:FindFirstChild("KevlarVest") and Model.Armor:FindFirstChild("CombatHelmet")) or Model:FindFirstChild("Hat") then
										v.Name.Text = "NPC"
										Model:SetAttribute("EntityType","NPC")
									else
										v.Name.Text = "Player"
										Model:SetAttribute("EntityType","Player")
									end
								else
									v.Name.Text = "Player"
								end
								v.Name.Visible = true
								v.Name.Position = UDim2.new(0, v.FilledBox.Position.X.Offset+v.FilledBox.Size.X.Offset/2, 0, v.FilledBox.Position.Y.Offset - v.Name.TextBounds.Y / 1.5)
								v.Name.TextColor3 = SettingsTable.Names.Color
							else
								v.Name.Visible = false
							end
							if SettingsTable.Distances.Enabled then
								v.Distance.Position = UDim2.new(0, v.FilledBox.Position.X.Offset+v.FilledBox.Size.X.Offset/2, 0, v.FilledBox.Position.Y.Offset + v.FilledBox.Size.Y.Offset + v.Distance.TextBounds.Y / 1.5)
								v.Distance.Text = math.floor(distance/Conversions[SettingsTable.Distances.Conversion]).." ("..SettingsTable.Distances.Conversion..")"
								v.Distance.Visible = true
								v.Distance.TextColor3 = SettingsTable.Distances.Color
							else
								v.Distance.Visible = false
							end
							if SettingsTable.Tools.Enabled then
								v.Tools.Position = UDim2.new(0, v.FilledBox.Position.X.Offset+v.FilledBox.Size.X.Offset+(v.Tools.TextBounds.X/2)+3, 0, v.FilledBox.Position.Y.Offset+1)
								v.Tools.Text = Functions:GetTool(Model)
								v.Tools.Visible = true
								v.Tools.TextColor3 = SettingsTable.Tools.Color
							else
								v.Tools.Visible = false
							end
						end
						do
							if SettingsTable.HealthBars.Enabled then
								v.OuterHealthBar.Position = UDim2.new(0, v.FilledBox.Position.X.Offset-9, 0, v.FilledBox.Position.Y.Offset-1)
								v.OuterHealthBar.Size = UDim2.new(0, 3, 0, v.FilledBox.Size.Y.Offset+1)
								if SettingsTable.GeneralSettings.IgnoreHumanoid == false then
									v.InnerHealthBar.Position = UDim2.new(0,0,1,0)
									v.InnerHealthBar.Size = UDim2.new(1,0,1,0)
								else
									v.InnerHealthBar.Position = UDim2.new(0,0,1,0)
									v.InnerHealthBar.Size = UDim2.new(1,0,1,0)
								end
								v.GradientHolder.Size = UDim2.new(1,0,1,0)
								v.GradientHolder.Position = UDim2.new(0,0,0,0)
								v.OuterHealthBar.Visible = true;
							else
								v.OuterHealthBar.Visible = false
							end
							if SettingsTable.HealthText.Enabled then
								if SettingsTable.HealthBars.Enabled then
									v.HealthText.Position = UDim2.new(0, (v.OuterHealthBar.Position.X.Offset-v.OuterHealthBar.Size.X.Offset)-9, 0, v.FilledBox.Position.Y.Offset+1)
								else
									v.HealthText.Position = UDim2.new(0, v.FilledBox.Position.X.Offset - (v.HealthText.TextBounds.X / 2) - 3, 0,  v.FilledBox.Position.Y.Offset)
								end
								if SettingsTable.GeneralSettings.IgnoreHumanoid == false then
									v.HealthText.Text = 100
								else
									v.HealthText.Text = 100
								end
								if SettingsTable.HealthText.UseHealthColor == true then
									v.HealthText.TextColor3 = SettingsTable.HealthText.Color
								else
									v.HealthText.TextColor3 = SettingsTable.HealthText.Color
								end
								v.HealthText.Visible= true
							else
								v.HealthText.Visible = false
							end
							do
								if v.SleepingText ~= nil and SettingsTable["SleepingText"] then
									if SettingsTable["SleepingText"].Enabled then
										v.SleepingText.Visible = true
										v.SleepingText.TextColor3 = SettingsTable["SleepingText"].Color
										if SettingsTable.Distances.Enabled then
											v.SleepingText.Position = v.Distance.Position + UDim2.new(0,0,0,13)
										else
											v.SleepingText.Position = UDim2.new(0, v.FilledBox.Position.X.Offset+v.FilledBox.Size.X.Offset/2, 0, v.FilledBox.Position.Y.Offset + v.FilledBox.Size.Y.Offset + v.SleepingText.TextBounds.Y / 1.5)
										end
										local animationTracks = Model.AnimationController.Animator:GetPlayingAnimationTracks()
										if #animationTracks > 0 and animationTracks[1].Animation.AnimationId == "rbxassetid://13280887764" then
											v.SleepingText.Text = "Sleeping"
										else
											v.SleepingText.Text = "Awake"
										end
									else
										v.SleepingText.Visible = false
									end
								end
							end
						end
					else
						v.Hide()
					end
				else
					v.Hide()
				end
			else
				v.FilledBox:Destroy()
				v.Name:Destroy()
				v.Distance:Destroy()
				v.Tools:Destroy()
				v.OuterHealthBar:Destroy()
				v.HealthText:Destroy()
				if v.SleepingText ~= nil then
					v.SleepingText:Destroy()
				end
				table.remove(PlayerCache,table.find(PlayerCache,Model))
			end
		end
	end)

	local ItemEspList = {}

	function Functions:CreateItemEsp(Model,Data)
		if table.find(ItemCache,Model) then return end
		assert(Data,"Erorr, CreateItemEsp Data not provided.")
		table.insert(ItemCache,Model)
		if ItemEspData[Model] then return end

		local Drawings = {}
		Drawings.Name = Functions:Create("TextLabel", {Parent = ScreenGui, Size = UDim2.new(0, 50, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = SettingsTable.GeneralSettings.TextSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0)})
		Drawings.Distance = Functions:Create("TextLabel", {Parent = ScreenGui, Size = UDim2.new(0, 50, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.Code, TextSize = SettingsTable.GeneralSettings.TextSize, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.fromRGB(0, 0, 0)})
		Drawings.Data = Data
		function Drawings.Hide(args)
			Drawings.Name.Visible = false
			Drawings.Distance.Visible = false
		end
		ItemEspList[Model] = {NameText=Drawings.Name,DistanceText=Drawings.Distance,Data=Drawings.Data}
		ItemEspData[Model] = Drawings

		function Drawings.RemoveItemEsp(Model)
			if not ItemEspList[Model] then return end
			ItemEspList[Model].NameText:Destroy()
			ItemEspList[Model].DistanceText:Destroy()
			ItemEspList[Model] = nil
			ItemEspData[Model] = nil
			table.remove(ItemCache,table.find(ItemCache,Model))
		end
	end

	ConnectionItem = game:GetService("RunService").RenderStepped:Connect(function()
		for i,v in pairs(ItemEspData) do
			local Model = i
			if ScreenGui ~= nil and Model ~= nil and Model:IsDescendantOf(game:GetService("Workspace")) and not table.find(SettingsTable.ObjectIgnoreList,Model) then
				local Position, OnScreen = Camera:WorldToScreenPoint(Model:GetPivot().p)
				local distance = LocalPlayer:DistanceFromCharacter(Model:GetPivot().p)
	
				if SettingsTable.GeneralSettings.IgnoreHumanoid then
					distance = (Camera.CFrame.p - Model:GetPivot().p).Magnitude
				end
	
				if distance <= SettingsTable.GeneralSettings.ItemRenderDistance and OnScreen then
					do
						if SettingsTable.ItemNames.Enabled then
							v.Name.Text = v.Data["Name"]
							v.Name.Visible = true
							v.Name.Position = UDim2.new(0, Position.X, 0, Position.Y)
							v.Name.TextColor3 = SettingsTable.ItemNames.Color
						else
							Name.Visible = false
						end
						if SettingsTable.ItemDistances.Enabled then
							if SettingsTable.ItemNames.Enabled then
								v.Distance.Position = UDim2.new(0, Position.X, 0, Position.Y + 11)
							else
								v.Distance.Position = UDim2.new(0, Position.X, 0, Position.Y)
							end
							v.Distance.Text = math.floor(distance/Conversions[SettingsTable.Distances.Conversion]).." ("..SettingsTable.Distances.Conversion..")"
							v.Distance.Visible = true
							v.Distance.TextColor3 = SettingsTable.ItemDistances.Color
						else
							v.Distance.Visible = false
						end
					end
				else
					v.Hide()
				end
			else
				v.Name:Destroy()
				v.Distance:Destroy()
				table.remove(ItemCache,table.find(ItemCache,Model))
			end
		end
	end)
end

return SettingsTable,Functions

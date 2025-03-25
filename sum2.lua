print("aim:version 1.3")
local workspace = cloneref(game:GetService("Workspace"))
local Camera = workspace.CurrentCamera
local Players = cloneref(game:GetService("Players"))
local LocalPlayer = Players.LocalPlayer
local FovPosition = nil
local SnaplinePosition = nil

local SettingsTable = {
    Fov = {Enabled=true,Color=Color3.fromRGB(255,255,255),OutlineColor=Color3.fromRGB(0,0,0),FilledColor=Color3.fromRGB(200,200,200),FovSize=90,FovFilled=false,FovOutline=true,FovPositionType="Mouse"};
    Snapline={Enabled=true,Outline=true,Color=Color3.fromRGB(255,0,0),OutlineColor=Color3.fromRGB(0,0,0)},
    GeneralSettings = {TargetPart="Head",AimMode="Mouse",IgnoreHumanoid=true,Sensitivity=10},
    Players={},
    Drawings={};
    Vars={Aiming=false};
}

local Functions = {};
local RandomVars = {};


--Functions
function Functions:Draw(Type, Propities)
    if not Type or not Propities then return end
    local drawing = Drawing.new(Type)
    for i, v in pairs(Propities) do
        drawing[i] = v
    end
    table.insert(SettingsTable.Drawings, drawing)
    return drawing
end

function Functions:FovPosition(vector2)
    if SettingsTable.Drawings["Fov"] and SettingsTable.Drawings["FovFilled"] and SettingsTable.Drawings["FovOutline"] then
        if SettingsTable.Fov.FovPositionType == "Screen" then
            FovPosition = Camera.ViewportSize / 2
        elseif SettingsTable.Fov.FovPositionType == "Mouse" then
            FovPosition = game:GetService("UserInputService"):GetMouseLocation() + Vector2.new(4.25,6)
        elseif vector2 ~= nil then
            FovPosition = vector2
        end
    end
end

function Functions:CreateFov()
    local Drawings = SettingsTable.Drawings
    Drawings["Fov"] = Functions:Draw("Circle", {Radius=SettingsTable.Fov.FovSize,NumSides=50,Thickness=1, Color = SettingsTable.Fov.Color, ZIndex = 2,Filled=false, Visible = false});
    Drawings["FovFilled"] = Functions:Draw("Circle", {Filled=true,Radius=SettingsTable.Fov.FovSize,NumSides=50,Thickness=1, Color = SettingsTable.Fov.Color, ZIndex = 1,Transparency=.8, Visible = false});
    Drawings["FovOutline"] = Functions:Draw("Circle", {Radius=SettingsTable.Fov.FovSize-1,NumSides=50,Thickness=3, Color = SettingsTable.Fov.OutlineColor,Filled=false, ZIndex = -1, Visible = false});
    Drawings["Snapline"] = Functions:Draw("Line", {Thickness=1, Color = SettingsTable.Snapline.Color, ZIndex = 2, Visible = false});
    Drawings["SnaplineOutline"] = Functions:Draw("Line", {Thickness=3, Color = SettingsTable.Snapline.OutlineColor, ZIndex = -1, Visible = false});


    local FovUpdater = function()
        local Connection = game:GetService("RunService").RenderStepped:Connect(function()
            Functions:FovPosition()
            Drawings["Fov"].Position=FovPosition;Drawings["FovOutline"].Position=FovPosition;Drawings["FovFilled"].Position=FovPosition
            if SettingsTable.Snapline.Enabled == true then
                Drawings["Snapline"].Color = SettingsTable.Snapline.Color
                Drawings["SnaplineOutline"].Color = SettingsTable.Snapline.OutlineColor
                if SnaplinePosition ~= nil and SettingsTable.Vars.Aiming == true then
                    if SettingsTable.GeneralSettings.AimMode == "Mouse" then
                        Drawings["Snapline"].From = game:GetService("UserInputService"):GetMouseLocation()
                    else
                        Drawings["Snapline"].From = Camera.ViewportSize / 2
                    end 
                    Drawings["Snapline"].To = SnaplinePosition
                    if SettingsTable.Snapline.Outline == true then
                        Drawings["SnaplineOutline"].From=Drawings["Snapline"].From;Drawings["SnaplineOutline"].To=Drawings["Snapline"].To;
                    end
                    Drawings["Snapline"].Visible = true;Drawings["SnaplineOutline"].Visible = true
                elseif SettingsTable.Vars.Aiming == false or SnaplinePosition == nil then
                    Drawings["Snapline"].Visible = false;Drawings["SnaplineOutline"].Visible = false
                    SnaplinePosition = nil
                end
            else
                Drawings["Snapline"].Visible = false;Drawings["SnaplineOutline"].Visible = false
            end
            if SettingsTable.Fov.Enabled == true then
                Drawings["Fov"].Visible = true
                Drawings["Fov"].Color = SettingsTable.Fov.Color
                Drawings["Fov"].Radius = SettingsTable.Fov.FovSize
                if SettingsTable.Fov.FovOutline == true then
                    Drawings["FovOutline"].Visible = true
                    Drawings["FovOutline"].Color = SettingsTable.Fov.OutlineColor
                    Drawings["FovOutline"].Radius = SettingsTable.Fov.FovSize - 1
                else
                    Drawings["FovOutline"].Visible = false
                end
                if SettingsTable.Fov.FovFilled == true then
                    Drawings["FovFilled"].Visible = true
                    Drawings["FovFilled"].Color = SettingsTable.Fov.FilledColor
                    Drawings["FovFilled"].Radius = SettingsTable.Fov.FovSize - 1
                else
                    Drawings["FovFilled"].Visible = false
                end
            else
                Drawings["FovOutline"].Visible = false;Drawings["FovFilled"].Visible = false;Drawings["Fov"].Visible = false
            end
        end)
    end
    coroutine.wrap(FovUpdater)();
end
function Functions:GetClosetInFov()
    if #SettingsTable.Players > 0 then
        local ClosestDistance = math.huge
        local Closest = nil
        local FovSize = SettingsTable.Fov.FovSize
        local TargetPartName = SettingsTable.GeneralSettings.TargetPart
        local IgnoreHumanoid = SettingsTable.GeneralSettings.IgnoreHumanoid
        local FovPosition = SettingsTable.Drawings["Fov"].Position

        for _, v in pairs(SettingsTable.Players) do
            if v and (IgnoreHumanoid or v ~= LocalPlayer.Character) then
                local Part = v:FindFirstChild(TargetPartName)
                if Part then
                    local PlayerPosition = Part.Position
                    local Distance = IgnoreHumanoid and (Camera.CFrame.p - PlayerPosition).Magnitude or (LocalPlayer.Character.HumanoidRootPart.Position - PlayerPosition).Magnitude
                    local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(PlayerPosition)
                    if OnScreen then
                        local ScreenDistance = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - FovPosition).Magnitude
                        if ScreenDistance <= FovSize and Distance < ClosestDistance then
                            Closest = v
                            ClosestDistance = Distance
                        end
                    end
                end
            end
        end

        if Closest then
            local SnapPos = Camera:WorldToViewportPoint(Closest:GetPivot().p)
            SnaplinePosition = Vector2.new(SnapPos.X, SnapPos.Y)
        else
            SnaplinePosition = nil
        end

        return Closest
    end
end

function Functions:AimAt(vector2)
    if vector2 then
        local MouseLocation = game:GetService("UserInputService"):GetMouseLocation()
        local Sensitivity = SettingsTable.GeneralSettings.Sensitivity
        mousemoverel((vector2.X - MouseLocation.X) / Sensitivity, (vector2.Y - MouseLocation.Y) / Sensitivity)
    end
end

return SettingsTable,Functions

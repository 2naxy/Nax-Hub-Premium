task.spawn(function()

    local Players = game:GetService("Players")

    local RunService = game:GetService("RunService")

    local UserInputService = game:GetService("UserInputService")

    local TweenService = game:GetService("TweenService")

    local HttpService = game:GetService("HttpService")

    local Stats = game:GetService("Stats")

    local Lighting = game:GetService("Lighting")



    local LocalPlayer = Players.LocalPlayer

    while not LocalPlayer do task.wait() LocalPlayer = Players.LocalPlayer end



    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

    pcall(function() if PlayerGui:FindFirstChild("NaxEliteFinal") then PlayerGui.NaxEliteFinal:Destroy() end end)



    local ScreenGui = Instance.new("ScreenGui")

    ScreenGui.Name = "NaxEliteFinal"; ScreenGui.ResetOnSpawn = false; ScreenGui.IgnoreGuiInset = true; ScreenGui.Parent = PlayerGui



    local ESPFolder = Instance.new("Folder", ScreenGui); ESPFolder.Name = "ESPCache"

    local HighFolder = Instance.new("Folder", workspace.CurrentCamera); HighFolder.Name = "NaxHighFolder"



    -- Config System

    local defaultCfg = { Hue = 234, HighHue = 210, MaxDistance = 5000, TextSize = 14, MenuKey = "LeftControl", ESPEnabled = false, ShowDisplay = true, ShowUser = true, ProximityAlert = false, ShowStats = false, Fullbright = false, SurvivalESP = false }

    local config = table.clone(defaultCfg)



    local function SaveConfig()

        pcall(function() writefile("NaxHub_Config.json", HttpService:JSONEncode(config)) end)

    end



    pcall(function()

        if isfile("NaxHub_Config.json") then

            local decoded = HttpService:JSONDecode(readfile("NaxHub_Config.json"))

            for i, v in pairs(decoded) do config[i] = v end

        end

    end)



    local accentColor = Color3.fromHSV(config.Hue / 360, 0.7, 1)

    local highlightColor = Color3.fromHSV(config.HighHue / 360, 0.7, 1)



    -- Tracker for Dynamic Color Refreshing

    local themedElements = {Strokes = {}, Toggles = {}, Watermarks = {}, Branding = {}}

    local function UpdateTheme()

        accentColor = Color3.fromHSV(config.Hue / 360, 0.7, 1)

        for _, s in pairs(themedElements.Strokes) do s.Color = accentColor end

        for _, t in pairs(themedElements.Toggles) do if t.State then t.Frame.BackgroundColor3 = accentColor end end

        for _, w in pairs(themedElements.Watermarks) do w.TextColor3 = accentColor end

        for _, b in pairs(themedElements.Branding) do b.TextColor3 = accentColor end

    end



    -- Stats Display

    local StatsFrame = Instance.new("Frame", ScreenGui)

    StatsFrame.Size = UDim2.new(0, 140, 0, 25); StatsFrame.Position = UDim2.new(0.5, -70, 0, 35); StatsFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15); StatsFrame.BackgroundTransparency = 0.2; StatsFrame.ZIndex = 500; StatsFrame.Visible = config.ShowStats; Instance.new("UICorner", StatsFrame)

    local StatsStroke = Instance.new("UIStroke", StatsFrame); StatsStroke.Color = accentColor; StatsStroke.Thickness = 1.5; table.insert(themedElements.Strokes, StatsStroke)

    local StatsLabel = Instance.new("TextLabel", StatsFrame); StatsLabel.Size = UDim2.new(1, 0, 1, 0); StatsLabel.BackgroundTransparency = 1; StatsLabel.TextColor3 = Color3.new(1, 1, 1); StatsLabel.Font = Enum.Font.Code; StatsLabel.TextSize = 12; StatsLabel.ZIndex = 501



    task.spawn(function()

        while task.wait(0.2) do

            if config.ShowStats then

                local fps = math.floor(1 / RunService.RenderStepped:Wait())

                local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())

                StatsLabel.Text = string.format("FPS: %d | PING: %d", fps, ping)

            end

        end

    end)



    -- Main UI

    local MainFrame = Instance.new("Frame", ScreenGui)

    MainFrame.Name = "MainFrame"; MainFrame.Size = UDim2.new(0, 500, 0, 360); MainFrame.Position = UDim2.new(0.5, -250, 0.5, -180); MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15); MainFrame.BorderSizePixel = 0; MainFrame.ClipsDescendants = true; MainFrame.ZIndex = 5; Instance.new("UICorner", MainFrame)

    local MainStroke = Instance.new("UIStroke", MainFrame); MainStroke.Thickness = 2; MainStroke.Color = accentColor; table.insert(themedElements.Strokes, MainStroke)



    -- Draggable

    local dragging, dragStart, startPos

    MainFrame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = MainFrame.Position end end)

    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then local delta = input.Position - dragStart; MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)

    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)



    -- Watermark

    local WatermarkFrame = Instance.new("Frame", MainFrame)

    WatermarkFrame.Size = UDim2.new(1.5, 0, 1.5, 0); WatermarkFrame.Position = UDim2.new(-0.25, 0, -0.25, 0); WatermarkFrame.BackgroundTransparency = 1; WatermarkFrame.ZIndex = 6; WatermarkFrame.Active = false

    for x = 0, 8 do for y = 0, 8 do

        local txt = Instance.new("TextLabel", WatermarkFrame)

        txt.Text = "NAX"; txt.Font = Enum.Font.SourceSansBold; txt.TextSize = 25; txt.TextColor3 = accentColor; txt.TextTransparency = 0.95; txt.BackgroundTransparency = 1; txt.Position = UDim2.new(0, x * 85, 0, y * 65); txt.Rotation = -25; txt.ZIndex = 6; table.insert(themedElements.Watermarks, txt)

    end end

    task.spawn(function() while MainFrame.Parent do WatermarkFrame.Position = WatermarkFrame.Position + UDim2.new(0, 0.4, 0, 0.3) if WatermarkFrame.Position.X.Offset >= 0 then WatermarkFrame.Position = UDim2.new(-0.25, 0, -0.25, 0) end task.wait(0.03) end end)



    -- Branding Fixed

    local Branding = Instance.new("Frame", MainFrame); Branding.Size = UDim2.new(0, 200, 0, 40); Branding.Position = UDim2.new(0, 140, 0, 15); Branding.BackgroundTransparency = 1; Branding.ZIndex = 101

    local NaxText = Instance.new("TextLabel", Branding); NaxText.Size = UDim2.new(0, 40, 1, 0); NaxText.BackgroundTransparency = 1; NaxText.Font = Enum.Font.SourceSansBold; NaxText.TextSize = 24; NaxText.TextColor3 = accentColor; NaxText.Text = "Nax"; NaxText.Rotation = -8; NaxText.ZIndex = 102; table.insert(themedElements.Branding, NaxText)

    local HubText = Instance.new("TextLabel", Branding); HubText.Size = UDim2.new(1, -45, 1, 0); HubText.Position = UDim2.new(0, 45, 0, 0); HubText.BackgroundTransparency = 1; HubText.Font = Enum.Font.SourceSansBold; HubText.TextSize = 20; HubText.TextColor3 = Color3.new(1, 1, 1); HubText.Text = "Hub Premium"; HubText.TextXAlignment = Enum.TextXAlignment.Left; HubText.ZIndex = 102



    -- Sidebar

    local Sidebar = Instance.new("Frame", MainFrame); Sidebar.Size = UDim2.new(0, 130, 1, 0); Sidebar.BackgroundColor3 = Color3.fromRGB(8, 8, 10); Sidebar.ZIndex = 100; Instance.new("UICorner", Sidebar)

    local ProfileImage = Instance.new("ImageLabel", Sidebar); ProfileImage.Size = UDim2.new(0, 55, 0, 55); ProfileImage.Position = UDim2.new(0.5, -27, 0, 20); ProfileImage.ZIndex = 110; Instance.new("UICorner", ProfileImage).CornerRadius = UDim.new(1, 0)

    local ProfStroke = Instance.new("UIStroke", ProfileImage); ProfStroke.Thickness = 2; ProfStroke.Color = accentColor; ProfStroke.ZIndex = 111; table.insert(themedElements.Strokes, ProfStroke)

    pcall(function() ProfileImage.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end)

    local UserLabel = Instance.new("TextLabel", Sidebar); UserLabel.Size = UDim2.new(1, 0, 0, 20); UserLabel.Position = UDim2.new(0, 0, 0, 80); UserLabel.BackgroundTransparency = 1; UserLabel.ZIndex = 110; UserLabel.Font = Enum.Font.SourceSansBold; UserLabel.TextSize = 11; UserLabel.TextColor3 = Color3.fromRGB(200, 200, 200); UserLabel.Text = "@" .. LocalPlayer.Name

    local PlayerCountLabel = Instance.new("TextLabel", Sidebar); PlayerCountLabel.Size = UDim2.new(1, -10, 0, 25); PlayerCountLabel.Position = UDim2.new(0, 8, 1, -25); PlayerCountLabel.BackgroundTransparency = 1; PlayerCountLabel.ZIndex = 110; PlayerCountLabel.Font = Enum.Font.SourceSansSemibold; PlayerCountLabel.TextSize = 12; PlayerCountLabel.TextColor3 = Color3.fromRGB(180, 180, 180); PlayerCountLabel.RichText = true; PlayerCountLabel.TextXAlignment = Enum.TextXAlignment.Left

    task.spawn(function() while MainFrame.Parent do PlayerCountLabel.Text = string.format("<font color='#00FF00'>●</font> %d Players", #Players:GetPlayers()) task.wait(1) end end)

    local Credits = Instance.new("TextLabel", MainFrame); Credits.Size = UDim2.new(0, 200, 0, 20); Credits.Position = UDim2.new(1, -210, 1, -25); Credits.BackgroundTransparency = 1; Credits.ZIndex = 101; Credits.Font = Enum.Font.SourceSansBold; Credits.TextSize = 13; Credits.TextColor3 = Color3.fromRGB(100, 100, 100); Credits.TextXAlignment = Enum.TextXAlignment.Right; Credits.RichText = true; Credits.Text = "Nax | <font color='#5865F2'>💬</font> pweck_."



    -- Component Helpers

    local function CreateSlider(text, min, max, configKey, parent, callback)

        local f = Instance.new("Frame", parent); f.Size = UDim2.new(1, -10, 0, 48); f.BackgroundTransparency = 1; f.ZIndex = 120

        local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 18); l.BackgroundTransparency = 1; l.ZIndex = 121; l.Font = Enum.Font.SourceSansSemibold; l.TextColor3 = Color3.fromRGB(180, 180, 180); l.TextSize = 12; l.TextXAlignment = Enum.TextXAlignment.Left; l.Text = text

        local vL = Instance.new("TextLabel", f); vL.Size = UDim2.new(1, 0, 0, 18); vL.BackgroundTransparency = 1; vL.ZIndex = 121; vL.Font = Enum.Font.SourceSansBold; vL.TextColor3 = accentColor; vL.TextXAlignment = Enum.TextXAlignment.Right; vL.Text = tostring(config[configKey])

        local bg = Instance.new("Frame", f); bg.Size = UDim2.new(1, 0, 0, 5); bg.Position = UDim2.new(0, 0, 0, 28); bg.BackgroundColor3 = Color3.fromRGB(30, 30, 35); bg.ZIndex = 121; Instance.new("UICorner", bg)

        local fill = Instance.new("Frame", bg); fill.Size = UDim2.new((config[configKey]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = accentColor; fill.ZIndex = 122; Instance.new("UICorner", fill); table.insert(themedElements.Toggles, {State = true, Frame = fill})

        local b = Instance.new("TextButton", bg); b.Size = UDim2.new(1, 0, 1, 0); b.BackgroundTransparency = 1; b.ZIndex = 125; b.Text = ""

        local drag = false; b.MouseButton1Down:Connect(function() drag = true end)

        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 and drag then drag = false; SaveConfig() end end)

        RunService.RenderStepped:Connect(function() if drag then

            local pct = math.clamp((UserInputService:GetMouseLocation().X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1); local val = math.floor(min + (max-min)*pct)

            config[configKey] = val; fill.Size = UDim2.new(pct, 0, 1, 0); vL.Text = tostring(val); callback(val)

        end end)

    end



    local function CreateToggle(text, configKey, parent, callback)

        local btn = Instance.new("TextButton", parent); btn.Size = UDim2.new(1, -10, 0, 38); btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25); btn.Text = ""; btn.ZIndex = 120; Instance.new("UICorner", btn)

        local lbl = Instance.new("TextLabel", btn); lbl.Size = UDim2.new(1, -50, 1, 0); lbl.Position = UDim2.new(0, 12, 0, 0); lbl.BackgroundTransparency = 1; lbl.ZIndex = 121; lbl.Font = Enum.Font.SourceSansSemibold; lbl.TextColor3 = Color3.fromRGB(210, 210, 210); lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Text = text

        local p = Instance.new("Frame", btn); p.Size = UDim2.new(0, 32, 0, 18); p.Position = UDim2.new(1, -42, 0.5, -9); p.BackgroundColor3 = Color3.fromRGB(40, 40, 45); p.ZIndex = 121; Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)

        local c = Instance.new("Frame", p); c.Size = UDim2.new(0, 14, 0, 14); c.Position = UDim2.new(0, 2, 0.5, -7); c.BackgroundColor3 = Color3.fromRGB(160, 160, 160); c.ZIndex = 122; Instance.new("UICorner", c).CornerRadius = UDim.new(1, 0)

        local tRef = {State = config[configKey], Frame = p}; table.insert(themedElements.Toggles, tRef)

        local function u() local s = config[configKey]; tRef.State = s; TweenService:Create(c, TweenInfo.new(0.2), {Position = s and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play() p.BackgroundColor3 = s and accentColor or Color3.fromRGB(40, 40, 45) end

        u(); btn.MouseButton1Click:Connect(function() config[configKey] = not config[configKey]; callback(config[configKey]); u(); SaveConfig() end)

    end



    -- Tab Logic

    local PageContainer = Instance.new("Frame", MainFrame); PageContainer.Size = UDim2.new(1, -150, 1, -110); PageContainer.Position = UDim2.new(0, 140, 0, 65); PageContainer.BackgroundTransparency = 1; PageContainer.ZIndex = 100; PageContainer.ClipsDescendants = true

    local Pages = {Visuals = Instance.new("ScrollingFrame", PageContainer), Misc = Instance.new("ScrollingFrame", PageContainer), Settings = Instance.new("ScrollingFrame", PageContainer)}

    for _, p in pairs(Pages) do p.Size = UDim2.new(1,0,1,0); p.BackgroundTransparency = 1; p.ZIndex = 101; p.ScrollBarThickness = 0; p.Visible = false; p.AutomaticCanvasSize = Enum.AutomaticSize.Y; Instance.new("UIListLayout", p).Padding = UDim.new(0, 10) end

    Pages.Visuals.Visible = true



    local TabIndicator = Instance.new("Frame", Sidebar); TabIndicator.Size = UDim2.new(0, 3, 0, 18); TabIndicator.Position = UDim2.new(0, 0, 0, 128.5); TabIndicator.BackgroundColor3 = Color3.new(1,1,1); TabIndicator.ZIndex = 102; Instance.new("UICorner", TabIndicator)

    local function CreateTab(text, y)

        local btn = Instance.new("TextButton", Sidebar); btn.Size = UDim2.new(1, 0, 0, 35); btn.Position = UDim2.new(0, 0, 0, y); btn.BackgroundTransparency = 1; btn.ZIndex = 102; btn.Font = Enum.Font.SourceSansBold; btn.TextSize = 14; btn.TextColor3 = (text == "Visuals") and Color3.new(1, 1, 1) or Color3.fromRGB(120, 120, 120); btn.Text = text

        btn.MouseButton1Click:Connect(function() for n, p in pairs(Pages) do p.Visible = (n == text) end for _, v in pairs(Sidebar:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Color3.fromRGB(120, 120, 120) end end btn.TextColor3 = Color3.new(1, 1, 1) end)

    end

    CreateTab("Visuals", 120); CreateTab("Misc", 155); CreateTab("Settings", 190)



    -- Inject Features

    CreateToggle("Enable Player ESP", "ESPEnabled", Pages.Visuals, function() end)

    CreateSlider("ESP Distance", 50, 10000, "MaxDistance", Pages.Visuals, function() end)

    CreateSlider("ESP Text Size", 8, 24, "TextSize", Pages.Visuals, function() end)

    

    CreateToggle("Fullbright / Night Vision", "Fullbright", Pages.Misc, function() end)

    CreateToggle("Proximity Danger Alert", "ProximityAlert", Pages.Misc, function() end)

    CreateToggle("Show Display Names", "ShowDisplay", Pages.Misc, function() end)

    CreateToggle("Show Usernames", "ShowUser", Pages.Misc, function() end)



    CreateToggle("Show Live FPS & Ping", "ShowStats", Pages.Settings, function(v) StatsFrame.Visible = v end)

    CreateSlider("Main Theme Hue", 0, 360, "Hue", Pages.Settings, function() UpdateTheme() end)

    CreateSlider("ESP Highlight Hue", 0, 360, "HighHue", Pages.Settings, function(v) highlightColor = Color3.fromHSV(v/360, 0.7, 1) end)

    local ResetBtn = Instance.new("TextButton", Pages.Settings); ResetBtn.Size = UDim2.new(1, -10, 0, 40); ResetBtn.BackgroundColor3 = Color3.fromRGB(35, 15, 15); ResetBtn.ZIndex = 106; ResetBtn.Text = "Reset Config"; ResetBtn.TextColor3 = Color3.new(1, 1, 1); ResetBtn.Font = Enum.Font.SourceSansBold; ResetBtn.TextSize = 15; Instance.new("UICorner", ResetBtn)

    ResetBtn.MouseButton1Click:Connect(function() pcall(function() delfile("NaxHub_Config.json") end) end)

    local DestroyBtn = Instance.new("TextButton", Pages.Settings); DestroyBtn.Size = UDim2.new(1, -10, 0, 40); DestroyBtn.BackgroundColor3 = Color3.fromRGB(50, 0, 0); DestroyBtn.ZIndex = 106; DestroyBtn.Text = "Destroy Hub GUI"; DestroyBtn.TextColor3 = Color3.new(1, 1, 1); DestroyBtn.Font = Enum.Font.SourceSansBold; DestroyBtn.TextSize = 15; Instance.new("UICorner", DestroyBtn)

    DestroyBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)



    -- Loops

    RunService.RenderStepped:Connect(function()

        if not config.ESPEnabled then ESPFolder:ClearAllChildren(); HighFolder:ClearAllChildren() return end

        for _, Player in pairs(Players:GetPlayers()) do 

            if Player ~= LocalPlayer and Player.Character then 

                pcall(function()

                    local root = Player.Character:FindFirstChild("HumanoidRootPart") or Player.Character.PrimaryPart

                    if root then

                        local dist = (workspace.CurrentCamera.CFrame.Position - root.Position).Magnitude

                        if dist <= config.MaxDistance then

                            local tag = ESPFolder:FindFirstChild(Player.Name.."_T") or Instance.new("BillboardGui", ESPFolder); tag.Name = Player.Name.."_T"; tag.AlwaysOnTop = true; tag.Size = UDim2.new(0, 200, 0, 50); tag.StudsOffset = Vector3.new(0, 3, 0); tag.Adornee = root

                            local lbl = tag:FindFirstChild("L") or Instance.new("TextLabel", tag); lbl.Name = "L"; lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1; lbl.TextColor3 = Color3.new(1,1,1); lbl.TextSize = config.TextSize; lbl.Font = Enum.Font.Code; lbl.RichText = true

                            local lns = {} if config.ShowDisplay then table.insert(lns, Player.DisplayName) end if config.ShowUser then table.insert(lns, "@"..Player.Name) end table.insert(lns, math.floor(dist).."m"); lbl.Text = table.concat(lns, " | ")

                            local high = HighFolder:FindFirstChild(Player.Name.."_H") or Instance.new("Highlight", HighFolder); high.Name = Player.Name.."_H"; high.Adornee = Player.Character; high.FillColor = highlightColor

                        else

                            if ESPFolder:FindFirstChild(Player.Name.."_T") then ESPFolder[Player.Name.."_T"]:Destroy() end

                            if HighFolder:FindFirstChild(Player.Name.."_H") then HighFolder[Player.Name.."_H"]:Destroy() end

                        end

                    end

                end)

            end

        end

    end)



    UserInputService.InputBegan:Connect(function(i, gp) if not gp and i.KeyCode == Enum.KeyCode[config.MenuKey] then MainFrame.Visible = not MainFrame.Visible end end)

    MainFrame.Visible = true

end)

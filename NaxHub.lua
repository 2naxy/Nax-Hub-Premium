task.spawn(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local HttpService = game:GetService("HttpService")
    local Lighting = game:GetService("Lighting")

    local LocalPlayer = Players.LocalPlayer
    while not LocalPlayer do task.wait() LocalPlayer = Players.LocalPlayer end
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

    -- [[ GLOBAL KILLSWITCH ]] --
    if getgenv().Nax_Cleanup then pcall(function() getgenv().Nax_Cleanup() end) end

    local HubRunning = true 
    local StatsLoopConnection, ESPLoopConnection
    local espCache = {}
    local highCache = {}

    getgenv().Nax_Cleanup = function()
        HubRunning = false
        if StatsLoopConnection then StatsLoopConnection:Disconnect() end
        if ESPLoopConnection then ESPLoopConnection:Disconnect() end
        if PlayerGui:FindFirstChild("NaxEliteFinal") then PlayerGui.NaxEliteFinal:Destroy() end
        if workspace.CurrentCamera:FindFirstChild("NaxHighFolder") then workspace.CurrentCamera.NaxHighFolder:Destroy() end
        if workspace.CurrentCamera:FindFirstChild("NaxESPCache") then workspace.CurrentCamera.NaxESPCache:Destroy() end
        table.clear(espCache)
        table.clear(highCache)
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NaxEliteFinal"; ScreenGui.ResetOnSpawn = false; ScreenGui.IgnoreGuiInset = true; ScreenGui.Parent = PlayerGui

    local ESPFolder = Instance.new("Folder", ScreenGui); ESPFolder.Name = "ESPCache"
    local HighFolder = Instance.new("Folder", workspace.CurrentCamera); HighFolder.Name = "NaxHighFolder"

    -- [[ PREMIUM AUDIO ASSETS ]] --
    local HoverSound = Instance.new("Sound", ScreenGui); HoverSound.SoundId = "rbxassetid://6895056282"; HoverSound.Volume = 0.2
    local ClickSound = Instance.new("Sound", ScreenGui); ClickSound.SoundId = "rbxassetid://6895058925"; ClickSound.Volume = 0.4
    local function PlayHover() pcall(function() HoverSound:Play() end) end
    local function PlayClick() pcall(function() ClickSound:Play() end) end

    -- [[ PROXIMITY ALERT UI & AUDIO ]] --
    local ProxVignette = Instance.new("ImageLabel", ScreenGui)
    ProxVignette.Size = UDim2.new(1, 0, 1, 0); ProxVignette.BackgroundTransparency = 1
    ProxVignette.Image = "rbxassetid://5736236254"; ProxVignette.ImageColor3 = Color3.new(1, 0, 0); ProxVignette.ImageTransparency = 1; ProxVignette.ZIndex = 1
    
    local ProxText = Instance.new("TextLabel", ScreenGui)
    ProxText.Size = UDim2.new(1, 0, 0, 50); ProxText.Position = UDim2.new(0, 0, 0.8, 0)
    ProxText.BackgroundTransparency = 1; ProxText.Font = Enum.Font.GothamBold; ProxText.TextSize = 22
    ProxText.TextColor3 = Color3.new(1, 0.2, 0.2); ProxText.TextTransparency = 1; ProxText.TextStrokeTransparency = 1
    ProxText.TextStrokeColor3 = Color3.new(0, 0, 0); ProxText.ZIndex = 2

    local ProxSound = Instance.new("Sound", ScreenGui)
    ProxSound.SoundId = "rbxassetid://886105315"; ProxSound.Volume = 0.5; ProxSound.Looped = true
    local isAlerting = false

    -- [[ 1. THE 6-SECOND TROLL LOADER ]] --
    local LoadFrame = Instance.new("Frame", ScreenGui)
    LoadFrame.Size = UDim2.new(0, 320, 0, 140); LoadFrame.Position = UDim2.new(0.5, -160, 0.5, -70)
    LoadFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15); LoadFrame.ZIndex = 5000; Instance.new("UICorner", LoadFrame)
    local LoadStroke = Instance.new("UIStroke", LoadFrame); LoadStroke.Thickness = 2; LoadStroke.Color = Color3.fromRGB(60, 60, 70)
    
    local LoadLabel = Instance.new("TextLabel", LoadFrame)
    LoadLabel.Size = UDim2.new(1, 0, 1, 0); LoadLabel.BackgroundTransparency = 1; LoadLabel.Font = Enum.Font.GothamBold; LoadLabel.TextColor3 = Color3.new(1, 1, 1); LoadLabel.TextSize = 20; LoadLabel.ZIndex = 5001; LoadLabel.Text = "Loading Nax Hub Premium..."
    
    local LoadSound = Instance.new("Sound", ScreenGui); LoadSound.SoundId = "rbxassetid://105471012712320"; LoadSound.Volume = 2; LoadSound:Play()
    task.wait(2.5); if not HubRunning then return end 
    LoadLabel.Text = "Sike just wasting ur time lil bro"; LoadLabel.TextColor3 = Color3.fromRGB(255, 60, 60); LoadLabel.TextSize = 22
    task.wait(2.5); if not HubRunning then return end 
    
    local trollSequence = {3, 2, 1, 2, 3, 4, 5, 4, 3, 2, 3, 2, 1}
    for _, num in ipairs(trollSequence) do LoadLabel.Text = "Starting in... " .. tostring(num); task.wait(0.8); if not HubRunning then return end end
    
    LoadLabel.Text = "Starting in... 0"; LoadLabel.TextColor3 = Color3.fromRGB(60, 255, 60)
    task.wait(1); if LoadFrame and LoadFrame.Parent then LoadFrame:Destroy() end
    if not HubRunning then return end 

    -- [[ 2. CONFIG SYSTEM ]] --
    local defaultCfg = { 
        Hue = 234, UISat = 70, UIVal = 100, RainbowTheme = false, 
        HighHue = 210, ESPSat = 70, ESPVal = 100, 
        MaxDistance = 100000, ESPRefreshRate = 60, TextSize = 14, MenuKey = "LeftControl", 
        ESPEnabled = false, ShowDisplay = true, ShowUser = true, ProximityAlert = false, 
        ShowStats = true, Fullbright = false, TargetName = "Select Player", TargetESP = false, 
        FPSBooster = false, KickOnAdmin = false
    }
    local config = table.clone(defaultCfg)
    local function SaveConfig() pcall(function() writefile("NaxHub_Config.json", HttpService:JSONEncode(config)) end) end
    pcall(function() if isfile("NaxHub_Config.json") then local d = HttpService:JSONDecode(readfile("NaxHub_Config.json")) for i,v in pairs(d) do if config[i] ~= nil then config[i] = v end end end end)

    local accentColor = Color3.fromHSV(config.Hue / 360, config.UISat / 100, config.UIVal / 100)
    local darkAccentColor = accentColor
    local highlightColor = Color3.fromHSV(config.HighHue / 360, config.ESPSat / 100, config.ESPVal / 100)
    local UIUpdaters = {}

    -- [[ 🛡️ ENHANCED STAFF KICK SECURITY (Artist Whitelist) ]] --
    local AdminGroupId = 2919215
    local function CheckForAdmin(player)
        if not config.KickOnAdmin or player == LocalPlayer or not HubRunning then return end
        task.spawn(function()
            pcall(function()
                local rank = player:GetRankInGroup(AdminGroupId)
                local role = player:GetRoleInGroup(AdminGroupId)
                local lowerRole = string.lower(role)
                
                -- Check rank and apply whitelist for Artists and Creators
                if rank > 1 and not string.find(lowerRole, "creator") and not string.find(lowerRole, "artist") then
                    LocalPlayer:Kick("🛡️ Nax Security Disconnect\n\nA group staff member joined the server!\n\nRole: " .. role .. "\nPlayer: " .. player.Name)
                end
            end)
        end)
    end
    Players.PlayerAdded:Connect(function(player) if config.KickOnAdmin then CheckForAdmin(player) end end)

    -- [[ 3. THEME ENGINE ]] --
    local themedElements = {Strokes = {}, Toggles = {}, Watermarks = {}, Branding = {}, Gradients = {}, Stats = {}, AccentGradients = {}, HoverStrokes = {}, Tabs = {}}
    local function UpdateTheme()
        local h, s, v = (tonumber(config.Hue) or 234) / 360, (tonumber(config.UISat) or 70) / 100, (tonumber(config.UIVal) or 100) / 100
        accentColor = Color3.fromHSV(h, s, v)
        local vDark = v > 0.5 and math.max(0, v - 0.4) or math.min(1, v + 0.3)
        darkAccentColor = Color3.fromHSV(h, s, vDark)
        local vDim = v > 0.5 and math.max(0, v - 0.8) or math.min(1, v + 0.2)
        local dimAccentColor = Color3.fromHSV(h, s, vDim)
        highlightColor = Color3.fromHSV((tonumber(config.HighHue) or 210) / 360, (tonumber(config.ESPSat) or 70) / 100, (tonumber(config.ESPVal) or 100) / 100)
        
        for _, obj in pairs(themedElements.Strokes) do obj.Color = accentColor end
        for _, obj in pairs(themedElements.Toggles) do if obj.State then obj.Frame.BackgroundColor3 = accentColor end end
        for _, obj in pairs(themedElements.Watermarks) do obj.TextColor3 = accentColor end
        for _, obj in pairs(themedElements.Branding) do obj.TextColor3 = accentColor end
        for _, obj in pairs(themedElements.Stats) do obj.TextColor3 = accentColor end
        for _, obj in pairs(themedElements.Tabs) do if obj.IsActive then obj.Button.TextColor3 = accentColor end end
        for _, g in pairs(themedElements.Gradients) do g.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, dimAccentColor), ColorSequenceKeypoint.new(0.25, accentColor), ColorSequenceKeypoint.new(0.5, dimAccentColor), ColorSequenceKeypoint.new(0.75, accentColor), ColorSequenceKeypoint.new(1, dimAccentColor)}) end
        for _, ag in pairs(themedElements.AccentGradients) do ag.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, accentColor), ColorSequenceKeypoint.new(1, darkAccentColor)}) end
    end

    task.spawn(function()
        while HubRunning do
            task.wait(0.05)
            if config.RainbowTheme then config.Hue = (config.Hue + 2) % 360; UpdateTheme(); for _, uFunc in ipairs(UIUpdaters) do pcall(uFunc) end end
            if isAlerting then TweenService:Create(ProxVignette, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true), {ImageTransparency = 0.4}):Play() end
        end
    end)

    -- [[ 4. MAIN HUB & TRUE ACRYLIC GLASSMORPHISM ]] --
    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 400, 0, 280); MainFrame.Position = UDim2.new(0.5, -200, 0.5, -140)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20); MainFrame.BackgroundTransparency = 0.15
    MainFrame.ZIndex = 10; MainFrame.Visible = true; Instance.new("UICorner", MainFrame)
    
    -- ACRYLIC NOISE TEXTURE
    local NoiseOverlay = Instance.new("ImageLabel", MainFrame)
    NoiseOverlay.Size = UDim2.new(1, 0, 1, 0); NoiseOverlay.BackgroundTransparency = 1
    NoiseOverlay.Image = "rbxassetid://13807212005"; NoiseOverlay.ImageTransparency = 0.9
    NoiseOverlay.ScaleType = Enum.ScaleType.Tile; NoiseOverlay.TileSize = UDim2.new(0, 128, 0, 128)
    NoiseOverlay.ZIndex = 11; Instance.new("UICorner", NoiseOverlay)

    local MainStroke = Instance.new("UIStroke", MainFrame); MainStroke.Thickness = 2.5; MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local StrokeGradient = Instance.new("UIGradient", MainStroke); table.insert(themedElements.Gradients, StrokeGradient)
    StrokeGradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.1, 1), NumberSequenceKeypoint.new(0.25, 0), NumberSequenceKeypoint.new(0.4, 1), NumberSequenceKeypoint.new(0.6, 1), NumberSequenceKeypoint.new(0.75, 0), NumberSequenceKeypoint.new(0.9, 1), NumberSequenceKeypoint.new(1, 1)})
    task.spawn(function() while HubRunning and MainFrame.Parent do StrokeGradient.Rotation = (StrokeGradient.Rotation + 0.6) % 360 task.wait(0.01) end end)

    TweenService:Create(MainFrame, TweenInfo.new(0.7, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Size = UDim2.new(0, 500, 0, 360), Position = UDim2.new(0.5, -250, 0.5, -180)}):Play()

    local WatermarkClipFrame = Instance.new("Frame", MainFrame)
    WatermarkClipFrame.Size = UDim2.new(1, 0, 1, 0); WatermarkClipFrame.BackgroundTransparency = 1; WatermarkClipFrame.ClipsDescendants = true; Instance.new("UICorner", WatermarkClipFrame)

    local WatermarkContainer = Instance.new("Frame", WatermarkClipFrame); WatermarkContainer.Size = UDim2.new(1.5, 0, 1.5, 0); WatermarkContainer.Position = UDim2.new(-0.25, 0, -0.25, 0); WatermarkContainer.BackgroundTransparency = 1; WatermarkContainer.ZIndex = 12
    for x = 0, 8 do for y = 0, 8 do
        local txt = Instance.new("TextLabel", WatermarkContainer); txt.Text = "NAX"; txt.Font = Enum.Font.GothamBold; txt.TextSize = 25; txt.TextColor3 = accentColor; txt.TextTransparency = 0.95; txt.BackgroundTransparency = 1; txt.Position = UDim2.new(0, x * 85, 0, y * 65); txt.Rotation = -25; txt.ZIndex = 12; table.insert(themedElements.Watermarks, txt)
    end end
    task.spawn(function() while HubRunning and MainFrame.Parent do WatermarkContainer.Position = WatermarkContainer.Position + UDim2.new(0, 0.4, 0, 0.3) if WatermarkContainer.Position.X.Offset >= 0 then WatermarkContainer.Position = UDim2.new(-0.25, 0, -0.25, 0) end task.wait(0.03) end end)

    local Sidebar = Instance.new("Frame", MainFrame); Sidebar.Size = UDim2.new(0, 130, 1, 0); Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 14); Sidebar.BackgroundTransparency = 0.3; Sidebar.ZIndex = 20; Instance.new("UICorner", Sidebar)
    local ProfileImage = Instance.new("ImageLabel", Sidebar); ProfileImage.Size = UDim2.new(0, 55, 0, 55); ProfileImage.Position = UDim2.new(0.5, -27, 0, 20); ProfileImage.ZIndex = 25; Instance.new("UICorner", ProfileImage).CornerRadius = UDim.new(1, 0)
    local ProfStroke = Instance.new("UIStroke", ProfileImage); ProfStroke.Thickness = 2; ProfStroke.Color = accentColor; table.insert(themedElements.Strokes, ProfStroke)
    pcall(function() ProfileImage.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end)
    local UserLabel = Instance.new("TextLabel", Sidebar); UserLabel.Size = UDim2.new(1, 0, 0, 20); UserLabel.Position = UDim2.new(0, 0, 0, 80); UserLabel.BackgroundTransparency = 1; UserLabel.ZIndex = 25; UserLabel.Font = Enum.Font.GothamBold; UserLabel.TextSize = 11; UserLabel.TextColor3 = Color3.fromRGB(200, 200, 200); UserLabel.Text = "@" .. LocalPlayer.Name
    local PlayerCountLabel = Instance.new("TextLabel", Sidebar); PlayerCountLabel.Size = UDim2.new(1, -10, 0, 25); PlayerCountLabel.Position = UDim2.new(0, 8, 1, -25); PlayerCountLabel.BackgroundTransparency = 1; PlayerCountLabel.ZIndex = 25; PlayerCountLabel.Font = Enum.Font.GothamMedium; PlayerCountLabel.TextSize = 12; PlayerCountLabel.TextColor3 = Color3.fromRGB(180, 180, 180); PlayerCountLabel.RichText = true; PlayerCountLabel.TextXAlignment = Enum.TextXAlignment.Left
    task.spawn(function() while HubRunning and MainFrame.Parent do PlayerCountLabel.Text = string.format("<font color='#00FF00'>●</font> %d Players", #Players:GetPlayers()) task.wait(1) end end)

    local Branding = Instance.new("Frame", MainFrame); Branding.Size = UDim2.new(0, 200, 0, 40); Branding.Position = UDim2.new(0, 140, 0, 15); Branding.BackgroundTransparency = 1; Branding.ZIndex = 30
    local NaxText = Instance.new("TextLabel", Branding); NaxText.Size = UDim2.new(0, 40, 1, 0); NaxText.BackgroundTransparency = 1; NaxText.Font = Enum.Font.GothamBold; NaxText.TextSize = 24; NaxText.Text = "Nax"; NaxText.Rotation = -8; NaxText.ZIndex = 31; table.insert(themedElements.Branding, NaxText)
    local HubText = Instance.new("TextLabel", Branding); HubText.Size = UDim2.new(1, -45, 1, 0); HubText.Position = UDim2.new(0, 45, 0, 0); HubText.BackgroundTransparency = 1; HubText.Font = Enum.Font.GothamBold; HubText.TextSize = 20; HubText.TextColor3 = Color3.new(1, 1, 1); HubText.Text = "Hub Premium"; HubText.ZIndex = 31; HubText.TextXAlignment = Enum.TextXAlignment.Left
    task.spawn(function() local t = 0 while HubRunning and MainFrame.Parent do t = t + 0.05 NaxText.Rotation = -8 + (math.sin(t) * 6) NaxText.TextSize = 24 * (1 + (math.cos(t * 0.5) * 0.06)) task.wait(0.02) end end)

    -- [[ 5. PAGE LOGIC & SEAMLESS TRANSITIONS ]] --
    local layoutOrders = {}
    local function GetOrder(parent) layoutOrders[parent] = (layoutOrders[parent] or 0) + 1; return layoutOrders[parent] end

    local PageContainer = Instance.new("Frame", MainFrame); PageContainer.Size = UDim2.new(1, -150, 1, -110); PageContainer.Position = UDim2.new(0, 140, 0, 65); PageContainer.BackgroundTransparency = 1; PageContainer.ZIndex = 30; PageContainer.ClipsDescendants = true
    local Pages = {Visuals = Instance.new("ScrollingFrame", PageContainer), Misc = Instance.new("ScrollingFrame", PageContainer), Settings = Instance.new("ScrollingFrame", PageContainer)}
    
    for _, p in pairs(Pages) do 
        p.Size = UDim2.new(1,0,1,0); p.BackgroundTransparency = 1; p.ZIndex = 31; p.Visible = false; p.ScrollBarThickness = 0; p.CanvasSize = UDim2.new(0, 0, 0, 1000); p.AutomaticCanvasSize = Enum.AutomaticSize.Y
        local ll = Instance.new("UIListLayout", p); ll.Padding = UDim.new(0, 10); ll.SortOrder = Enum.SortOrder.LayoutOrder
        task.spawn(function() while HubRunning and p.Parent do if p.Visible then p.CanvasSize = UDim2.new(0, 0, 0, ll.AbsoluteContentSize.Y + 20) end task.wait(0.5) end end)
    end
    Pages.Visuals.Visible = true

    local function ApplyHoverEffects(btn, stroke, normalColor, hoverColor)
        btn.MouseEnter:Connect(function() PlayHover() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play() if stroke then TweenService:Create(stroke, TweenInfo.new(0.2), {Color = accentColor}):Play() end end)
        btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = normalColor}):Play() if stroke then TweenService:Create(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(35, 35, 40)}):Play() end end)
    end

    local function CreateTab(text, y)
        local btn = Instance.new("TextButton", Sidebar); btn.Size = UDim2.new(1, 0, 0, 35); btn.Position = UDim2.new(0, 0, 0, y); btn.BackgroundTransparency = 1; btn.ZIndex = 25; btn.Font = Enum.Font.GothamBold; btn.TextSize = 14; btn.Text = text
        local tRef = {Button = btn, IsActive = (text == "Visuals")}; table.insert(themedElements.Tabs, tRef)
        btn.TextColor3 = tRef.IsActive and accentColor or Color3.fromRGB(120, 120, 120)

        btn.MouseEnter:Connect(function() PlayHover() if not tRef.IsActive then TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(180, 180, 180)}):Play() end end)
        btn.MouseLeave:Connect(function() if not tRef.IsActive then TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(120, 120, 120)}):Play() end end)
        
        btn.MouseButton1Click:Connect(function() 
            PlayClick()
            for n, p in pairs(Pages) do 
                if n == text and not p.Visible then
                    -- Fluid Page Slide Transition
                    p.Visible = true
                    p.Position = UDim2.new(0, 0, 0, 15)
                    TweenService:Create(p, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
                elseif n ~= text then
                    p.Visible = false
                end
            end 
            for _, t in pairs(themedElements.Tabs) do t.IsActive = (t.Button == btn); TweenService:Create(t.Button, TweenInfo.new(0.2), {TextColor3 = t.IsActive and accentColor or Color3.fromRGB(120, 120, 120)}):Play() end 
        end)
    end
    CreateTab("Visuals", 120); CreateTab("Misc", 155); CreateTab("Settings", 190)

    -- [[ 6. UI COMPONENTS ]] --
    local function CreateToggle(text, configKey, parent, callback)
        local btn = Instance.new("TextButton", parent); btn.Size = UDim2.new(1, -10, 0, 38); btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25); btn.Text = ""; btn.ZIndex = 35; btn.LayoutOrder = GetOrder(parent)
        Instance.new("UICorner", btn); local stroke = Instance.new("UIStroke", btn); stroke.Color = Color3.fromRGB(35, 35, 40); table.insert(themedElements.HoverStrokes, stroke)
        ApplyHoverEffects(btn, stroke, Color3.fromRGB(20, 20, 25), Color3.fromRGB(28, 28, 33))
        
        local lbl = Instance.new("TextLabel", btn); lbl.Size = UDim2.new(1, -50, 1, 0); lbl.Position = UDim2.new(0, 12, 0, 0); lbl.BackgroundTransparency = 1; lbl.Font = Enum.Font.GothamSemibold; lbl.TextColor3 = Color3.fromRGB(220, 220, 220); lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Text = text; lbl.ZIndex = 36
        local p = Instance.new("Frame", btn); p.Size = UDim2.new(0, 32, 0, 18); p.Position = UDim2.new(1, -42, 0.5, -9); p.BackgroundColor3 = Color3.fromRGB(40, 40, 45); p.ZIndex = 36; Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
        local c = Instance.new("Frame", p); c.Size = UDim2.new(0, 14, 0, 14); c.Position = UDim2.new(0, 2, 0.5, -7); c.BackgroundColor3 = Color3.new(1,1,1); c.ZIndex = 37; Instance.new("UICorner", c).CornerRadius = UDim.new(1, 0)
        
        local grad = Instance.new("UIGradient", p); grad.Rotation = 45; table.insert(themedElements.AccentGradients, grad)
        local tRef = {State = config[configKey] == true, Frame = p}; table.insert(themedElements.Toggles, tRef)
        
        local function u() 
            local s = config[configKey] == true; tRef.State = s
            TweenService:Create(c, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = s and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play() 
            p.BackgroundColor3 = s and accentColor or Color3.fromRGB(40, 40, 45)
            if callback then pcall(callback, s) end
        end
        u(); table.insert(UIUpdaters, u)
        btn.MouseButton1Click:Connect(function() PlayClick(); config[configKey] = not config[configKey]; u(); SaveConfig() end)
    end

    local function CreateSlider(text, min, max, configKey, parent)
        local f = Instance.new("Frame", parent); f.Size = UDim2.new(1, -10, 0, 50); f.BackgroundTransparency = 1; f.ZIndex = 35; f.LayoutOrder = GetOrder(parent)
        local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 20); l.BackgroundTransparency = 1; l.Font = Enum.Font.GothamSemibold; l.TextColor3 = Color3.fromRGB(220, 220, 220); l.TextSize = 13; l.TextXAlignment = Enum.TextXAlignment.Left; l.Text = text; l.ZIndex = 36
        local vL = Instance.new("TextLabel", f); vL.Size = UDim2.new(1, 0, 0, 20); vL.BackgroundTransparency = 1; vL.Font = Enum.Font.GothamBold; vL.TextColor3 = accentColor; vL.TextSize = 13; vL.TextXAlignment = Enum.TextXAlignment.Right; vL.Text = tostring(math.floor(tonumber(config[configKey]) or min)); vL.ZIndex = 36; table.insert(themedElements.Stats, vL)
        local bg = Instance.new("Frame", f); bg.Size = UDim2.new(1, 0, 0, 8); bg.Position = UDim2.new(0, 0, 0, 32); bg.BackgroundColor3 = Color3.fromRGB(30, 30, 35); bg.ZIndex = 36; Instance.new("UICorner", bg).CornerRadius = UDim.new(1,0)
        
        local val = tonumber(config[configKey]) or min
        local startPct = math.clamp((val - min) / (max - min), 0, 1)
        
        local fill = Instance.new("Frame", bg); fill.Size = UDim2.new(startPct, 0, 1, 0); fill.BackgroundColor3 = accentColor; fill.ZIndex = 37; Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0); table.insert(themedElements.Toggles, {State = true, Frame = fill})
        local grad = Instance.new("UIGradient", fill); table.insert(themedElements.AccentGradients, grad)
        local knob = Instance.new("Frame", fill); knob.Size = UDim2.new(0, 14, 0, 14); knob.Position = UDim2.new(1, -7, 0.5, -7); knob.BackgroundColor3 = Color3.new(1,1,1); knob.ZIndex = 38; Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
        local b = Instance.new("TextButton", bg); b.Size = UDim2.new(1, 0, 1, 0); b.BackgroundTransparency = 1; b.Text = ""; b.ZIndex = 40
        
        b.MouseEnter:Connect(function() PlayHover() TweenService:Create(knob, TweenInfo.new(0.2), {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -9, 0.5, -9)}):Play() end)
        b.MouseLeave:Connect(function() TweenService:Create(knob, TweenInfo.new(0.2), {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -7, 0.5, -7)}):Play() end)

        local function u()
            local cVal = tonumber(config[configKey]) or min
            local pct = math.clamp((cVal - min) / (max - min), 0, 1)
            TweenService:Create(fill, TweenInfo.new(0.2), {Size = UDim2.new(pct, 0, 1, 0)}):Play()
            vL.Text = tostring(math.floor(cVal))
        end
        table.insert(UIUpdaters, u)

        local drag = false; b.MouseButton1Down:Connect(function() PlayClick(); drag = true end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false; SaveConfig() end end)
        RunService.RenderStepped:Connect(function() if drag and HubRunning then local pct = math.clamp((UserInputService:GetMouseLocation().X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1); local newVal = math.floor(min + (max-min)*pct); config[configKey] = newVal; fill.Size = UDim2.new(pct, 0, 1, 0); vL.Text = tostring(newVal); UpdateTheme() end end)
    end

    local function CreateKeybind(text, configKey, parent)
        local btn = Instance.new("TextButton", parent); btn.Size = UDim2.new(1, -10, 0, 38); btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25); btn.Text = ""; btn.ZIndex = 35; btn.LayoutOrder = GetOrder(parent)
        Instance.new("UICorner", btn); local stroke = Instance.new("UIStroke", btn); stroke.Color = Color3.fromRGB(35, 35, 40); ApplyHoverEffects(btn, stroke, Color3.fromRGB(20, 20, 25), Color3.fromRGB(28, 28, 33))
        
        local lbl = Instance.new("TextLabel", btn); lbl.Size = UDim2.new(1, -80, 1, 0); lbl.Position = UDim2.new(0, 12, 0, 0); lbl.BackgroundTransparency = 1; lbl.Font = Enum.Font.GothamSemibold; lbl.TextColor3 = Color3.fromRGB(220, 220, 220); lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Text = text; lbl.ZIndex = 36
        local val = Instance.new("TextLabel", btn); val.Size = UDim2.new(0, 75, 0, 22); val.Position = UDim2.new(1, -80, 0.5, -11); val.BackgroundColor3 = Color3.fromRGB(30, 30, 35); val.TextColor3 = accentColor; val.Font = Enum.Font.GothamBold; val.TextSize = 12; val.Text = tostring(config[configKey] or "None"); val.ZIndex = 37; Instance.new("UICorner", val); table.insert(themedElements.Stats, val)
        
        local function u() val.Text = tostring(config[configKey] or "None") end
        table.insert(UIUpdaters, u)

        local listening = false
        btn.MouseButton1Click:Connect(function() PlayClick(); listening = true; val.Text = "..." end)
        UserInputService.InputBegan:Connect(function(i) if listening and i.UserInputType == Enum.UserInputType.Keyboard then config[configKey] = i.KeyCode.Name; val.Text = i.KeyCode.Name; listening = false; SaveConfig() PlayClick() end end)
    end

    local function CreateButton(text, parent, callback)
        local btn = Instance.new("TextButton", parent); btn.Size = UDim2.new(1, -10, 0, 38); btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25); btn.ZIndex = 35; btn.LayoutOrder = GetOrder(parent)
        Instance.new("UICorner", btn); local stroke = Instance.new("UIStroke", btn); stroke.Color = Color3.fromRGB(35, 35, 40)
        btn.Text = text; btn.Font = Enum.Font.GothamBold; btn.TextSize = 13; btn.TextColor3 = Color3.new(1,1,1)
        ApplyHoverEffects(btn, stroke, Color3.fromRGB(20, 20, 25), Color3.fromRGB(28, 28, 33))
        btn.MouseButton1Click:Connect(function() PlayClick(); local oldC = btn.BackgroundColor3; btn.BackgroundColor3 = accentColor; TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = oldC}):Play(); if callback then pcall(callback) end end)
    end

    local function CreateDropdown(parent)
        local DropMain = Instance.new("Frame", parent); DropMain.Size = UDim2.new(1, -10, 0, 38); DropMain.BackgroundColor3 = Color3.fromRGB(20, 20, 25); DropMain.ZIndex = 35; DropMain.LayoutOrder = GetOrder(parent); DropMain.ClipsDescendants = true
        Instance.new("UICorner", DropMain); local stroke = Instance.new("UIStroke", DropMain); stroke.Color = Color3.fromRGB(35, 35, 40)
        
        local Display = Instance.new("TextLabel", DropMain); Display.Size = UDim2.new(1, -40, 0, 38); Display.Position = UDim2.new(0, 12, 0, 0); Display.BackgroundTransparency = 1; Display.Font = Enum.Font.GothamSemibold; Display.TextSize = 13; Display.TextColor3 = Color3.fromRGB(220, 220, 220); Display.TextXAlignment = Enum.TextXAlignment.Left; Display.Text = "Target: " .. (config.TargetName == "" and "Select Player" or config.TargetName); Display.ZIndex = 36
        local Arrow = Instance.new("TextLabel", DropMain); Arrow.Size = UDim2.new(0, 38, 0, 38); Arrow.Position = UDim2.new(1, -38, 0, 0); Arrow.BackgroundTransparency = 1; Arrow.Font = Enum.Font.GothamBold; Arrow.TextSize = 16; Arrow.TextColor3 = Color3.new(1,1,1); Arrow.Text = "v"; Arrow.ZIndex = 36

        local Btn = Instance.new("TextButton", DropMain); Btn.Size = UDim2.new(1, 0, 0, 38); Btn.BackgroundTransparency = 1; Btn.Text = ""; Btn.ZIndex = 45
        ApplyHoverEffects(Btn, stroke, Color3.fromRGB(20, 20, 25), Color3.fromRGB(28, 28, 33))

        local Content = Instance.new("Frame", DropMain); Content.Size = UDim2.new(1, 0, 1, -38); Content.Position = UDim2.new(0, 0, 0, 38); Content.BackgroundTransparency = 1; Content.Visible = false; Content.ZIndex = 36
        local SearchBox = Instance.new("TextBox", Content); SearchBox.Size = UDim2.new(1, -16, 0, 28); SearchBox.Position = UDim2.new(0, 8, 0, 5); SearchBox.BackgroundColor3 = Color3.fromRGB(15, 15, 18); SearchBox.Font = Enum.Font.Gotham; SearchBox.TextSize = 12; SearchBox.TextColor3 = Color3.new(1,1,1); SearchBox.PlaceholderText = "Search player..."; SearchBox.Text = ""; SearchBox.ZIndex = 37; Instance.new("UICorner", SearchBox); local searchStroke = Instance.new("UIStroke", SearchBox); searchStroke.Color = accentColor; table.insert(themedElements.Strokes, searchStroke)
        local Scroll = Instance.new("ScrollingFrame", Content); Scroll.Size = UDim2.new(1, -16, 1, -45); Scroll.Position = UDim2.new(0, 8, 0, 40); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 2; Scroll.ZIndex = 37; local ListL = Instance.new("UIListLayout", Scroll); ListL.Padding = UDim.new(0, 5)

        ListL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Scroll.CanvasSize = UDim2.new(0, 0, 0, ListL.AbsoluteContentSize.Y + 10) end)

        local function u() Display.Text = "Target: " .. (config.TargetName == "" and "Select Player" or tostring(config.TargetName)) end
        table.insert(UIUpdaters, u)

        local isOpen = false
        local function Refresh()
            for _, c in pairs(Scroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and (SearchBox.Text == "" or string.find(p.Name:lower(), SearchBox.Text:lower()) or string.find(p.DisplayName:lower(), SearchBox.Text:lower())) then
                    local item = Instance.new("Frame", Scroll); item.Size = UDim2.new(1, -8, 0, 32); item.BackgroundColor3 = Color3.fromRGB(25, 25, 30); item.ZIndex = 38; Instance.new("UICorner", item).CornerRadius = UDim.new(0, 4)
                    local img = Instance.new("ImageLabel", item); img.Size = UDim2.new(0, 24, 0, 24); img.Position = UDim2.new(0, 4, 0.5, -12); img.BackgroundColor3 = Color3.fromRGB(40, 40, 45); img.ZIndex = 39; Instance.new("UICorner", img).CornerRadius = UDim.new(1, 0)
                    task.spawn(function() pcall(function() img.Image = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end) end)
                    local pName = Instance.new("TextLabel", item); pName.Size = UDim2.new(1, -35, 1, 0); pName.Position = UDim2.new(0, 34, 0, 0); pName.BackgroundTransparency = 1; pName.Font = Enum.Font.GothamSemibold; pName.TextSize = 12; pName.TextColor3 = (config.TargetName == p.Name) and accentColor or Color3.fromRGB(200, 200, 200); pName.TextXAlignment = Enum.TextXAlignment.Left; pName.Text = p.DisplayName .. " (@" .. p.Name .. ")"; pName.ZIndex = 39

                    if config.TargetName == p.Name then table.insert(themedElements.Stats, pName) end

                    local clickBtn = Instance.new("TextButton", item); clickBtn.Size = UDim2.new(1, 0, 1, 0); clickBtn.BackgroundTransparency = 1; clickBtn.Text = ""; clickBtn.ZIndex = 40
                    ApplyHoverEffects(clickBtn, nil, Color3.fromRGB(25, 25, 30), Color3.fromRGB(35, 35, 40))

                    clickBtn.MouseButton1Click:Connect(function() PlayClick(); config.TargetName = p.Name; u(); isOpen = false; TweenService:Create(DropMain, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, -10, 0, 38)}):Play(); Content.Visible = false; TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 0}):Play(); SaveConfig() end)
                end
            end
        end

        Btn.MouseButton1Click:Connect(function() PlayClick(); isOpen = not isOpen; if isOpen then TweenService:Create(DropMain, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, -10, 0, 200)}):Play(); Content.Visible = true; TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 180}):Play(); Refresh() else TweenService:Create(DropMain, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, -10, 0, 38)}):Play(); Content.Visible = false; TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 0}):Play() end end)
        SearchBox:GetPropertyChangedSignal("Text"):Connect(Refresh)
    end

    -- [[ INJECT VISUALS ]] --
    CreateToggle("Enable Player ESP", "ESPEnabled", Pages.Visuals)
    CreateSlider("ESP Max Distance", 50, 100000, "MaxDistance", Pages.Visuals)
    CreateSlider("ESP Text Size", 8, 24, "TextSize", Pages.Visuals)
    CreateSlider("ESP Update Rate (Saves FPS)", 10, 144, "ESPRefreshRate", Pages.Visuals)

    local TargetDivider = Instance.new("Frame", Pages.Visuals); TargetDivider.Size = UDim2.new(1, -10, 0, 20); TargetDivider.BackgroundTransparency = 1; TargetDivider.ZIndex = 35; TargetDivider.LayoutOrder = GetOrder(Pages.Visuals)
    local TargetTitle = Instance.new("TextLabel", TargetDivider); TargetTitle.Size = UDim2.new(1, 0, 1, 0); TargetTitle.BackgroundTransparency = 1; TargetTitle.Font = Enum.Font.GothamBold; TargetTitle.TextSize = 13; TargetTitle.TextColor3 = accentColor; TargetTitle.TextXAlignment = Enum.TextXAlignment.Center; TargetTitle.Text = "— TARGET VISUALS —"; TargetTitle.ZIndex = 36; table.insert(themedElements.Stats, TargetTitle)

    CreateDropdown(Pages.Visuals)
    CreateToggle("Target ESP Override", "TargetESP", Pages.Visuals)

    -- [[ INJECT MISC ]] --
    CreateToggle("FPS Booster (Potato Map)", "FPSBooster", Pages.Misc, function(state)
        pcall(function()
            if state then Lighting.GlobalShadows = false for _, v in pairs(Lighting:GetChildren()) do if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Clouds") then v.Enabled = false end end
            else Lighting.GlobalShadows = true for _, v in pairs(Lighting:GetChildren()) do if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Clouds") then v.Enabled = true end end end
        end)
    end)
    CreateToggle("Fullbright / Night Vision", "Fullbright", Pages.Misc)
    CreateToggle("Proximity Danger Alert", "ProximityAlert", Pages.Misc)
    CreateToggle("Show Display Names", "ShowDisplay", Pages.Misc)
    CreateToggle("Show Usernames", "ShowUser", Pages.Misc)
    CreateButton("Execute Lunar Hub", Pages.Misc, function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Mangnex/Lunar-Hub/refs/heads/main/FreeLoader.lua"))() end)

    -- [[ INJECT SETTINGS ]] --
    CreateKeybind("Menu Toggle Key", "MenuKey", Pages.Settings)
    CreateToggle("Show Skeet Watermark", "ShowStats", Pages.Settings, function(state) local frame = ScreenGui:FindFirstChild("WatermarkFrame"); if frame then frame.Visible = state end end)
    
    local ThemeDivider = Instance.new("Frame", Pages.Settings); ThemeDivider.Size = UDim2.new(1, -10, 0, 20); ThemeDivider.BackgroundTransparency = 1; ThemeDivider.ZIndex = 35; ThemeDivider.LayoutOrder = GetOrder(Pages.Settings)
    local ThemeTitle = Instance.new("TextLabel", ThemeDivider); ThemeTitle.Size = UDim2.new(1, 0, 1, 0); ThemeTitle.BackgroundTransparency = 1; ThemeTitle.Font = Enum.Font.GothamBold; ThemeTitle.TextSize = 13; ThemeTitle.TextColor3 = accentColor; ThemeTitle.TextXAlignment = Enum.TextXAlignment.Center; ThemeTitle.Text = "— MENU & ESP COLORS —"; ThemeTitle.ZIndex = 36; table.insert(themedElements.Stats, ThemeTitle)

    CreateToggle("Kick on Staff Join", "KickOnAdmin", Pages.Settings, function(state) if state then for _, player in pairs(Players:GetPlayers()) do CheckForAdmin(player) end end end)

    CreateToggle("Rainbow Theme Mode", "RainbowTheme", Pages.Settings)
    CreateSlider("Menu Hue", 0, 360, "Hue", Pages.Settings)
    CreateSlider("Menu Saturation (0 = White/Gray)", 0, 100, "UISat", Pages.Settings)
    CreateSlider("Menu Brightness (0 = Black)", 0, 100, "UIVal", Pages.Settings)
    
    CreateSlider("ESP Hue", 0, 360, "HighHue", Pages.Settings)
    CreateSlider("ESP Saturation", 0, 100, "ESPSat", Pages.Settings)
    CreateSlider("ESP Brightness", 0, 100, "ESPVal", Pages.Settings)

    local function PerformKillswitch()
        HubRunning = false
        if StatsLoopConnection then StatsLoopConnection:Disconnect() end
        if ESPLoopConnection then ESPLoopConnection:Disconnect() end
        pcall(function() ESPFolder:Destroy() end)
        pcall(function() HighFolder:Destroy() end)
        ScreenGui:Destroy()
    end

    local ResetBtn = Instance.new("TextButton", Pages.Settings); ResetBtn.Size = UDim2.new(1, -10, 0, 35); ResetBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35); ResetBtn.ZIndex = 35; ResetBtn.LayoutOrder = GetOrder(Pages.Settings); ResetBtn.Text = "Reset Config"; ResetBtn.TextColor3 = Color3.new(1,1,1); ResetBtn.Font = Enum.Font.GothamBold; ResetBtn.TextSize = 13; Instance.new("UICorner", ResetBtn); local rs = Instance.new("UIStroke", ResetBtn); rs.Color = Color3.fromRGB(45, 45, 50); ApplyHoverEffects(ResetBtn, rs, Color3.fromRGB(30, 30, 35), Color3.fromRGB(40, 40, 45))
    ResetBtn.MouseButton1Click:Connect(function() 
        PlayClick()
        pcall(function() delfile("NaxHub_Config.json") end) 
        for k, v in pairs(defaultCfg) do config[k] = v end
        UpdateTheme(); for _, uFunc in ipairs(UIUpdaters) do pcall(uFunc) end; SaveConfig()
        local oldText = ResetBtn.Text; ResetBtn.Text = "Config Reset!"
        task.delay(1.5, function() ResetBtn.Text = oldText end)
    end)

    local DestroyBtn = Instance.new("TextButton", Pages.Settings); DestroyBtn.Size = UDim2.new(0, 100, 0, 25); DestroyBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 28); DestroyBtn.ZIndex = 35; DestroyBtn.LayoutOrder = GetOrder(Pages.Settings); DestroyBtn.Text = "Destroy Hub"; DestroyBtn.TextColor3 = Color3.fromRGB(150, 150, 150); DestroyBtn.Font = Enum.Font.GothamBold; DestroyBtn.TextSize = 12; Instance.new("UICorner", DestroyBtn); ApplyHoverEffects(DestroyBtn, nil, Color3.fromRGB(25, 25, 28), Color3.fromRGB(40, 30, 30))
    DestroyBtn.MouseButton1Click:Connect(function() PlayClick(); PerformKillswitch() end)

    -- [[ 💧 PREMIUM SKEET WATERMARK ]] --
    local WatermarkFrame = Instance.new("Frame", ScreenGui)
    WatermarkFrame.Name = "WatermarkFrame"
    WatermarkFrame.Size = UDim2.new(0, 0, 0, 26); WatermarkFrame.AutomaticSize = Enum.AutomaticSize.X
    WatermarkFrame.Position = UDim2.new(0, 20, 0, 20)
    WatermarkFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20); WatermarkFrame.BackgroundTransparency = 0.2; WatermarkFrame.ZIndex = 100; WatermarkFrame.Visible = config.ShowStats; Instance.new("UICorner", WatermarkFrame).CornerRadius = UDim.new(0, 4)
    
    local WMNoise = Instance.new("ImageLabel", WatermarkFrame)
    WMNoise.Size = UDim2.new(1, 0, 1, 0); WMNoise.BackgroundTransparency = 1; WMNoise.Image = "rbxassetid://13807212005"; WMNoise.ImageTransparency = 0.9; WMNoise.ScaleType = Enum.ScaleType.Tile; WMNoise.TileSize = UDim2.new(0, 128, 0, 128); WMNoise.ZIndex = 101; Instance.new("UICorner", WMNoise).CornerRadius = UDim.new(0, 4)

    local WatermarkStroke = Instance.new("UIStroke", WatermarkFrame); WatermarkStroke.Thickness = 1.5; WatermarkStroke.Color = accentColor; table.insert(themedElements.Strokes, WatermarkStroke)
    
    local WatermarkLabel = Instance.new("TextLabel", WatermarkFrame)
    WatermarkLabel.Size = UDim2.new(1, -16, 1, 0); WatermarkLabel.Position = UDim2.new(0, 8, 0, 0)
    WatermarkLabel.BackgroundTransparency = 1; WatermarkLabel.Font = Enum.Font.GothamSemibold; WatermarkLabel.TextSize = 12
    WatermarkLabel.TextColor3 = Color3.new(1, 1, 1); WatermarkLabel.RichText = true; WatermarkLabel.ZIndex = 102

    -- Make Watermark Draggable
    local wDragging, wDragStart, wStartPos
    WatermarkFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then wDragging = true; wDragStart = i.Position; wStartPos = WatermarkFrame.Position end end)
    UserInputService.InputChanged:Connect(function(i) if wDragging and i.UserInputType == Enum.UserInputType.MouseMovement then local d = i.Position - wDragStart; WatermarkFrame.Position = UDim2.new(wStartPos.X.Scale, wStartPos.X.Offset + d.X, wStartPos.Y.Scale, wStartPos.Y.Offset + d.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then wDragging = false end end)

    local fpsCount = 0
    StatsLoopConnection = RunService.RenderStepped:Connect(function() if HubRunning then fpsCount = fpsCount + 1 end end)
    
    task.spawn(function()
        while HubRunning do
            task.wait(1)
            if config.ShowStats then
                local currentFps = fpsCount; fpsCount = 0; local currentPing = 0
                pcall(function() currentPing = math.floor(LocalPlayer:GetNetworkPing() * 1000) end)
                if currentPing == 0 then pcall(function() currentPing = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) end) end
                
                local hexColor = accentColor:ToHex()
                WatermarkLabel.Text = string.format("<font color='#%s'><b>Nax</b></font> Premium <font color='#666'>|</font> FPS: %d <font color='#666'>|</font> Ping: %dms <font color='#666'>|</font> Players: %d", hexColor, currentFps, currentPing, #Players:GetPlayers())
            else fpsCount = 0 end
        end
    end)

    task.spawn(function() while HubRunning and task.wait(1) do if config.Fullbright then pcall(function() Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.FogEnd = 100000; Lighting.GlobalShadows = false end) end end end)

    -- [[ LAG-PROOF O(1) ESP LOOP ]] --
    local lastESPUpdate = 0
    ESPLoopConnection = RunService.RenderStepped:Connect(function()
        if not HubRunning then return end
        local now = tick()
        if now - lastESPUpdate < (1 / (tonumber(config.ESPRefreshRate) or 60)) then return end
        lastESPUpdate = now

        if not (config.ESPEnabled or config.TargetESP or config.ProximityAlert) then 
            for _, v in pairs(espCache) do v:Destroy() end
            for _, v in pairs(highCache) do v:Destroy() end
            table.clear(espCache); table.clear(highCache)
            if isAlerting then isAlerting = false; TweenService:Create(ProxVignette, TweenInfo.new(0.5), {ImageTransparency = 1}):Play(); TweenService:Create(ProxText, TweenInfo.new(0.5), {TextTransparency = 1, TextStrokeTransparency = 1}):Play(); ProxSound:Stop() end
            return 
        end
        
        local camPos = workspace.CurrentCamera.CFrame.Position
        local validPlayers = {}
        local playersList = Players:GetPlayers()

        for i = 1, #playersList do
            local Player = playersList[i]
            if Player ~= LocalPlayer then
                local char = Player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then validPlayers[#validPlayers + 1] = {Player = Player, Char = char, Root = root, Dist = (camPos - root.Position).Magnitude} end
            end
        end

        table.sort(validPlayers, function(a, b) return a.Dist < b.Dist end)

        if config.ProximityAlert and #validPlayers > 0 then
            local closest = validPlayers[1]
            if closest.Dist <= 75 then
                if not isAlerting then
                    isAlerting = true
                    TweenService:Create(ProxVignette, TweenInfo.new(0.5), {ImageTransparency = 0.4}):Play()
                    TweenService:Create(ProxText, TweenInfo.new(0.5), {TextTransparency = 0, TextStrokeTransparency = 0}):Play()
                    ProxSound:Play()
                end
                ProxText.Text = "⚠️ ENEMY NEARBY: " .. closest.Player.DisplayName .. " (" .. math.floor(closest.Dist) .. "m) ⚠️"
            else
                if isAlerting then
                    isAlerting = false
                    TweenService:Create(ProxVignette, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
                    TweenService:Create(ProxText, TweenInfo.new(0.5), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
                    ProxSound:Stop()
                end
            end
        else
            if isAlerting then isAlerting = false; TweenService:Create(ProxVignette, TweenInfo.new(0.5), {ImageTransparency = 1}):Play(); TweenService:Create(ProxText, TweenInfo.new(0.5), {TextTransparency = 1, TextStrokeTransparency = 1}):Play(); ProxSound:Stop() end
        end

        local currentFramePlayers = {}
        local activeHighCount = 0
        local activeLabelCount = 0
        local safeMaxDist = tonumber(config.MaxDistance) or 100000

        for i = 1, #validPlayers do
            local pData = validPlayers[i]
            local Player = pData.Player; local dist = pData.Dist; local pName = Player.Name
            local isT = (pName == config.TargetName); local showTarget = (isT and config.TargetESP); local showNormal = (config.ESPEnabled and dist <= safeMaxDist)

            if showNormal or showTarget then
                currentFramePlayers[pName] = true
                local allowLabel = showTarget or (showNormal and activeLabelCount < 35)
                
                if allowLabel then
                    activeLabelCount = activeLabelCount + 1
                    local lns = showTarget and "<font color='#FF0000'>TARGET -</font> " or ""
                    if config.ShowDisplay then lns = lns .. Player.DisplayName .. " " end
                    if config.ShowUser then lns = lns .. "@" .. pName .. " " end
                    lns = lns .. "["..math.floor(dist).."m]"

                    local textColor = showTarget and Color3.new(1,0,0) or Color3.new(1,1,1)

                    local tag = espCache[pName]
                    if not tag then
                        tag = Instance.new("BillboardGui", ESPFolder); tag.Name = pName; tag.AlwaysOnTop = true; tag.Size = UDim2.new(0, 200, 0, 50); tag.StudsOffset = Vector3.new(0, 3, 0)
                        local lbl = Instance.new("TextLabel", tag); lbl.Name = "L"; lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1; lbl.Font = Enum.Font.GothamBold; lbl.RichText = true
                        espCache[pName] = tag
                    end
                    tag.Adornee = pData.Root; tag.L.Text = lns; tag.L.TextSize = tonumber(config.TextSize) or 14; tag.L.TextColor3 = textColor
                else
                    if espCache[pName] then espCache[pName]:Destroy(); espCache[pName] = nil end
                end

                local allowHigh = showTarget or (showNormal and activeHighCount < 25)
                if allowHigh then
                    activeHighCount = activeHighCount + 1
                    local high = highCache[pName]
                    if not high then high = Instance.new("Highlight", HighFolder); high.Name = pName; highCache[pName] = high end
                    high.Adornee = pData.Char
                    if showTarget then high.FillColor = Color3.new(1,0,0); high.OutlineColor = Color3.new(1,0,0); high.FillTransparency = 0.2
                    else high.FillColor = highlightColor; high.OutlineColor = highlightColor; high.FillTransparency = 0.5 end
                else
                    if highCache[pName] then highCache[pName]:Destroy(); highCache[pName] = nil end
                end
            end
        end

        for pName, tag in pairs(espCache) do if not currentFramePlayers[pName] then tag:Destroy(); espCache[pName] = nil end end
        for pName, high in pairs(highCache) do if not currentFramePlayers[pName] then high:Destroy(); highCache[pName] = nil end end
    end)

    UpdateTheme()
    
    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = i.Position; startPos = MainFrame.Position end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local d = i.Position - dragStart; MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputBegan:Connect(function(i, gp) if not gp and i.KeyCode and i.KeyCode.Name == config.MenuKey then PlayClick() MainFrame.Visible = not MainFrame.Visible end end)
end)

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
    local MainLoopConnection, StatsLoopConnection, ESPLoopConnection
    local espCache = {}
    local highCache = {}

    getgenv().Nax_Cleanup = function()
        HubRunning = false
        if MainLoopConnection then MainLoopConnection:Disconnect() end
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

    -- [[ AUDIO ASSETS ]] --
    local HoverSound = Instance.new("Sound", ScreenGui); HoverSound.SoundId = "rbxassetid://6895056282"; HoverSound.Volume = 0.2
    local ClickSound = Instance.new("Sound", ScreenGui); ClickSound.SoundId = "rbxassetid://6895058925"; ClickSound.Volume = 0.4
    local function PlayHover() pcall(function() HoverSound:Play() end) end
    local function PlayClick() pcall(function() ClickSound:Play() end) end

    -- [[ CONFIG SYSTEM ]] --
    local defaultCfg = { 
        Hue = 234, UISat = 70, UIVal = 100, RainbowTheme = false, 
        HighHue = 210, ESPSat = 70, ESPVal = 100, 
        MaxDistance = 100000, ESPRefreshRate = 60, TextSize = 14, MenuKey = "LeftControl", 
        ESPEnabled = false, ShowDisplay = true, ShowUser = true, 
        ShowStats = true, TargetName = "Select Player", TargetESP = false, 
        FPSBooster = false, KickOnAdmin = false
    }
    local config = table.clone(defaultCfg)
    local function SaveConfig() pcall(function() writefile("NaxHub_Config.json", HttpService:JSONEncode(config)) end) end
    pcall(function() if isfile("NaxHub_Config.json") then local d = HttpService:JSONDecode(readfile("NaxHub_Config.json")) for i,v in pairs(d) do if config[i] ~= nil then config[i] = v end end end end)

    local accentColor = Color3.fromHSV(config.Hue / 360, config.UISat / 100, config.UIVal / 100)
    local highlightColor = Color3.fromHSV(config.HighHue / 360, config.ESPSat / 100, config.ESPVal / 100)
    local UIUpdaters = {}

    -- [[ THEME ENGINE ]] --
    local themedElements = {Strokes = {}, Toggles = {}, Watermarks = {}, Branding = {}, Gradients = {}, Stats = {}, AccentGradients = {}, Tabs = {}}
    local function UpdateTheme()
        local h, s, v = (tonumber(config.Hue) or 234) / 360, (tonumber(config.UISat) or 70) / 100, (tonumber(config.UIVal) or 100) / 100
        accentColor = Color3.fromHSV(h, s, v)
        local darkAccentColor = Color3.fromHSV(h, s, v > 0.5 and math.max(0, v - 0.4) or math.min(1, v + 0.3))
        local dimAccentColor = Color3.fromHSV(h, s, v > 0.5 and math.max(0, v - 0.8) or math.min(1, v + 0.2))
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

    -- [[ MAIN HUB ]] --
    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 500, 0, 360); MainFrame.Position = UDim2.new(0.5, -250, 0.5, -180)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20); MainFrame.BackgroundTransparency = 0.15
    MainFrame.ZIndex = 10; MainFrame.Visible = true; Instance.new("UICorner", MainFrame)
    
    local NoiseOverlay = Instance.new("ImageLabel", MainFrame)
    NoiseOverlay.Size = UDim2.new(1, 0, 1, 0); NoiseOverlay.BackgroundTransparency = 1
    NoiseOverlay.Image = "rbxassetid://13807212005"; NoiseOverlay.ImageTransparency = 0.9
    NoiseOverlay.ScaleType = Enum.ScaleType.Tile; NoiseOverlay.TileSize = UDim2.new(0, 128, 0, 128)
    NoiseOverlay.ZIndex = 11; Instance.new("UICorner", NoiseOverlay)

    local MainStroke = Instance.new("UIStroke", MainFrame); MainStroke.Thickness = 2.5; MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local StrokeGradient = Instance.new("UIGradient", MainStroke); table.insert(themedElements.Gradients, StrokeGradient)
    StrokeGradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.1, 1), NumberSequenceKeypoint.new(0.25, 0), NumberSequenceKeypoint.new(0.4, 1), NumberSequenceKeypoint.new(0.6, 1), NumberSequenceKeypoint.new(0.75, 0), NumberSequenceKeypoint.new(0.9, 1), NumberSequenceKeypoint.new(1, 1)})

    local WatermarkClipFrame = Instance.new("Frame", MainFrame)
    WatermarkClipFrame.Size = UDim2.new(1, 0, 1, 0); WatermarkClipFrame.BackgroundTransparency = 1; WatermarkClipFrame.ClipsDescendants = true; Instance.new("UICorner", WatermarkClipFrame)

    local WatermarkContainer = Instance.new("Frame", WatermarkClipFrame); WatermarkContainer.Size = UDim2.new(1.5, 0, 1.5, 0); WatermarkContainer.Position = UDim2.new(-0.25, 0, -0.25, 0); WatermarkContainer.BackgroundTransparency = 1; WatermarkContainer.ZIndex = 12
    for x = 0, 8 do for y = 0, 8 do
        local txt = Instance.new("TextLabel", WatermarkContainer); txt.Text = "NAX"; txt.Font = Enum.Font.GothamBold; txt.TextSize = 25; txt.TextColor3 = accentColor; txt.TextTransparency = 0.95; txt.BackgroundTransparency = 1; txt.Position = UDim2.new(0, x * 85, 0, y * 65); txt.Rotation = -25; txt.ZIndex = 12; table.insert(themedElements.Watermarks, txt)
    end end

    local Sidebar = Instance.new("Frame", MainFrame); Sidebar.Size = UDim2.new(0, 130, 1, 0); Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 14); Sidebar.BackgroundTransparency = 0.3; Sidebar.ZIndex = 20; Instance.new("UICorner", Sidebar)
    local ProfileImage = Instance.new("ImageLabel", Sidebar); ProfileImage.Size = UDim2.new(0, 55, 0, 55); ProfileImage.Position = UDim2.new(0.5, -27, 0, 20); ProfileImage.ZIndex = 25; Instance.new("UICorner", ProfileImage).CornerRadius = UDim.new(1, 0)
    local ProfStroke = Instance.new("UIStroke", ProfileImage); ProfStroke.Thickness = 2; ProfStroke.Color = accentColor; table.insert(themedElements.Strokes, ProfStroke)
    pcall(function() ProfileImage.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end)
    local UserLabel = Instance.new("TextLabel", Sidebar); UserLabel.Size = UDim2.new(1, 0, 0, 20); UserLabel.Position = UDim2.new(0, 0, 0, 80); UserLabel.BackgroundTransparency = 1; UserLabel.ZIndex = 25; UserLabel.Font = Enum.Font.GothamBold; UserLabel.TextSize = 11; UserLabel.TextColor3 = Color3.fromRGB(200, 200, 200); UserLabel.Text = "@" .. LocalPlayer.Name

    local PlayerCountLabel = Instance.new("TextLabel", Sidebar); PlayerCountLabel.Size = UDim2.new(1, -10, 0, 25); PlayerCountLabel.Position = UDim2.new(0, 8, 1, -25); PlayerCountLabel.BackgroundTransparency = 1; PlayerCountLabel.ZIndex = 25; PlayerCountLabel.Font = Enum.Font.GothamMedium; PlayerCountLabel.TextSize = 12; PlayerCountLabel.TextColor3 = Color3.fromRGB(180, 180, 180); PlayerCountLabel.RichText = true; PlayerCountLabel.TextXAlignment = Enum.TextXAlignment.Left

    local Branding = Instance.new("Frame", MainFrame); Branding.Size = UDim2.new(0, 200, 0, 40); Branding.Position = UDim2.new(0, 140, 0, 15); Branding.BackgroundTransparency = 1; Branding.ZIndex = 30
    local NaxText = Instance.new("TextLabel", Branding); NaxText.Size = UDim2.new(0, 40, 1, 0); NaxText.BackgroundTransparency = 1; NaxText.Font = Enum.Font.GothamBold; NaxText.TextSize = 24; NaxText.Text = "Nax"; NaxText.Rotation = -8; NaxText.ZIndex = 31; table.insert(themedElements.Branding, NaxText)
    local HubText = Instance.new("TextLabel", Branding); HubText.Size = UDim2.new(1, -45, 1, 0); HubText.Position = UDim2.new(0, 45, 0, 0); HubText.BackgroundTransparency = 1; HubText.Font = Enum.Font.GothamBold; HubText.TextSize = 20; HubText.TextColor3 = Color3.new(1, 1, 1); HubText.Text = "Hub Premium"; HubText.ZIndex = 31; HubText.TextXAlignment = Enum.TextXAlignment.Left

    -- [[ SINGLE OPTIMIZED UI ANIMATION LOOP ]] --
    MainLoopConnection = RunService.RenderStepped:Connect(function()
        if not HubRunning then return end
        local t = os.clock()
        
        -- Rainbow Theme
        if config.RainbowTheme then 
            config.Hue = (t * 50) % 360 
            UpdateTheme() 
            for _, uFunc in ipairs(UIUpdaters) do pcall(uFunc) end 
        end
        
        -- UI Element Animations
        if MainFrame.Visible then
            StrokeGradient.Rotation = (t * 50) % 360
            
            local wmOffset = (t * 15) % 85
            WatermarkContainer.Position = UDim2.new(-0.25, wmOffset, -0.25, wmOffset * 0.75)
            
            NaxText.Rotation = -8 + (math.sin(t * 3) * 6)
            NaxText.TextSize = 24 * (1 + (math.cos(t * 1.5) * 0.06))
        end
    end)

    -- [[ PAGE LOGIC ]] --
    local layoutOrders = {}
    local function GetOrder(parent) layoutOrders[parent] = (layoutOrders[parent] or 0) + 1; return layoutOrders[parent] end

    local PageContainer = Instance.new("Frame", MainFrame); PageContainer.Size = UDim2.new(1, -150, 1, -110); PageContainer.Position = UDim2.new(0, 140, 0, 65); PageContainer.BackgroundTransparency = 1; PageContainer.ZIndex = 30; PageContainer.ClipsDescendants = true
    local Pages = {Visuals = Instance.new("ScrollingFrame", PageContainer), Misc = Instance.new("ScrollingFrame", PageContainer), Settings = Instance.new("ScrollingFrame", PageContainer)}
    
    for _, p in pairs(Pages) do 
        p.Size = UDim2.new(1,0,1,0); p.BackgroundTransparency = 1; p.ZIndex = 31; p.Visible = false; p.ScrollBarThickness = 0; p.AutomaticCanvasSize = Enum.AutomaticSize.Y
        local ll = Instance.new("UIListLayout", p); ll.Padding = UDim.new(0, 10); ll.SortOrder = Enum.SortOrder.LayoutOrder
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

        btn.MouseButton1Click:Connect(function() 
            PlayClick()
            for n, p in pairs(Pages) do 
                if n == text and not p.Visible then
                    p.Visible = true; p.Position = UDim2.new(0, 0, 0, 15)
                    TweenService:Create(p, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
                elseif n ~= text then p.Visible = false end
            end 
            for _, t in pairs(themedElements.Tabs) do t.IsActive = (t.Button == btn); TweenService:Create(t.Button, TweenInfo.new(0.2), {TextColor3 = t.IsActive and accentColor or Color3.fromRGB(120, 120, 120)}):Play() end 
        end)
    end
    CreateTab("Visuals", 120); CreateTab("Misc", 155); CreateTab("Settings", 190)

    -- [[ UI COMPONENTS ]] --
    local function CreateToggle(text, configKey, parent, callback)
        local btn = Instance.new("TextButton", parent); btn.Size = UDim2.new(1, -10, 0, 38); btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25); btn.Text = ""; btn.ZIndex = 35; btn.LayoutOrder = GetOrder(parent)
        Instance.new("UICorner", btn); local stroke = Instance.new("UIStroke", btn); stroke.Color = Color3.fromRGB(35, 35, 40)
        ApplyHoverEffects(btn, stroke, Color3.fromRGB(20, 20, 25), Color3.fromRGB(28, 28, 33))
        
        local lbl = Instance.new("TextLabel", btn); lbl.Size = UDim2.new(1, -50, 1, 0); lbl.Position = UDim2.new(0, 12, 0, 0); lbl.BackgroundTransparency = 1; lbl.Font = Enum.Font.GothamSemibold; lbl.TextColor3 = Color3.fromRGB(220, 220, 220); lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Text = text; lbl.ZIndex = 36
        local p = Instance.new("Frame", btn); p.Size = UDim2.new(0, 32, 0, 18); p.Position = UDim2.new(1, -42, 0.5, -9); p.BackgroundColor3 = Color3.fromRGB(40, 40, 45); p.ZIndex = 36; Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
        local c = Instance.new("Frame", p); c.Size = UDim2.new(0, 14, 0, 14); c.Position = UDim2.new(0, 2, 0.5, -7); c.BackgroundColor3 = Color3.new(1,1,1); c.ZIndex = 37; Instance.new("UICorner", c).CornerRadius = UDim.new(1, 0)
        
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
        local knob = Instance.new("Frame", fill); knob.Size = UDim2.new(0, 14, 0, 14); knob.Position = UDim2.new(1, -7, 0.5, -7); knob.BackgroundColor3 = Color3.new(1,1,1); knob.ZIndex = 38; Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
        local b = Instance.new("TextButton", bg); b.Size = UDim2.new(1, 0, 1, 0); b.BackgroundTransparency = 1; b.Text = ""; b.ZIndex = 40

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

    local function CreateButton(text, parent, callback)
        local btn = Instance.new("TextButton", parent); btn.Size = UDim2.new(1, -10, 0, 38); btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25); btn.ZIndex = 35; btn.LayoutOrder = GetOrder(parent)
        Instance.new("UICorner", btn); local stroke = Instance.new("UIStroke", btn); stroke.Color = Color3.fromRGB(35, 35, 40)
        btn.Text = text; btn.Font = Enum.Font.GothamBold; btn.TextSize = 13; btn.TextColor3 = Color3.new(1,1,1)
        ApplyHoverEffects(btn, stroke, Color3.fromRGB(20, 20, 25), Color3.fromRGB(28, 28, 33))
        btn.MouseButton1Click:Connect(function() PlayClick(); local oldC = btn.BackgroundColor3; btn.BackgroundColor3 = accentColor; TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = oldC}):Play(); if callback then pcall(callback) end end)
    end

    -- [[ INJECT VISUALS ]] --
    CreateToggle("Enable Player ESP", "ESPEnabled", Pages.Visuals)
    CreateSlider("ESP Max Distance", 50, 100000, "MaxDistance", Pages.Visuals)
    CreateSlider("ESP Text Size", 8, 24, "TextSize", Pages.Visuals)
    CreateSlider("ESP Update Rate (Saves FPS)", 10, 144, "ESPRefreshRate", Pages.Visuals)

    -- [[ INJECT MISC ]] --
    CreateToggle("Extreme FPS Booster (Nuke Maps)", "FPSBooster", Pages.Misc, function(state)
        pcall(function()
            if state then 
                Lighting.GlobalShadows = false 
                for _, v in pairs(Lighting:GetDescendants()) do 
                    if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Clouds") then v.Enabled = false end 
                end
                
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.Material = Enum.Material.SmoothPlastic
                        v.CastShadow = false
                    end
                    if v:IsA("Texture") or v:IsA("Decal") then
                        v.Transparency = 1
                    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                        v.Enabled = false
                    elseif v:IsA("MeshPart") then
                        pcall(function() v.TextureID = "" end)
                    elseif v:IsA("SpecialMesh") then
                        pcall(function() v.TextureId = "" end)
                    end
                end
                
                workspace.Terrain.WaterWaveSize = 0
                workspace.Terrain.WaterWaveSpeed = 0
                workspace.Terrain.WaterReflectance = 0
                workspace.Terrain.WaterTransparency = 0
            end
        end)
    end)
    CreateToggle("Show Display Names", "ShowDisplay", Pages.Misc)
    CreateToggle("Show Usernames", "ShowUser", Pages.Misc)
    CreateButton("Execute Lunar Hub", Pages.Misc, function() 
        pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Mangnex/Lunar-Hub/refs/heads/main/FreeLoader.lua"))() end) 
    end)

    -- [[ INJECT SETTINGS ]] --
    CreateToggle("Show FPS & Ping Watermark", "ShowStats", Pages.Settings, function(state) local frame = ScreenGui:FindFirstChild("WatermarkFrame"); if frame then frame.Visible = state end end)
    CreateToggle("Rainbow Theme Mode", "RainbowTheme", Pages.Settings)
    CreateSlider("Menu Hue", 0, 360, "Hue", Pages.Settings)
    CreateSlider("Menu Saturation (0 = White)", 0, 100, "UISat", Pages.Settings)
    CreateSlider("Menu Brightness (0 = Black)", 0, 100, "UIVal", Pages.Settings)
    CreateSlider("ESP Hue", 0, 360, "HighHue", Pages.Settings)
    CreateSlider("ESP Saturation", 0, 100, "ESPSat", Pages.Settings)
    CreateSlider("ESP Brightness", 0, 100, "ESPVal", Pages.Settings)

    -- [[ 💧 PREMIUM WATERMARK (FPS / PING) ]] --
    local WatermarkFrame = Instance.new("Frame", ScreenGui)
    WatermarkFrame.Name = "WatermarkFrame"
    WatermarkFrame.Size = UDim2.new(0, 0, 0, 26); WatermarkFrame.AutomaticSize = Enum.AutomaticSize.X
    WatermarkFrame.Position = UDim2.new(0, 20, 0, 20)
    WatermarkFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20); WatermarkFrame.BackgroundTransparency = 0.2; WatermarkFrame.ZIndex = 100; WatermarkFrame.Visible = config.ShowStats; Instance.new("UICorner", WatermarkFrame).CornerRadius = UDim.new(0, 4)
    
    local WatermarkStroke = Instance.new("UIStroke", WatermarkFrame); WatermarkStroke.Thickness = 1.5; WatermarkStroke.Color = accentColor; table.insert(themedElements.Strokes, WatermarkStroke)
    
    local WatermarkLabel = Instance.new("TextLabel", WatermarkFrame)
    WatermarkLabel.Size = UDim2.new(1, -16, 1, 0); WatermarkLabel.Position = UDim2.new(0, 8, 0, 0)
    WatermarkLabel.BackgroundTransparency = 1; WatermarkLabel.Font = Enum.Font.GothamSemibold; WatermarkLabel.TextSize = 12
    WatermarkLabel.TextColor3 = Color3.new(1, 1, 1); WatermarkLabel.RichText = true; WatermarkLabel.ZIndex = 102

    local fpsCount = 0
    local lastTick = tick()
    StatsLoopConnection = RunService.RenderStepped:Connect(function() 
        if HubRunning then 
            fpsCount = fpsCount + 1 
            if tick() - lastTick >= 1 then
                if config.ShowStats then
                    local currentFps = fpsCount
                    local currentPing = 0
                    pcall(function() currentPing = math.floor(LocalPlayer:GetNetworkPing() * 1000) end)
                    if currentPing == 0 then pcall(function() currentPing = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) end) end
                    
                    local hexColor = accentColor:ToHex()
                    WatermarkLabel.Text = string.format("<font color='#%s'><b>Nax</b></font> Premium <font color='#666'>|</font> FPS: %d <font color='#666'>|</font> Ping: %dms <font color='#666'>|</font> Players: %d", hexColor, currentFps, currentPing, #Players:GetPlayers())
                end
                if PlayerCountLabel then
                    PlayerCountLabel.Text = string.format("<font color='#00FF00'>●</font> %d Players", #Players:GetPlayers())
                end
                fpsCount = 0
                lastTick = tick()
            end
        end 
    end)

    -- [[ LAG-PROOF INSTANCE-POOLING ESP LOOP ]] --
    local lastESPUpdate = 0
    ESPLoopConnection = RunService.RenderStepped:Connect(function()
        if not HubRunning then return end
        local now = tick()
        if now - lastESPUpdate < (1 / (tonumber(config.ESPRefreshRate) or 60)) then return end
        lastESPUpdate = now

        if not config.ESPEnabled then 
            for _, tag in pairs(espCache) do tag.Enabled = false end
            for _, high in pairs(highCache) do high.Enabled = false end
            return 
        end
        
        local camPos = workspace.CurrentCamera.CFrame.Position
        local safeMaxDist = tonumber(config.MaxDistance) or 100000
        local currentFramePlayers = {}

        for _, Player in pairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer then
                local char = Player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local pName = Player.Name
                
                if root then
                    local dist = (camPos - root.Position).Magnitude
                    
                    if dist <= safeMaxDist then
                        currentFramePlayers[pName] = true
                        
                        -- Pooling BillboardGui
                        local tag = espCache[pName]
                        if not tag then
                            tag = Instance.new("BillboardGui", ESPFolder); tag.Name = pName; tag.AlwaysOnTop = true; tag.Size = UDim2.new(0, 200, 0, 50); tag.StudsOffset = Vector3.new(0, 3, 0)
                            local lbl = Instance.new("TextLabel", tag); lbl.Name = "L"; lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1; lbl.Font = Enum.Font.GothamBold; lbl.RichText = true
                            espCache[pName] = tag
                        end
                        
                        local lns = ""
                        if config.ShowDisplay then lns = lns .. Player.DisplayName .. " " end
                        if config.ShowUser then lns = lns .. "@" .. pName .. " " end
                        lns = lns .. "["..math.floor(dist).."m]"

                        tag.Enabled = true
                        tag.Adornee = root
                        tag.L.Text = lns
                        tag.L.TextSize = tonumber(config.TextSize) or 14

                        -- Pooling Highlight
                        local high = highCache[pName]
                        if not high then 
                            high = Instance.new("Highlight", HighFolder); high.Name = pName; highCache[pName] = high 
                        end
                        high.Enabled = true
                        high.Adornee = char
                        high.FillColor = highlightColor; high.OutlineColor = highlightColor; high.FillTransparency = 0.5
                    end
                end
            end
        end

        -- Disable ESP for players not in range / missing characters (Prevents Destroy() Lag)
        for pName, tag in pairs(espCache) do if not currentFramePlayers[pName] then tag.Enabled = false end end
        for pName, high in pairs(highCache) do if not currentFramePlayers[pName] then high.Enabled = false end end
    end)

    UpdateTheme()
    
    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = i.Position; startPos = MainFrame.Position end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local d = i.Position - dragStart; MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputBegan:Connect(function(i, gp) if not gp and i.KeyCode and i.KeyCode.Name == config.MenuKey then PlayClick() MainFrame.Visible = not MainFrame.Visible end end)
end)

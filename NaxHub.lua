task.spawn(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local HttpService = game:GetService("HttpService")
    local Lighting = game:GetService("Lighting")
    local Stats = game:GetService("Stats")

    local LocalPlayer = Players.LocalPlayer
    while not LocalPlayer do task.wait() LocalPlayer = Players.LocalPlayer end
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

    if PlayerGui:FindFirstChild("NaxEliteFinal") then PlayerGui.NaxEliteFinal:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NaxEliteFinal"; ScreenGui.ResetOnSpawn = false; ScreenGui.IgnoreGuiInset = true; ScreenGui.Parent = PlayerGui

    local ESPFolder = Instance.new("Folder", ScreenGui); ESPFolder.Name = "ESPCache"
    local HighFolder = Instance.new("Folder", workspace.CurrentCamera); HighFolder.Name = "NaxHighFolder"

    local HubRunning = true 

    -- [[ 1. THE EXTENDED TROLL LOADER ]] --
    local LoadFrame = Instance.new("Frame", ScreenGui)
    LoadFrame.Size = UDim2.new(0, 320, 0, 140); LoadFrame.Position = UDim2.new(0.5, -160, 0.5, -70)
    LoadFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15); LoadFrame.ZIndex = 5000; Instance.new("UICorner", LoadFrame)
    local LoadStroke = Instance.new("UIStroke", LoadFrame); LoadStroke.Thickness = 2; LoadStroke.Color = Color3.fromRGB(60, 60, 70)
    
    local LoadLabel = Instance.new("TextLabel", LoadFrame)
    LoadLabel.Size = UDim2.new(1, 0, 1, 0); LoadLabel.BackgroundTransparency = 1; LoadLabel.Font = Enum.Font.GothamBold; LoadLabel.TextColor3 = Color3.new(1, 1, 1); LoadLabel.TextSize = 20; LoadLabel.ZIndex = 5001; LoadLabel.Text = "Loading Nax Hub Premium..."
    
    local LoadSound = Instance.new("Sound", ScreenGui); LoadSound.SoundId = "rbxassetid://105471012712320"; LoadSound.Volume = 2; LoadSound:Play()
    
    task.wait(2.5)
    if not HubRunning then return end 
    LoadLabel.Text = "Sike just wasting ur time lil bro"
    LoadLabel.TextColor3 = Color3.fromRGB(255, 60, 60); LoadLabel.TextSize = 22
    task.wait(2.5)
    if not HubRunning then return end 
    
    -- The Agonizing Countdown
    local trollSequence = {3, 2, 1, 2, 3, 4, 5, 4, 3, 2, 3, 2, 1}
    for _, num in ipairs(trollSequence) do
        LoadLabel.Text = "Starting in... " .. tostring(num)
        task.wait(0.8) -- Wait almost a full second per number
        if not HubRunning then return end
    end
    
    -- Skip to 0 and load
    LoadLabel.Text = "Starting in... 0"
    LoadLabel.TextColor3 = Color3.fromRGB(60, 255, 60) -- Turns green
    task.wait(1)
    
    if LoadFrame and LoadFrame.Parent then LoadFrame:Destroy() end
    if not HubRunning then return end 

    -- [[ 2. CONFIG SYSTEM ]] --
    local defaultCfg = { Hue = 234, HighHue = 210, MaxDistance = 10000, InfiniteDistance = false, ESPRefreshRate = 60, TextSize = 14, MenuKey = "LeftControl", ESPEnabled = false, ShowDisplay = true, ShowUser = true, ProximityAlert = false, ShowStats = false, Fullbright = false, TargetName = "Select Player", TargetESP = false, UnlockCamera = false, FPSBooster = false }
    local config = table.clone(defaultCfg)
    local function SaveConfig() pcall(function() writefile("NaxHub_Config.json", HttpService:JSONEncode(config)) end) end
    pcall(function() if isfile("NaxHub_Config.json") then local d = HttpService:JSONDecode(readfile("NaxHub_Config.json")) for i,v in pairs(d) do config[i]=v end end end)

    local accentColor = Color3.fromHSV(config.Hue / 360, 0.7, 1)
    local darkAccentColor = Color3.fromHSV(config.Hue / 360, 0.9, 0.6)
    local highlightColor = Color3.fromHSV(config.HighHue / 360, 0.7, 1)

    -- [[ 3. THEME ENGINE ]] --
    local themedElements = {Strokes = {}, Toggles = {}, Watermarks = {}, Branding = {}, Gradients = {}, Spinners = {}, Stats = {}, AccentGradients = {}, HoverStrokes = {}}
    local function UpdateTheme()
        accentColor = Color3.fromHSV(config.Hue / 360, 0.7, 1)
        darkAccentColor = Color3.fromHSV(config.Hue / 360, 0.9, 0.6)
        highlightColor = Color3.fromHSV(config.HighHue / 360, 0.7, 1)
        
        for _, s in pairs(themedElements.Strokes) do s.Color = accentColor end
        for _, t in pairs(themedElements.Toggles) do if t.State then t.Frame.BackgroundColor3 = accentColor end end
        for _, w in pairs(themedElements.Watermarks) do w.TextColor3 = accentColor end
        for _, b in pairs(themedElements.Branding) do b.TextColor3 = accentColor end
        for _, st in pairs(themedElements.Stats) do st.TextColor3 = accentColor end
        for _, sp in pairs(themedElements.Spinners) do sp.BackgroundColor3 = accentColor; if sp:FindFirstChildOfClass("UIStroke") then sp:FindFirstChildOfClass("UIStroke").Color = accentColor end end
        for _, g in pairs(themedElements.Gradients) do g.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, accentColor), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 15, 20)), ColorSequenceKeypoint.new(1, accentColor)}) end
        for _, ag in pairs(themedElements.AccentGradients) do ag.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, accentColor), ColorSequenceKeypoint.new(1, darkAccentColor)}) end
    end

    -- [[ 4. MAIN HUB & GLASSMORPHISM ]] --
    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 400, 0, 280); MainFrame.Position = UDim2.new(0.5, -200, 0.5, -140)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20); MainFrame.BackgroundTransparency = 0.15
    MainFrame.ZIndex = 10; MainFrame.Visible = true; Instance.new("UICorner", MainFrame)
    
    local MainStroke = Instance.new("UIStroke", MainFrame); MainStroke.Thickness = 2.5; MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local StrokeGradient = Instance.new("UIGradient", MainStroke); table.insert(themedElements.Gradients, StrokeGradient)
    task.spawn(function() while HubRunning and MainFrame.Parent do StrokeGradient.Rotation = (StrokeGradient.Rotation + 1.5) % 360 task.wait(0.01) end end)

    TweenService:Create(MainFrame, TweenInfo.new(0.7, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 500, 0, 360), Position = UDim2.new(0.5, -250, 0.5, -180)
    }):Play()

    -- Slow Edge Trail Dot
    local function CreateSpinner(trans)
        local s = Instance.new("Frame", MainFrame); s.Size = UDim2.new(0, 6, 0, 6); s.ZIndex = 15; s.BackgroundColor3 = accentColor; s.BackgroundTransparency = trans; Instance.new("UICorner", s).CornerRadius = UDim.new(1,0)
        local glow = Instance.new("UIStroke", s); glow.Thickness = 3; glow.Color = accentColor; glow.Transparency = math.clamp(trans + 0.2, 0, 1)
        table.insert(themedElements.Spinners, s); return s
    end
    local trailParts = {} for i = 0, 6 do table.insert(trailParts, CreateSpinner(i * 0.15)) end
    task.spawn(function()
        local prog = 0
        while HubRunning and MainFrame.Parent do
            prog = prog + 0.0015
            for i, part in pairs(trailParts) do
                local t = (prog - ((i-1) * 0.008)) % 1; local x, y
                if t < 0.25 then x, y = t * 4, 0 elseif t < 0.5 then x, y = 1, (t - 0.25) * 4 elseif t < 0.75 then x, y = 1 - ((t - 0.5) * 4), 1 else x, y = 0, 1 - ((t - 0.75) * 4) end
                part.Position = UDim2.new(x, -3, y, -3)
            end
            RunService.RenderStepped:Wait()
        end
    end)

    -- Repeating Nax Background
    local WatermarkContainer = Instance.new("Frame", MainFrame); WatermarkContainer.Size = UDim2.new(1.5, 0, 1.5, 0); WatermarkContainer.Position = UDim2.new(-0.25, 0, -0.25, 0); WatermarkContainer.BackgroundTransparency = 1; WatermarkContainer.ZIndex = 11; WatermarkContainer.ClipsDescendants = true
    for x = 0, 8 do for y = 0, 8 do
        local txt = Instance.new("TextLabel", WatermarkContainer); txt.Text = "NAX"; txt.Font = Enum.Font.GothamBold; txt.TextSize = 25; txt.TextColor3 = accentColor; txt.TextTransparency = 0.95; txt.BackgroundTransparency = 1; txt.Position = UDim2.new(0, x * 85, 0, y * 65); txt.Rotation = -25; txt.ZIndex = 11; table.insert(themedElements.Watermarks, txt)
    end end
    task.spawn(function() while HubRunning and MainFrame.Parent do WatermarkContainer.Position = WatermarkContainer.Position + UDim2.new(0, 0.4, 0, 0.3) if WatermarkContainer.Position.X.Offset >= 0 then WatermarkContainer.Position = UDim2.new(-0.25, 0, -0.25, 0) end task.wait(0.03) end end)

    -- Sidebar Metadata
    local Sidebar = Instance.new("Frame", MainFrame); Sidebar.Size = UDim2.new(0, 130, 1, 0); Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 14); Sidebar.BackgroundTransparency = 0.3; Sidebar.ZIndex = 20; Instance.new("UICorner", Sidebar)
    local ProfileImage = Instance.new("ImageLabel", Sidebar); ProfileImage.Size = UDim2.new(0, 55, 0, 55); ProfileImage.Position = UDim2.new(0.5, -27, 0, 20); ProfileImage.ZIndex = 25; Instance.new("UICorner", ProfileImage).CornerRadius = UDim.new(1, 0)
    local ProfStroke = Instance.new("UIStroke", ProfileImage); ProfStroke.Thickness = 2; ProfStroke.Color = accentColor; table.insert(themedElements.Strokes, ProfStroke)
    pcall(function() ProfileImage.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end)
    local UserLabel = Instance.new("TextLabel", Sidebar); UserLabel.Size = UDim2.new(1, 0, 0, 20); UserLabel.Position = UDim2.new(0, 0, 0, 80); UserLabel.BackgroundTransparency = 1; UserLabel.ZIndex = 25; UserLabel.Font = Enum.Font.GothamBold; UserLabel.TextSize = 11; UserLabel.TextColor3 = Color3.fromRGB(200, 200, 200); UserLabel.Text = "@" .. LocalPlayer.Name
    local PlayerCountLabel = Instance.new("TextLabel", Sidebar); PlayerCountLabel.Size = UDim2.new(1, -10, 0, 25); PlayerCountLabel.Position = UDim2.new(0, 8, 1, -25); PlayerCountLabel.BackgroundTransparency = 1; PlayerCountLabel.ZIndex = 25; PlayerCountLabel.Font = Enum.Font.GothamMedium; PlayerCountLabel.TextSize = 12; PlayerCountLabel.TextColor3 = Color3.fromRGB(180, 180, 180); PlayerCountLabel.RichText = true; PlayerCountLabel.TextXAlignment = Enum.TextXAlignment.Left
    task.spawn(function() while HubRunning and MainFrame.Parent do PlayerCountLabel.Text = string.format("<font color='#00FF00'>●</font> %d Players", #Players:GetPlayers()) task.wait(1) end end)

    -- Branding
    local Branding = Instance.new("Frame", MainFrame); Branding.Size = UDim2.new(0, 200, 0, 40); Branding.Position = UDim2.new(0, 140, 0, 15); Branding.BackgroundTransparency = 1; Branding.ZIndex = 30
    local NaxText = Instance.new("TextLabel", Branding); NaxText.Size = UDim2.new(0, 40, 1, 0); NaxText.BackgroundTransparency = 1; NaxText.Font = Enum.Font.GothamBold; NaxText.TextSize = 24; NaxText.Text = "Nax"; NaxText.Rotation = -8; NaxText.ZIndex = 31; table.insert(themedElements.Branding, NaxText)
    local HubText = Instance.new("TextLabel", Branding); HubText.Size = UDim2.new(1, -45, 1, 0); HubText.Position = UDim2.new(0, 45, 0, 0); HubText.BackgroundTransparency = 1; HubText.Font = Enum.Font.GothamBold; HubText.TextSize = 20; HubText.TextColor3 = Color3.new(1, 1, 1); HubText.Text = "Hub Premium"; HubText.ZIndex = 31; HubText.TextXAlignment = Enum.TextXAlignment.Left
    task.spawn(function() local t = 0 while HubRunning and MainFrame.Parent do t = t + 0.05 NaxText.Rotation = -8 + (math.sin(t) * 6) NaxText.TextSize = 24 * (1 + (math.cos(t * 0.5) * 0.06)) task.wait(0.02) end end)
    local Credits = Instance.new("TextLabel", MainFrame); Credits.Size = UDim2.new(0, 200, 0, 20); Credits.Position = UDim2.new(1, -210, 1, -25); Credits.BackgroundTransparency = 1; Credits.ZIndex = 30; Credits.Font = Enum.Font.GothamBold; Credits.TextSize = 13; Credits.TextColor3 = Color3.fromRGB(100, 100, 100); Credits.TextXAlignment = Enum.TextXAlignment.Right; Credits.RichText = true; Credits.Text = "Nax | <font color='#5865F2'>💬</font> pweck_."

    -- [[ 5. PAGE LOGIC ]] --
    local layoutOrders = {}
    local function GetOrder(parent) layoutOrders[parent] = (layoutOrders[parent] or 0) + 1; return layoutOrders[parent] end

    local PageContainer = Instance.new("Frame", MainFrame); PageContainer.Size = UDim2.new(1, -150, 1, -110); PageContainer.Position = UDim2.new(0, 140, 0, 65); PageContainer.BackgroundTransparency = 1; PageContainer.ZIndex = 30; PageContainer.ClipsDescendants = true
    local Pages = {Visuals = Instance.new("ScrollingFrame", PageContainer), Misc = Instance.new("ScrollingFrame", PageContainer), Settings = Instance.new("ScrollingFrame", PageContainer)}
    for _, p in pairs(Pages) do 
        p.Size = UDim2.new(1,0,1,0); p.BackgroundTransparency = 1; p.ZIndex = 31; p.Visible = false
        if p:IsA("ScrollingFrame") then 
            p.ScrollBarThickness = 0; p.AutomaticCanvasSize = Enum.AutomaticSize.Y
            local ll = Instance.new("UIListLayout", p); ll.Padding = UDim.new(0, 10); ll.SortOrder = Enum.SortOrder.LayoutOrder
        end 
    end
    Pages.Visuals.Visible = true

    -- [[ HELPER: TACTILE HOVER ANIMATION ]] --
    local function ApplyHoverEffects(btn, stroke, normalColor, hoverColor)
        btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play() if stroke then TweenService:Create(stroke, TweenInfo.new(0.2), {Color = accentColor}):Play() end end)
        btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = normalColor}):Play() if stroke then TweenService:Create(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(35, 35, 40)}):Play() end end)
    end

    -- [[ 6. PREMIUM UI COMPONENT GENERATORS ]] --
    local function CreateToggle(text, configKey, parent, callback)
        local btn = Instance.new("TextButton", parent); btn.Size = UDim2.new(1, -10, 0, 38); btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25); btn.Text = ""; btn.ZIndex = 35; btn.LayoutOrder = GetOrder(parent)
        Instance.new("UICorner", btn); local stroke = Instance.new("UIStroke", btn); stroke.Color = Color3.fromRGB(35, 35, 40); table.insert(themedElements.HoverStrokes, stroke)
        ApplyHoverEffects(btn, stroke, Color3.fromRGB(20, 20, 25), Color3.fromRGB(28, 28, 33))
        
        local lbl = Instance.new("TextLabel", btn); lbl.Size = UDim2.new(1, -50, 1, 0); lbl.Position = UDim2.new(0, 12, 0, 0); lbl.BackgroundTransparency = 1; lbl.Font = Enum.Font.GothamSemibold; lbl.TextColor3 = Color3.fromRGB(220, 220, 220); lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Text = text; lbl.ZIndex = 36
        local p = Instance.new("Frame", btn); p.Size = UDim2.new(0, 32, 0, 18); p.Position = UDim2.new(1, -42, 0.5, -9); p.BackgroundColor3 = Color3.fromRGB(40, 40, 45); p.ZIndex = 36; Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
        local c = Instance.new("Frame", p); c.Size = UDim2.new(0, 14, 0, 14); c.Position = UDim2.new(0, 2, 0.5, -7); c.BackgroundColor3 = Color3.new(1,1,1); c.ZIndex = 37; Instance.new("UICorner", c).CornerRadius = UDim.new(1, 0)
        
        local grad = Instance.new("UIGradient", p); grad.Rotation = 45; table.insert(themedElements.AccentGradients, grad)
        local tRef = {State = config[configKey], Frame = p}; table.insert(themedElements.Toggles, tRef)
        local function u() local s = config[configKey]; tRef.State = s; TweenService:Create(c, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = s and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play() p.BackgroundColor3 = s and accentColor or Color3.fromRGB(40, 40, 45) end
        u(); btn.MouseButton1Click:Connect(function() config[configKey] = not config[configKey]; u(); if callback then callback(config[configKey]) end SaveConfig() end)
    end

    local function CreateSlider(text, min, max, configKey, parent)
        local f = Instance.new("Frame", parent); f.Size = UDim2.new(1, -10, 0, 50); f.BackgroundTransparency = 1; f.ZIndex = 35; f.LayoutOrder = GetOrder(parent)
        local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 0, 20); l.BackgroundTransparency = 1; l.Font = Enum.Font.GothamSemibold; l.TextColor3 = Color3.fromRGB(220, 220, 220); l.TextSize = 13; l.TextXAlignment = Enum.TextXAlignment.Left; l.Text = text; l.ZIndex = 36
        local vL = Instance.new("TextLabel", f); vL.Size = UDim2.new(1, 0, 0, 20); vL.BackgroundTransparency = 1; vL.Font = Enum.Font.GothamBold; vL.TextColor3 = accentColor; vL.TextSize = 13; vL.TextXAlignment = Enum.TextXAlignment.Right; vL.Text = tostring(config[configKey]); vL.ZIndex = 36
        
        local bg = Instance.new("Frame", f); bg.Size = UDim2.new(1, 0, 0, 8); bg.Position = UDim2.new(0, 0, 0, 32); bg.BackgroundColor3 = Color3.fromRGB(30, 30, 35); bg.ZIndex = 36; Instance.new("UICorner", bg).CornerRadius = UDim.new(1,0)
        local fill = Instance.new("Frame", bg); fill.Size = UDim2.new((config[configKey]-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = accentColor; fill.ZIndex = 37; Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0); table.insert(themedElements.Toggles, {State = true, Frame = fill})
        
        local grad = Instance.new("UIGradient", fill); table.insert(themedElements.AccentGradients, grad)
        local knob = Instance.new("Frame", fill); knob.Size = UDim2.new(0, 14, 0, 14); knob.Position = UDim2.new(1, -7, 0.5, -7); knob.BackgroundColor3 = Color3.new(1,1,1); knob.ZIndex = 38; Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
        local b = Instance.new("TextButton", bg); b.Size = UDim2.new(1, 0, 1, 0); b.BackgroundTransparency = 1; b.Text = ""; b.ZIndex = 40
        
        b.MouseEnter:Connect(function() TweenService:Create(knob, TweenInfo.new(0.2), {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -9, 0.5, -9)}):Play() end)
        b.MouseLeave:Connect(function() TweenService:Create(knob, TweenInfo.new(0.2), {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -7, 0.5, -7)}):Play() end)

        local drag = false; b.MouseButton1Down:Connect(function() drag = true end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false; SaveConfig() end end)
        RunService.RenderStepped:Connect(function() if drag and HubRunning then local pct = math.clamp((UserInputService:GetMouseLocation().X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1); local val = math.floor(min + (max-min)*pct); config[configKey] = val; fill.Size = UDim2.new(pct, 0, 1, 0); vL.Text = tostring(val); UpdateTheme() end end)
    end

    local function CreateKeybind(text, configKey, parent)
        local btn = Instance.new("TextButton", parent); btn.Size = UDim2.new(1, -10, 0, 38); btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25); btn.Text = ""; btn.ZIndex = 35; btn.LayoutOrder = GetOrder(parent)
        Instance.new("UICorner", btn); local stroke = Instance.new("UIStroke", btn); stroke.Color = Color3.fromRGB(35, 35, 40); ApplyHoverEffects(btn, stroke, Color3.fromRGB(20, 20, 25), Color3.fromRGB(28, 28, 33))
        
        local lbl = Instance.new("TextLabel", btn); lbl.Size = UDim2.new(1, -80, 1, 0); lbl.Position = UDim2.new(0, 12, 0, 0); lbl.BackgroundTransparency = 1; lbl.Font = Enum.Font.GothamSemibold; lbl.TextColor3 = Color3.fromRGB(220, 220, 220); lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Text = text; lbl.ZIndex = 36
        local val = Instance.new("TextLabel", btn); val.Size = UDim2.new(0, 75, 0, 22); val.Position = UDim2.new(1, -80, 0.5, -11); val.BackgroundColor3 = Color3.fromRGB(30, 30, 35); val.TextColor3 = accentColor; val.Font = Enum.Font.GothamBold; val.TextSize = 12; val.Text = config[configKey]; val.ZIndex = 37; Instance.new("UICorner", val)
        
        local listening = false
        btn.MouseButton1Click:Connect(function() listening = true; val.Text = "..." end)
        UserInputService.InputBegan:Connect(function(i) if listening and i.UserInputType == Enum.UserInputType.Keyboard then config[configKey] = i.KeyCode.Name; val.Text = i.KeyCode.Name; listening = false; SaveConfig() end end)
    end

    local function CreateButton(text, parent, callback)
        local btn = Instance.new("TextButton", parent); btn.Size = UDim2.new(1, -10, 0, 38); btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25); btn.ZIndex = 35; btn.LayoutOrder = GetOrder(parent)
        Instance.new("UICorner", btn); local stroke = Instance.new("UIStroke", btn); stroke.Color = Color3.fromRGB(35, 35, 40)
        btn.Text = text; btn.Font = Enum.Font.GothamBold; btn.TextSize = 13; btn.TextColor3 = Color3.new(1,1,1)
        ApplyHoverEffects(btn, stroke, Color3.fromRGB(20, 20, 25), Color3.fromRGB(28, 28, 33))
        btn.MouseButton1Click:Connect(function() local oldC = btn.BackgroundColor3; btn.BackgroundColor3 = accentColor; TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = oldC}):Play(); if callback then callback() end end)
    end

    local function CreateDropdown(parent)
        local DropMain = Instance.new("Frame", parent); DropMain.Size = UDim2.new(1, -10, 0, 38); DropMain.BackgroundColor3 = Color3.fromRGB(20, 20, 25); DropMain.ZIndex = 35; DropMain.LayoutOrder = GetOrder(parent); DropMain.ClipsDescendants = true
        Instance.new("UICorner", DropMain); local stroke = Instance.new("UIStroke", DropMain); stroke.Color = Color3.fromRGB(35, 35, 40)
        
        local Display = Instance.new("TextLabel", DropMain); Display.Size = UDim2.new(1, -40, 0, 38); Display.Position = UDim2.new(0, 12, 0, 0); Display.BackgroundTransparency = 1; Display.Font = Enum.Font.GothamSemibold; Display.TextSize = 13; Display.TextColor3 = Color3.fromRGB(220, 220, 220); Display.TextXAlignment = Enum.TextXAlignment.Left; Display.Text = "Target: " .. (config.TargetName == "" and "Select Player" or config.TargetName); Display.ZIndex = 36
        local Arrow = Instance.new("TextLabel", DropMain); Arrow.Size = UDim2.new(0, 38, 0, 38); Arrow.Position = UDim2.new(1, -38, 0, 0); Arrow.BackgroundTransparency = 1; Arrow.Font = Enum.Font.GothamBold; Arrow.TextSize = 16; Arrow.TextColor3 = Color3.new(1,1,1); Arrow.Text = "v"; Arrow.ZIndex = 36

        local Btn = Instance.new("TextButton", DropMain); Btn.Size = UDim2.new(1, 0, 0, 38); Btn.BackgroundTransparency = 1; Btn.Text = ""; Btn.ZIndex = 45
        ApplyHoverEffects(Btn, stroke, Color3.fromRGB(20, 20, 25), Color3.fromRGB(28, 28, 33))

        local Content = Instance.new("Frame", DropMain); Content.Size = UDim2.new(1, 0, 1, -38); Content.Position = UDim2.new(0, 0, 0, 38); Content.BackgroundTransparency = 1; Content.Visible = false; Content.ZIndex = 36
        
        local SearchBox = Instance.new("TextBox", Content); SearchBox.Size = UDim2.new(1, -16, 0, 28); SearchBox.Position = UDim2.new(0, 8, 0, 5); SearchBox.BackgroundColor3 = Color3.fromRGB(15, 15, 18); SearchBox.Font = Enum.Font.Gotham; SearchBox.TextSize = 12; SearchBox.TextColor3 = Color3.new(1,1,1); SearchBox.PlaceholderText = "Search player..."; SearchBox.Text = ""; SearchBox.ZIndex = 37; Instance.new("UICorner", SearchBox); Instance.new("UIStroke", SearchBox).Color = accentColor
        
        local Scroll = Instance.new("ScrollingFrame", Content); Scroll.Size = UDim2.new(1, -16, 1, -45); Scroll.Position = UDim2.new(0, 8, 0, 40); Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 2; Scroll.ZIndex = 37; local ListL = Instance.new("UIListLayout", Scroll); ListL.Padding = UDim.new(0, 5)

        local isOpen = false
        local function Refresh()
            for _, c in pairs(Scroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
            local ySize = 0
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and (SearchBox.Text == "" or string.find(p.Name:lower(), SearchBox.Text:lower()) or string.find(p.DisplayName:lower(), SearchBox.Text:lower())) then
                    local item = Instance.new("Frame", Scroll); item.Size = UDim2.new(1, -8, 0, 32); item.BackgroundColor3 = Color3.fromRGB(25, 25, 30); item.ZIndex = 38; Instance.new("UICorner", item).CornerRadius = UDim.new(0, 4)
                    local img = Instance.new("ImageLabel", item); img.Size = UDim2.new(0, 24, 0, 24); img.Position = UDim2.new(0, 4, 0.5, -12); img.BackgroundColor3 = Color3.fromRGB(40, 40, 45); img.ZIndex = 39; Instance.new("UICorner", img).CornerRadius = UDim.new(1, 0)
                    task.spawn(function() pcall(function() img.Image = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end) end)
                    local pName = Instance.new("TextLabel", item); pName.Size = UDim2.new(1, -35, 1, 0); pName.Position = UDim2.new(0, 34, 0, 0); pName.BackgroundTransparency = 1; pName.Font = Enum.Font.GothamSemibold; pName.TextSize = 12; pName.TextColor3 = (config.TargetName == p.Name) and accentColor or Color3.fromRGB(200, 200, 200); pName.TextXAlignment = Enum.TextXAlignment.Left; pName.Text = p.DisplayName .. " (@" .. p.Name .. ")"; pName.ZIndex = 39

                    local clickBtn = Instance.new("TextButton", item); clickBtn.Size = UDim2.new(1, 0, 1, 0); clickBtn.BackgroundTransparency = 1; clickBtn.Text = ""; clickBtn.ZIndex = 40
                    ApplyHoverEffects(clickBtn, nil, Color3.fromRGB(25, 25, 30), Color3.fromRGB(35, 35, 40))

                    clickBtn.MouseButton1Click:Connect(function()
                        config.TargetName = p.Name; Display.Text = "Target: " .. p.Name; isOpen = false; TweenService:Create(DropMain, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, -10, 0, 38)}):Play(); Content.Visible = false; TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 0}):Play(); SaveConfig()
                    end)
                    ySize = ySize + 37
                end
            end
            Scroll.CanvasSize = UDim2.new(0, 0, 0, ySize)
        end

        Btn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            if isOpen then TweenService:Create(DropMain, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, -10, 0, 200)}):Play(); Content.Visible = true; TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 180}):Play(); Refresh()
            else TweenService:Create(DropMain, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, -10, 0, 38)}):Play(); Content.Visible = false; TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = 0}):Play() end
        end)
        SearchBox:GetPropertyChangedSignal("Text"):Connect(Refresh)
    end

    local function CreateTab(text, y)
        local btn = Instance.new("TextButton", Sidebar); btn.Size = UDim2.new(1, 0, 0, 35); btn.Position = UDim2.new(0, 0, 0, y); btn.BackgroundTransparency = 1; btn.ZIndex = 25; btn.Font = Enum.Font.GothamBold; btn.TextSize = 14; btn.TextColor3 = (text == "Visuals") and Color3.new(1,1,1) or Color3.fromRGB(120, 120, 120); btn.Text = text
        btn.MouseEnter:Connect(function() if btn.TextColor3 ~= Color3.new(1,1,1) then TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(180, 180, 180)}):Play() end end)
        btn.MouseLeave:Connect(function() if btn.TextColor3 ~= Color3.new(1,1,1) then TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(120, 120, 120)}):Play() end end)
        btn.MouseButton1Click:Connect(function() for n, p in pairs(Pages) do p.Visible = (n == text) end for _, v in pairs(Sidebar:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Color3.fromRGB(120, 120, 120) end end btn.TextColor3 = Color3.new(1, 1, 1) end)
    end
    CreateTab("Visuals", 120); CreateTab("Misc", 155); CreateTab("Settings", 190)

    -- [[ INJECT VISUALS ]] --
    CreateToggle("Enable Player ESP", "ESPEnabled", Pages.Visuals)
    CreateSlider("ESP Max Distance", 50, 100000, "MaxDistance", Pages.Visuals)
    CreateSlider("ESP Text Size", 8, 24, "TextSize", Pages.Visuals)
    CreateSlider("ESP Update Rate (Saves FPS)", 10, 144, "ESPRefreshRate", Pages.Visuals)

    local TargetDivider = Instance.new("Frame", Pages.Visuals); TargetDivider.Size = UDim2.new(1, -10, 0, 20); TargetDivider.BackgroundTransparency = 1; TargetDivider.ZIndex = 35; TargetDivider.LayoutOrder = GetOrder(Pages.Visuals)
    local TargetTitle = Instance.new("TextLabel", TargetDivider); TargetTitle.Size = UDim2.new(1, 0, 1, 0); TargetTitle.BackgroundTransparency = 1; TargetTitle.Font = Enum.Font.GothamBold; TargetTitle.TextSize = 13; TargetTitle.TextColor3 = accentColor; TargetTitle.TextXAlignment = Enum.TextXAlignment.Center; TargetTitle.Text = "— TARGET VISUALS —"; TargetTitle.ZIndex = 36; table.insert(themedElements.Branding, TargetTitle)

    CreateDropdown(Pages.Visuals)
    CreateToggle("Target ESP Override", "TargetESP", Pages.Visuals)

    -- [[ INJECT MISC ]] --
    CreateToggle("FPS Booster (Potato Map)", "FPSBooster", Pages.Misc, function(state)
        if state then Lighting.GlobalShadows = false for _, v in pairs(Lighting:GetChildren()) do if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Clouds") then v.Enabled = false end end
        else Lighting.GlobalShadows = true for _, v in pairs(Lighting:GetChildren()) do if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Clouds") then v.Enabled = true end end end
    end)
    CreateToggle("Fullbright / Night Vision", "Fullbright", Pages.Misc)
    CreateToggle("Unlock Camera Zoom", "UnlockCamera", Pages.Misc)
    CreateToggle("Proximity Danger Alert", "ProximityAlert", Pages.Misc)
    CreateToggle("Show Display Names", "ShowDisplay", Pages.Misc)
    CreateToggle("Show Usernames", "ShowUser", Pages.Misc)
    CreateButton("Execute Lunar Hub", Pages.Misc, function() loadstring(game:HttpGet("https://raw.githubusercontent.com/Mangnex/Lunar-Hub/refs/heads/main/FreeLoader.lua"))() end)

    -- [[ INJECT SETTINGS ]] --
    CreateKeybind("Menu Toggle Key", "MenuKey", Pages.Settings)
    CreateToggle("Show FPS & Ping UI", "ShowStats", Pages.Settings)
    CreateSlider("Menu Theme Hue", 0, 360, "Hue", Pages.Settings)
    CreateSlider("ESP Highlight Hue", 0, 360, "HighHue", Pages.Settings)
    
    local StatsLoopConnection, ESPLoopConnection

    local function PerformKillswitch()
        HubRunning = false
        if StatsLoopConnection then StatsLoopConnection:Disconnect() end
        if ESPLoopConnection then ESPLoopConnection:Disconnect() end
        pcall(function() ESPFolder:Destroy() end)
        pcall(function() HighFolder:Destroy() end)
        ScreenGui:Destroy()
    end

    local ResetBtn = Instance.new("TextButton", Pages.Settings); ResetBtn.Size = UDim2.new(1, -10, 0, 35); ResetBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35); ResetBtn.ZIndex = 35; ResetBtn.LayoutOrder = GetOrder(Pages.Settings); ResetBtn.Text = "Reset Config"; ResetBtn.TextColor3 = Color3.new(1,1,1); ResetBtn.Font = Enum.Font.GothamBold; ResetBtn.TextSize = 13; Instance.new("UICorner", ResetBtn); local rs = Instance.new("UIStroke", ResetBtn); rs.Color = Color3.fromRGB(45, 45, 50); ApplyHoverEffects(ResetBtn, rs, Color3.fromRGB(30, 30, 35), Color3.fromRGB(40, 40, 45))
    ResetBtn.MouseButton1Click:Connect(function() pcall(function() delfile("NaxHub_Config.json") end) PerformKillswitch() end)

    local DestroyBtn = Instance.new("TextButton", Pages.Settings); DestroyBtn.Size = UDim2.new(0, 100, 0, 25); DestroyBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 28); DestroyBtn.ZIndex = 35; DestroyBtn.LayoutOrder = GetOrder(Pages.Settings); DestroyBtn.Text = "Destroy Hub"; DestroyBtn.TextColor3 = Color3.fromRGB(150, 150, 150); DestroyBtn.Font = Enum.Font.GothamBold; DestroyBtn.TextSize = 12; Instance.new("UICorner", DestroyBtn); ApplyHoverEffects(DestroyBtn, nil, Color3.fromRGB(25, 25, 28), Color3.fromRGB(40, 30, 30))
    DestroyBtn.MouseButton1Click:Connect(function() PerformKillswitch() end)

    -- [[ FIXED LIVE FPS & PING COUNTER ]] --
    local StatsFrame = Instance.new("Frame", ScreenGui); StatsFrame.Size = UDim2.new(0, 150, 0, 30); StatsFrame.Position = UDim2.new(0, 15, 0, 15); StatsFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20); StatsFrame.BackgroundTransparency = 0.2; StatsFrame.ZIndex = 100; StatsFrame.Visible = false; Instance.new("UICorner", StatsFrame).CornerRadius = UDim.new(0, 6)
    local StatsStroke = Instance.new("UIStroke", StatsFrame); StatsStroke.Thickness = 2; StatsStroke.Color = accentColor; table.insert(themedElements.Strokes, StatsStroke)
    local StatsLabel = Instance.new("TextLabel", StatsFrame); StatsLabel.Size = UDim2.new(1, 0, 1, 0); StatsLabel.BackgroundTransparency = 1; StatsLabel.Font = Enum.Font.GothamBold; StatsLabel.TextSize = 13; StatsLabel.TextColor3 = Color3.new(1, 1, 1); StatsLabel.Text = "FPS: 0 | Ping: 0ms"; StatsLabel.ZIndex = 101

    local lastStatsUpdate = tick()
    StatsLoopConnection = RunService.RenderStepped:Connect(function(dt)
        if not HubRunning then return end
        if tick() - lastStatsUpdate >= 1 then
            lastStatsUpdate = tick()
            if config.ShowStats then
                local fps = math.floor(1 / dt)
                local ping = 0; pcall(function() ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) end)
                if ping == 0 then pcall(function() ping = math.floor(game:GetService("Stats").PerformanceStats.Ping:GetValue()) end) end
                StatsLabel.Text = string.format("FPS: %d | Ping: %dms", fps, ping); StatsFrame.Visible = true
            else StatsFrame.Visible = false end
        end
    end)

    -- [[ LOGIC LOOPS ]] --
    task.spawn(function() 
        while HubRunning and task.wait(1) do 
            if config.Fullbright then Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.FogEnd = 100000; Lighting.GlobalShadows = false end 
            if config.UnlockCamera then LocalPlayer.CameraMaxZoomDistance = 100000 else if LocalPlayer.CameraMaxZoomDistance == 100000 then LocalPlayer.CameraMaxZoomDistance = 400 end end
        end 
    end)

    -- [[ GHOST-PROOF & LIMIT-PROOF ESP LOOP ]] --
    local lastESPUpdate = 0
    ESPLoopConnection = RunService.RenderStepped:Connect(function()
        if not HubRunning then return end
        local now = tick()
        if now - lastESPUpdate < (1 / config.ESPRefreshRate) then return end
        lastESPUpdate = now

        if not (config.ESPEnabled or config.TargetESP) then ESPFolder:ClearAllChildren(); HighFolder:ClearAllChildren(); return end
        
        local validPlayers = {}
        for _, Player in pairs(Players:GetPlayers()) do 
            if Player ~= LocalPlayer and Player.Character then 
                local root = Player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local dist = (workspace.CurrentCamera.CFrame.Position - root.Position).Magnitude
                    table.insert(validPlayers, {Player = Player, Char = Player.Character, Root = root, Dist = dist})
                end
            end
        end

        table.sort(validPlayers, function(a, b) return a.Dist < b.Dist end)

        local currentFramePlayers = {}
        local activeHighlights = 0

        for _, pData in ipairs(validPlayers) do
            local Player = pData.Player; local dist = pData.Dist; local root = pData.Root; local char = pData.Char
            
            local isT = (Player.Name == config.TargetName)
            local showTarget = (isT and config.TargetESP)
            local showNormal = config.ESPEnabled and (dist <= config.MaxDistance)

            if showNormal or showTarget then
                currentFramePlayers[Player.Name] = true
                
                -- Billboard Gui
                local tag = ESPFolder:FindFirstChild(Player.Name.."_T") or Instance.new("BillboardGui", ESPFolder); tag.Name = Player.Name.."_T"; tag.AlwaysOnTop = true; tag.Size = UDim2.new(0, 200, 0, 50); tag.StudsOffset = Vector3.new(0, 3, 0); tag.Adornee = root
                local lbl = tag:FindFirstChild("L") or Instance.new("TextLabel", tag); lbl.Name = "L"; lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1; lbl.TextSize = config.TextSize; lbl.Font = Enum.Font.GothamBold; lbl.RichText = true
                
                local lns = {} 
                if showTarget then table.insert(lns, "<font color='#FF0000'>TARGET -</font>"); if config.ShowDisplay then table.insert(lns, Player.DisplayName) end; if config.ShowUser then table.insert(lns, "@"..Player.Name) end; table.insert(lns, "["..math.floor(dist).."m]"); lbl.Text = table.concat(lns, " "); lbl.TextColor3 = Color3.new(1, 0, 0)
                else if config.ShowDisplay then table.insert(lns, Player.DisplayName) end; if config.ShowUser then table.insert(lns, "@"..Player.Name) end; table.insert(lns, "["..math.floor(dist).."m]"); lbl.Text = table.concat(lns, " | "); lbl.TextColor3 = Color3.new(1, 1, 1) end

                -- Smart Highlight Limiter (Max 25 to prevent Roblox Bug)
                if showTarget then
                    local high = HighFolder:FindFirstChild(Player.Name.."_H") or Instance.new("Highlight", HighFolder); high.Name = Player.Name.."_H"; high.Adornee = char; high.FillColor = Color3.new(1, 0, 0); high.OutlineColor = Color3.new(1, 0, 0); high.FillTransparency = 0.2; activeHighlights = activeHighlights + 1
                elseif showNormal and activeHighlights < 25 then
                    local high = HighFolder:FindFirstChild(Player.Name.."_H") or Instance.new("Highlight", HighFolder); high.Name = Player.Name.."_H"; high.Adornee = char; high.FillColor = highlightColor; high.OutlineColor = highlightColor; high.FillTransparency = 0.5; activeHighlights = activeHighlights + 1
                else
                    local high = HighFolder:FindFirstChild(Player.Name.."_H"); if high then high:Destroy() end
                end
            end
        end

        -- Clean up dead/out-of-range players instantly
        for _, child in pairs(ESPFolder:GetChildren()) do local pName = string.gsub(child.Name, "_T", ""); if not currentFramePlayers[pName] then child:Destroy() end end
        for _, child in pairs(HighFolder:GetChildren()) do local pName = string.gsub(child.Name, "_H", ""); if not currentFramePlayers[pName] then child:Destroy() end end
    end)

    UpdateTheme()
    
    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = i.Position; startPos = MainFrame.Position end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local d = i.Position - dragStart; MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputBegan:Connect(function(i, gp) if not gp and i.KeyCode.Name == config.MenuKey then MainFrame.Visible = not MainFrame.Visible end end)
end)

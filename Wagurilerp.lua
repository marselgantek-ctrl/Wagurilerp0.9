-- =====================================================================
-- WAGURI HUB MM2 (ULTIMATE CLEAN VERSION - ALL FEATURES INTACT)
-- =====================================================================
local repo = 'https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = Workspace.CurrentCamera

local Window = Library:CreateWindow({
    Title = '🌸 Waguri Hub MM2',
    Center = true,
    AutoShow = true,
    Resizable = true,
    ShowCustomCursor = false,
    TabPadding = 4,
    MenuFadeTime = 0.2
})

local Tabs = {
    ESP = Window:AddTab('MM2 ESP'),
    Sheriff = Window:AddTab('Sheriff & Aim'),
    Avatar = Window:AddTab('Avatar & Anims'),
    Visuals = Window:AddTab('Visuals'),
    Notifications = Window:AddTab('Notifications'),
    Stealth = Window:AddTab('Invisibility'),
    Movement = Window:AddTab('Movement'),
    Teleport = Window:AddTab('Teleport'),
    Settings = Window:AddTab('Settings'),
}

---------------------------------------------------------
-- 1. TAB MM2 ESP (ESP ASLI + DIRECTION LINE + HIGHLIGHT)
---------------------------------------------------------
local EspPlayerGroup = Tabs.ESP:AddLeftGroupbox('Player Role ESP')
local EspItemGroup = Tabs.ESP:AddRightGroupbox('Item & Custom ESP')

_G.ESP_Murder = true
_G.ESP_Sheriff = true
_G.ESP_Innocent = false
_G.ESP_GunDrop = true
_G.ESP_Name = true
_G.ESP_DirectionLine = false
_G.LineThickness = 2 
_G.LineLengthSetting = 35

EspPlayerGroup:AddToggle('EspMurder', { Text = 'ESP Murderer (Merah)', Default = true, Callback = function(v) _G.ESP_Murder = v end })
EspPlayerGroup:AddToggle('EspSheriff', { Text = 'ESP Sheriff (Biru)', Default = true, Callback = function(v) _G.ESP_Sheriff = v end })
EspPlayerGroup:AddToggle('EspInnoc', { Text = 'ESP Innocent (Hijau)', Default = false, Callback = function(v) _G.ESP_Innocent = v end })

EspPlayerGroup:AddToggle('EspDirectionLineToggle', { Text = 'Garis Arah Pandang Murderer + Highlight', Default = false, Callback = function(v) _G.ESP_DirectionLine = v end })
EspPlayerGroup:AddSlider('LineThicknessSlider', {
    Text = 'Ketebalan Garis (1 - 20)',
    Default = 2,
    Min = 1,
    Max = 20,
    Rounding = 0,
    Callback = function(v)
        _G.LineThickness = v
    end
})
EspPlayerGroup:AddSlider('LineLengthSlider', {
    Text = 'Panjang Garis (1 - 20 [x10 Studs])',
    Default = 3.5,
    Min = 1,
    Max = 20,
    Rounding = 1,
    Callback = function(v)
        _G.LineLengthSetting = v * 10
    end
})

EspItemGroup:AddToggle('EspGun', { Text = 'ESP Gun Drop (Kuning + Nama)', Default = true, Callback = function(v) _G.ESP_GunDrop = v end })
EspItemGroup:AddToggle('EspNameTag', { Text = 'Tampilkan Nama Role', Default = true, Callback = function(v) _G.ESP_Name = v end })

local function getPlayerRole(plr)
    if not plr or not plr.Character then return "Innocent" end
    local function hasTool(name)
        return plr.Backpack:FindFirstChild(name) or plr.Character:FindFirstChild(name)
    end
    if hasTool("Knife") then return "Murderer"
    elseif hasTool("Gun") then return "Sheriff" end
    return "Innocent"
end

local function isPlayerSheriff()
    if not player.Character then return false end
    return player.Character:FindFirstChild("Gun") ~= nil or player.Backpack:FindFirstChild("Gun") ~= nil
end

local murderLine = Instance.new("Part")
murderLine.Name = "MurderDirectionBeam"
murderLine.Size = Vector3.new(0.1, 0.1, 1)
murderLine.Anchored = true
murderLine.CanCollide = false
murderLine.Transparency = 1
murderLine.Color = Color3.fromRGB(255, 255, 255)
murderLine.Material = Enum.Material.Neon
murderLine.Parent = Workspace

local lineHighlight = Instance.new("Highlight")
lineHighlight.Name = "LineESPHighlight"
lineHighlight.FillColor = Color3.fromRGB(255, 255, 255)
lineHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
lineHighlight.FillTransparency = 0.2
lineHighlight.OutlineTransparency = 0
lineHighlight.Adornee = murderLine
lineHighlight.Enabled = false
lineHighlight.Parent = murderLine

RunService.RenderStepped:Connect(function()
    pcall(function()
        local targetMurder = nil
        if _G.ESP_DirectionLine then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player and getPlayerRole(plr) == "Murderer" and plr.Character and plr.Character:FindFirstChild("Head") then
                    targetMurder = plr.Character
                    break
                end
            end
        end

        if targetMurder then
            local head = targetMurder:FindFirstChild("Head") or targetMurder:FindFirstChild("HumanoidRootPart")
            if head then
                local p1 = head.Position + Vector3.new(0, 1.2, 0)
                local lookVector = head.CFrame.LookVector
                local lineLength = _G.LineLengthSetting or 35
                local p2 = p1 + (lookVector * lineLength)
                local distance = (p1 - p2).Magnitude
                
                murderLine.Transparency = 0.05
                lineHighlight.Enabled = true
                local thickness = _G.LineThickness or 2
                murderLine.Size = Vector3.new(thickness * 0.04, thickness * 0.04, distance)
                murderLine.CFrame = CFrame.new(p1, p2) * CFrame.new(0, 0, -distance / 2)
            else
                murderLine.Transparency = 1
                lineHighlight.Enabled = false
            end
        else
            murderLine.Transparency = 1
            lineHighlight.Enabled = false
        end
    end)
end)

task.spawn(function()
    while true do
        task.wait(0.8)
        pcall(function()
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    local char = plr.Character
                    local role = getPlayerRole(plr)
                    local shouldShow = false
                    local espColor = Color3.fromRGB(0, 255, 100)

                    if role == "Murderer" and _G.ESP_Murder then
                        shouldShow = true; espColor = Color3.fromRGB(255, 40, 40)
                    elseif role == "Sheriff" and _G.ESP_Sheriff then
                        shouldShow = true; espColor = Color3.fromRGB(40, 120, 255)
                    elseif role == "Innocent" and _G.ESP_Innocent then
                        shouldShow = true; espColor = Color3.fromRGB(50, 255, 100)
                    end

                    local existingHL = char:FindFirstChild("MM2Highlight")
                    local hrp = char:FindFirstChild("HumanoidRootPart")

                    if shouldShow then
                        if not existingHL then
                            existingHL = Instance.new("Highlight")
                            existingHL.Name = "MM2Highlight"
                            existingHL.OutlineColor = Color3.fromRGB(255, 255, 255)
                            existingHL.FillTransparency = 0.45
                            existingHL.Parent = char
                        end
                        existingHL.FillColor = espColor

                        if hrp then
                            local bb = hrp:FindFirstChild("MM2Billboard")
                            if _G.ESP_Name then
                                local labelText = "[" .. role:upper() .. "]\n" .. plr.Name
                                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                    local dist = math.floor((hrp.Position - player.Character.HumanoidRootPart.Position).Magnitude)
                                    labelText = labelText .. " (" .. dist .. "m)"
                                end

                                if not bb then
                                    bb = Instance.new("BillboardGui")
                                    bb.Name = "MM2Billboard"
                                    bb.Size = UDim2.new(0, 140, 0, 40)
                                    bb.StudsOffset = Vector3.new(0, 3, 0)
                                    bb.AlwaysOnTop = true
                                    bb.Parent = hrp

                                    local lbl = Instance.new("TextLabel")
                                    lbl.Name = "RoleLabel"
                                    lbl.Size = UDim2.new(1, 0, 1, 0)
                                    lbl.BackgroundTransparency = 1
                                    lbl.TextStrokeTransparency = 0
                                    lbl.Font = Enum.Font.GothamBold
                                    lbl.TextSize = 11
                                    lbl.Parent = bb
                                end
                                bb.RoleLabel.Text = labelText
                                bb.RoleLabel.TextColor3 = espColor
                            elseif bb then
                                bb:Destroy()
                            end
                        end
                    else
                        if existingHL then existingHL:Destroy() end
                        if hrp and hrp:FindFirstChild("MM2Billboard") then hrp.MM2Billboard:Destroy() end
                    end
                end
            end

            local gunDrop = Workspace:FindFirstChild("GunDrop", true)
            if gunDrop and gunDrop:IsA("BasePart") then
                local hl = gunDrop:FindFirstChild("GunHighlight")
                local bb = gunDrop:FindFirstChild("GunBillboard")
                
                if _G.ESP_GunDrop then
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "GunHighlight"
                        hl.FillColor = Color3.fromRGB(255, 220, 0)
                        hl.Parent = gunDrop
                    end
                    if not bb then
                        bb = Instance.new("BillboardGui")
                        bb.Name = "GunBillboard"
                        bb.Size = UDim2.new(0, 100, 0, 30)
                        bb.StudsOffset = Vector3.new(0, 2.5, 0)
                        bb.AlwaysOnTop = true
                        bb.Parent = gunDrop

                        local lbl = Instance.new("TextLabel")
                        lbl.Name = "GunLabel"
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.TextStrokeTransparency = 0
                        lbl.Font = Enum.Font.GothamBold
                        lbl.TextSize = 12
                        lbl.TextColor3 = Color3.fromRGB(255, 220, 0)
                        lbl.Text = "[GUN DROP]"
                        lbl.Parent = bb
                    end
                else
                    if hl then hl:Destroy() end
                    if bb then bb:Destroy() end
                end
            end
        end)
    end
end)

---------------------------------------------------------
-- 2. TAB SHERIFF & BODY AIMLOCK (LERP 0.9)
---------------------------------------------------------
local SheriffGroup = Tabs.Sheriff:AddLeftGroupbox('Sheriff Aimlock & Laser')
local GunGrabGroup = Tabs.Sheriff:AddRightGroupbox('Gun Drop Utilities')

_G.AutoGrabGun = false
_G.SheriffLaser = false
_G.SheriffIndicator = false

GunGrabGroup:AddToggle('AutoGrabToggle', { Text = 'Auto Grab Gun (Otomatis)', Default = false, Callback = function(v) _G.AutoGrabGun = v end })

SheriffGroup:AddToggle('SheriffIndicatorToggle', { 
    Text = 'Indikator Bulat Target Murderer', 
    Default = false, 
    Callback = function(v) 
        _G.SheriffIndicator = v
        Library:Notify(v and 'Indikator Target Aktif!' or 'Indikator Target Dimatikan.')
    end 
})

SheriffGroup:AddToggle('SheriffLaserToggle', { Text = 'Laser Effect ke Murderer', Default = false, Callback = function(v) _G.SheriffLaser = v end })

local function grabGunNow()
    pcall(function()
        local gunDrop = Workspace:FindFirstChild("GunDrop", true)
        if gunDrop and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local oldPos = player.Character.HumanoidRootPart.CFrame
            player.Character.HumanoidRootPart.CFrame = gunDrop.CFrame
            task.wait(0.1)
            player.Character.HumanoidRootPart.CFrame = oldPos
            Library:Notify('Berhasil mengambil Gun!')
        else
            Library:Notify('Gun Drop tidak ditemukan di map!')
        end
    end)
end

GunGrabGroup:AddButton({ Text = 'TP & Ambil Gun Sekarang', Func = grabGunNow })

---------------------------------------------------------
-- 3. TAB AVATAR & ANIMATIONS
---------------------------------------------------------
local AvatarGroup = Tabs.Avatar:AddLeftGroupbox('Copy Avatar (Server Players)')
local AnimsGroup = Tabs.Avatar:AddRightGroupbox('Paket Animasi Keren & Normal')

_G.TargetPlayerName = ""

AvatarGroup:AddInput('TargetUserBox', {
    Default = '',
    Numeric = false,
    Finished = false,
    Text = 'Ketik Username Target di Server',
    Tooltip = 'Player yang sedang ada di dalam game',
    Placeholder = 'Contoh: NamaPlayer',
    Callback = function(v)
        _G.TargetPlayerName = v
    end
})

AvatarGroup:AddButton({
    Text = 'Salin Avatar Target',
    Func = function()
        pcall(function()
            local targetName = _G.TargetPlayerName
            if not targetName or targetName == "" then
                Library:Notify('Masukkan username target terlebih dahulu!')
                return
            end
            
            local targetPlr = nil
            for _, p in pairs(Players:GetPlayers()) do
                if string.sub(string.lower(p.Name), 1, string.len(targetName)) == string.lower(targetName) or 
                   string.sub(string.lower(p.DisplayName), 1, string.len(targetName)) == string.lower(targetName) then
                    targetPlr = p
                    break
                end
            end
            
            if not targetPlr or not targetPlr.Character then
                Library:Notify('Player tidak ditemukan di server ini!')
                return
            end
            
            local myChar = player.Character
            if myChar and myChar:FindFirstChildOfClass("Humanoid") then
                local myHum = myChar:FindFirstChildOfClass("Humanoid")
                local targetHum = targetPlr.Character:FindFirstChildOfClass("Humanoid")
                
                if targetHum then
                    local succ, desc = pcall(function()
                        return targetHum:GetAppliedDescription()
                    end)
                    if succ and desc then
                        myHum:ApplyDescription(desc)
                        Library:Notify('Berhasil menyalin avatar ' .. targetPlr.Name .. '!')
                    else
                        Library:Notify('Gagal menyalin deskripsi avatar.')
                    end
                end
            end
        end)
    end
})

AnimsGroup:AddButton({
    Text = 'Terapkan Animasi Keren (Smooth)',
    Func = function()
        pcall(function()
            local char = player.Character
            if char then
                local animate = char:FindFirstChild("Animate")
                if animate then
                    animate.Disabled = true
                    task.wait(0.05)
                    if animate:FindFirstChild("walk") and animate.walk:FindFirstChild("WalkAnim") then
                        animate.walk.WalkAnim.AnimationId = "rbxassetid://616168032"
                    end
                    if animate:FindFirstChild("run") and animate.run:FindFirstChild("RunAnim") then
                        animate.run.RunAnim.AnimationId = "rbxassetid://616163682"
                    end
                    animate.Disabled = false
                    Library:Notify('Animasi Keren Diaktifkan!')
                end
            end
        end)
    end
})

AnimsGroup:AddButton({
    Text = 'Reset Animasi ke Normal',
    Func = function()
        pcall(function()
            local char = player.Character
            if char then
                local animate = char:FindFirstChild("Animate")
                if animate then
                    animate.Disabled = true
                    task.wait(0.05)
                    if animate:FindFirstChild("walk") and animate.walk:FindFirstChild("WalkAnim") then
                        animate.walk.WalkAnim.AnimationId = "rbxassetid://913376220"
                    end
                    if animate:FindFirstChild("run") and animate.run:FindFirstChild("RunAnim") then
                        animate.run.RunAnim.AnimationId = "rbxassetid://913376220"
                    end
                    animate.Disabled = false
                    Library:Notify('Animasi Berhasil Direset ke Normal!')
                end
            end
        end)
    end
})

---------------------------------------------------------
-- 4. TAB VISUALS (SPINNING CROSSHAIR)
---------------------------------------------------------
local VisualGroup = Tabs.Visuals:AddLeftGroupbox('Crosshair Pengaturan')

_G.SpinningCrosshair = false

VisualGroup:AddToggle('CrosshairToggle', {
    Text = 'Spinning Crosshair (Mutar)',
    Default = false,
    Callback = function(v)
        _G.SpinningCrosshair = v
        Library:Notify(v and 'Spinning Crosshair Aktif!' or 'Spinning Crosshair Dimatikan.')
    end
})

local targetGui = pcall(function() return game:GetService("CoreGui").Name end) and game:GetService("CoreGui") or playerGui

if targetGui:FindFirstChild("WaguriCrosshairGui") then targetGui.WaguriCrosshairGui:Destroy() end
local crossGui = Instance.new("ScreenGui", targetGui)
crossGui.Name = "WaguriCrosshairGui"
crossGui.IgnoreGuiInset = true

local crossContainer = Instance.new("Frame", crossGui)
crossContainer.Size = UDim2.fromOffset(40, 40)
crossContainer.AnchorPoint = Vector2.new(0.5, 0.5)
crossContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
crossContainer.BackgroundTransparency = 1
crossContainer.Visible = false

local function createLine(pos, size)
    local line = Instance.new("Frame", crossContainer)
    line.Size = size
    line.Position = pos
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
    line.BorderSizePixel = 0
    Instance.new("UICorner", line).CornerRadius = UDim.new(1, 0)
    return line
end

createLine(UDim2.new(0.5, 0, 0.2, 0), UDim2.new(0, 4, 0, 12))
createLine(UDim2.new(0.5, 0, 0.8, 0), UDim2.new(0, 4, 0, 12))
createLine(UDim2.new(0.2, 0, 0.5, 0), UDim2.new(0, 12, 0, 4))
createLine(UDim2.new(0.8, 0, 0.5, 0), UDim2.new(0, 12, 0, 4))

VisualGroup:AddToggle('FloatingCrosshairToggle', {
    Text = 'Tampilkan Crosshair di Layar',
    Default = false,
    Callback = function(v)
        crossContainer.Visible = v
        Library:Notify(v and 'Crosshair Ditampilkan!' or 'Crosshair Disembunyikan.')
    end
})

RunService.RenderStepped:Connect(function()
    pcall(function()
        if _G.SpinningCrosshair and crossContainer.Visible then
            crossContainer.Rotation = crossContainer.Rotation + 4
        end
    end)
end)

---------------------------------------------------------
-- 5. TAB NOTIFICATIONS (Anti-Fling & Status Tracker)
---------------------------------------------------------
local NotifyGroup = Tabs.Notifications:AddLeftGroupbox('Notifications & Protection')

_G.TrackerNotify = false
_G.AntiFling = false

NotifyGroup:AddToggle('TrackerNotifyToggle', { 
    Text = 'Notifikasi Status (Sheriff Mati & Gun Drop)', 
    Default = false, 
    Callback = function(v) 

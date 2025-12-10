-- Brainrot Finder + Server Hopper
-- Executor-agnostic (Synapse, Delta, Fluxus)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer

-- Executor-agnostic
local queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
local protect = (syn and syn.protect_gui) or function(x) return x end
if type(queueteleport) ~= "function" then queueteleport = nil end

-- File storage
local fileName = "brainrot_selected.json"
local function saveSelection(selection)
    if writefile then writefile(fileName, HttpService:JSONEncode({selected = selection})) end
end
local function loadSelection()
    if isfile and isfile(fileName) then
        local ok,data = pcall(function() return HttpService:JSONDecode(readfile(fileName)) end)
        if ok and data then return data.selected end
    end
    return nil
end
local function clearSelection()
    if isfile then pcall(delfile,fileName) end
end

-- Handle teleport memory
local justTeleported = getgenv().wasTeleported or false
getgenv().wasTeleported = false
local chosenBrainrot
if justTeleported then
    chosenBrainrot = loadSelection()
else
    chosenBrainrot = nil
    clearSelection()
end

-- Auto-execute after teleport
lp.OnTeleport:Connect(function()
    if queueteleport then
        queueteleport("getgenv().wasTeleported = true; loadstring(game:HttpGet('https://raw.githubusercontent.com/chesslindan-ops/Loeenaoakrbwiwjrjw/main/brainrot.lua'))()")
    end
end)

-- Remove old GUI
if lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("BrainrotFinderUI") then
    lp.PlayerGui.BrainrotFinderUI:Destroy()
end

-- Brainrot list
local brainrots = {
    "La Vacca Saturno Saturnita","Bisonte Giuppitere","Blackhole Goat","Jackorilla",
    "Agarrini Ia Palini","Chachechi","Karkerkar Kurkur","Los Tortus","Los Matteos",
    "Sammyni Spyderini","Trenostruzzo Turbo 4000","Chimpanzini Spiderini","Boatito Auratito",
    "Fragola La La La","Dul Dul Dul","Frankentteo","Karker Sahur","Torrtuginni Dragonfrutini",
    "Los Tralaleritos","Zombie Tralala","La Cucaracha","Vulturino Skeletono","Guerriro Digitale",
    "Extinct Tralalero","Yess My Examine","Extinct Matteo","Las Tralaleritas","Las Vaquitas Saturnitas",
    "Pumpkin Spyderini","Job Job Job Sahur","Los Karkeritos","Graipuss Medussi","La Vacca Jacko Linterino",
    "Trickolino","Los Spyderinis","Perrito Burrito","1x1x1x1","Los Cucarachas","Cuadramat and Pakrahmatmamat",
    "Los Jobcitos","Nooo My Hotspot","Pot Hotspot","Noo My Examine","Telemorte","La Sahur Combinasion",
    "To To To Sahur","Pirulitoita Bicicletaire","Horegini Boom","Quesadilla Crocodila","Pot Pumpkin",
    "Chicleteira Bicicleteira","Spaghetti Tualetti","Esok Sekolah","Quesadillo Vampiro","Burrito Bandito",
    "Chicleteirina Bicicleteirina","Los Quesadillas","Noo My Candy","Los Nooo My Hotspotsitos",
    "La Grande Combinassion","Rang Ring Bus","Guest 666","Los Chicleteiras","Six Seven","Mariachi Corazoni",
    "Los Burritos","Swag Soda","Los Combinasionas","Fishino Clownino","Tacorita Bicicleta",
    "Nuclearo Dinosauro","Las Sis","La Karkerkar Combinasion","Chillin Chili","Chipso and Queso",
    "Money Money Puggy","Celularcini Viciosini","Los Planitos","Los Mobilis","Los 67",
    "Mieteteira Bicicleteira","La Spooky Grande","Los Spooky Combinasionas","Los Hotspositos","Los Puggies",
    "W or L","Tralaledon","La Extinct Grande Combinasion","Tralaledon","Los Primos","Eviledon","Los Tacoritas",
    "Tang Tang Keletang","Ketupat Kepat","Los Bros","Tictac Sahur","La Supreme Combinasion","Orcaledon",
    "Ketchuru and Musturu","Spooky and Pumpky","Lavadorito Spinito","Los Spaghettis","La Casa Boo",
    "Fragrama and Chocrama","La Secret Combinasion","Burguro and Fryuro","Capitano Moby",
    "Headless Horseman","Strawberry Elephant","Meowl","Tralalero Tralala"
}

-- Main GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrainrotFinderUI"
screenGui.ResetOnSpawn = false
protect(screenGui)
screenGui.Parent = lp.PlayerGui

-- Tween intro
local function tweenIntro(callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0,0,0,4)
    f.Position = UDim2.new(0.5,0,0.5,0)
    f.AnchorPoint = Vector2.new(0.5,0.5)
    f.BackgroundColor3 = Color3.fromRGB(100,45,200)
    f.BorderSizePixel = 0
    f.Parent = screenGui

    local t = Instance.new("TextLabel")
    t.Text = "Solaris Hopper Script"
    t.Size = UDim2.new(1,0,1,0)
    t.Position = UDim2.new(0,0,0,0)
    t.BackgroundTransparency = 1
    t.TextColor3 = Color3.fromRGB(255,255,255)
    t.Font = Enum.Font.GothamBold
    t.TextScaled = true
    t.TextTransparency = 1
    t.Parent = f

    local tw1 = TweenService:Create(f,TweenInfo.new(0.5,Enum.EasingStyle.Quad),{Size=UDim2.new(0,300,0,4)})
    tw1:Play()
    tw1.Completed:Connect(function()
        local tw2 = TweenService:Create(f,TweenInfo.new(0.5,Enum.EasingStyle.Quad),{Size=UDim2.new(0,300,0,80)})
        tw2:Play()
        tw2.Completed:Connect(function()
            local tw3 = TweenService:Create(t,TweenInfo.new(0.5),{TextTransparency=0})
            tw3:Play()
            tw3.Completed:Connect(function()
                task.wait(1)
                local twf = TweenService:Create(f,TweenInfo.new(0.5),{BackgroundTransparency=1})
                local twt = TweenService:Create(t,TweenInfo.new(0.5),{TextTransparency=1})
                twf:Play(); twt:Play()
                twf.Completed:Connect(function()
                    f:Destroy()
                    if callback then callback() end
                end)
            end)
        end)
    end)
end

-- Spawn main menu
function spawnMenu()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 300)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(80, 40, 140)
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true
    frame.Parent = screenGui

    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = UDim.new(0, 12)
    uicorner.Parent = frame

    -- Status label
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, -10, 0, 30)
    statusText.Position = UDim2.new(0, 5, 0, 5)
    statusText.BackgroundTransparency = 1
    statusText.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusText.Font = Enum.Font.GothamBold
    statusText.TextSize = 16
    statusText.TextWrapped = true
    statusText.Text = chosenBrainrot and ("still searching for "..chosenBrainrot.."...") or "select your brainrot (tap name)"
    statusText.Parent = frame

    -- Scroll frame
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -10, 1, -45)
    scroll.Position = UDim2.new(0, 5, 0, 40)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 8
    scroll.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.Parent = scroll

    -- Buttons for each brainrot
    for _, name in ipairs(list) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 25)
        b.BackgroundColor3 = Color3.fromRGB(60, 30, 100)
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Text = name
        b.Font = Enum.Font.Gotham
        b.TextSize = 14
        b.Parent = scroll

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 6)
        corner.Parent = b

        b.MouseButton1Click:Connect(function()
            chosenBrainrot = name
            if writefile then
                saveSelection(name)
            end
            statusText.Text = "still searching for "..chosenBrainrot.."..."
        end)
    end

    -- Update CanvasSize dynamically
    local function updateCanvas()
        local total = layout.AbsoluteContentSize.Y + 10 -- extra padding
        scroll.CanvasSize = UDim2.new(0, 0, 0, total)
    end

    -- Update after layout changes
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    updateCanvas()

    -- Status update functions
    function setSearching() statusText.Text = "still searching for "..chosenBrainrot.."..." end
    function setFound() statusText.Text = "Brainrot Found in current server!" end
end

    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1,-10,0,30)
    statusText.Position = UDim2.new(0,5,0,5)
    statusText.BackgroundTransparency = 1
    statusText.Font = Enum.Font.GothamBold
    statusText.TextSize = 16
    statusText.TextColor3 = Color3.fromRGB(255,255,255)
    statusText.TextWrapped = true
    statusText.Text = chosenBrainrot and ("still searching for "..chosenBrainrot.."...") or "select your brainrot (tap name)"
    statusText.Parent = frame

    -- Scroll frame
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1,-10,1,-45)
    scroll.Position = UDim2.new(0,5,0,40)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 8
    scroll.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    for i,name in ipairs(brainrots) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1,0,0,25)
        b.BackgroundColor3 = Color3.fromRGB(60,30,100)
        b.TextColor3 = Color3.fromRGB(255,255,255)
        b.Font = Enum.Font.Gotham
        b.TextSize = 14
        b.Text = name
        b.Parent = scroll
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0,6)
        corner.Parent = b

        b.MouseButton1Click:Connect(function()
            chosenBrainrot = name
            saveSelection(name)
            statusText.Text = "still searching for "..chosenBrainrot.."..."
        end)
    end

    -- Status functions
    function setSearching() statusText.Text = "still searching for "..chosenBrainrot.."..." end
    function setFound() statusText.Text = "Brainrot Found in current server!" end
    return setSearching,setFound
end

-- Intro then menu
local setSearching,setFound
tweenIntro(function()
    setSearching,setFound = spawnMenu()
end)

-- Brainrot detection
local function plotHasBrainrot(target)
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return false end
    for _,obj in ipairs(plots:GetDescendants()) do
        if obj.Name == target then return true end
    end
    return false
end

-- Server hopping
local PlaceID = game.PlaceId
local nextCursor = ""

local function hopToServer()
    local ok,site = pcall(function()
        local url = "https://games.roblox.com/v1/games/"..PlaceID.."/servers/Public?sortOrder=Asc&limit=100"
        if nextCursor ~= "" then url = url.."&cursor="..nextCursor end
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    if not ok or not site or not site.data then return end
    nextCursor = site.nextPageCursor or ""

    for _,v in ipairs(site.data) do
        if v.playing < v.maxPlayers then
            if queueteleport then
                queueteleport("getgenv().wasTeleported = true; loadstring(game:HttpGet('https://raw.githubusercontent.com/chesslindan-ops/Loeenaoakrbwiwjrjw/main/brainrot.lua'))()")
            end
            TeleportService:TeleportToPlaceInstance(PlaceID,v.id,lp)
            task.wait(0.2)
            if lp.Kick then lp:Kick("Searching for "..chosenBrainrot) end
            return
        end
    end
    if lp.Kick then lp:Kick("No servers available (retrying)...") end
end

-- Main loop
local foundFlag = false
task.spawn(function()
    while not foundFlag do
        task.wait(2)
        if chosenBrainrot and plotHasBrainrot(chosenBrainrot) then
            foundFlag = true
            if setFound then setFound() end
            StarterGui:SetCore("SendNotification",{Title="Brainrot Found",Text=chosenBrainrot,Duration=5})
            break
        end
        if chosenBrainrot then
            if setSearching then setSearching() end
            hopToServer()
        end
    end
end)

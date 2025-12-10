-- Brainrot Finder + Server Hopper (Any Brainrot)
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

-- Remove old GUI
if lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("BrainrotFinderUI") then
    lp.PlayerGui.BrainrotFinderUI:Destroy()
end

-- Brainrot list
local brainrots = {
    "Los Jobcitos","Nooo My Hotspot","Pot Hotspot","Noo My Examine","Telemorte","La Sahur Combinasion","Spaghetti Tualetti","Esok Sekolah","Quesadillo Vampiro","Burrito Bandito",
    "Chicleteirina Bicicleteirina","Los Quesadillas","Noo My Candy","Los Nooo My Hotspotsitos",
    "La Grande Combinassion","Rang Ring Bus","Guest 666","Los Chicleteiras","67","Mariachi Corazoni",
    "Los Burritos","Swag Soda","Los Combinasionas","Fishino Clownino","Tacorita Bicicleta",
    "Nuclearo Dinosauro","Las Sis","La Karkerkar Combinasion","Chillin Chili","Chipso and Queso",
    "Money Money Puggy","Celularcini Viciosini","Los Planitos","Los Mobilis","Los 67",
    "Mieteteira Bicicleteira","La Spooky Grande","Los Spooky Combinasionas","Los Hotspositos","Los Puggies",
    "W or L","Tralaledon","La Extinct Grande Combinasion","Tralaledon","Los Primos","Eviledon","Los Tacoritas",
    "Tang Tang Keletang","Ketupat Kepat","Los Bros","Tictac Sahur","La Supreme Combinasion","Orcaledon",
    "Ketchuru and Musturu","Spooky and Pumpky","Lavadorito Spinito","Los Spaghettis","La Casa Boo",
    "Fragrama and Chocrama","La Secret Combinasion","Burguro and Fryuro","Capitano Moby",
    "Headless Horseman","Strawberry Elephant","Meowl","Tralalero Tralala","Cookie and Milki","Dragon Cannelloni","Garama and Madundung", "La Jolly Grande", "Swag Soda","List List List Sahur"
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
local function spawnMenu()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0,250,0,80)
    frame.Position = UDim2.new(0.5,-125,0,20)
    frame.BackgroundColor3 = Color3.fromRGB(50,50,70)
    frame.ClipsDescendants = true
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = UDim.new(0,12)
    uicorner.Parent = frame

    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1,-10,1,0)
    statusText.Position = UDim2.new(0,5,0,0)
    statusText.BackgroundTransparency = 1
    statusText.TextColor3 = Color3.fromRGB(255,255,255)
    statusText.Font = Enum.Font.GothamBold
    statusText.TextSize = 16
    statusText.TextWrapped = true
    statusText.Text = "Searching for any brainrot..."
    statusText.Parent = frame

    local function setSearching() statusText.Text = "Searching for any brainrot..." end
    local function setFound(name) statusText.Text = "Brainrot found: "..name end
    return setSearching, setFound
end

-- Intro then menu
local setSearching, setFound
local menuReady = false
tweenIntro(function()
    setSearching, setFound = spawnMenu()
    menuReady = true
end)

-- Brainrot detection
local function anyBrainrotDetected()
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return nil end
    for _,obj in ipairs(plots:GetDescendants()) do
        for _,name in ipairs(brainrots) do
            if obj.Name == name then
                return name
            end
        end
    end
    return nil
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
                queueteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/chesslindan-ops/Loeenaoakrbwiwjrjw/main/brainrot.lua'))()")
            end
            TeleportService:TeleportToPlaceInstance(PlaceID,v.id,lp)
            task.wait(0.2)
            if lp.Kick then lp:Kick("Searching for brainrots") end
            return
        end
    end
end

-- Main loop
task.spawn(function()
    repeat task.wait() until menuReady
    while true do
        task.wait(2)
        local found = anyBrainrotDetected()
        if found then
            if setFound then setFound(found) end
            StarterGui:SetCore("SendNotification",{Title="Brainrot Found",Text=found,Duration=5})
            break
        end
        if setSearching then setSearching() end
        hopToServer()
    end
end)

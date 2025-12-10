
-- Brainrot Finder + Server Hopper (Single File)
-- Executor-agnostic (Synapse, Delta, Fluxus)

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local lp = Players.LocalPlayer

---------------------------------------------------------
-- executor-agnostic queue/protect
---------------------------------------------------------
local queueteleport = (syn and syn.queue_on_teleport)
    or queue_on_teleport
    or (fluxus and fluxus.queue_on_teleport)
local protect = (syn and syn.protect_gui) or function(x) return x end

if type(queueteleport) ~= "function" then
    queueteleport = nil
end

---------------------------------------------------------
-- file storage
---------------------------------------------------------
local fileName = "brainrot_selected.json"

local function saveSelection(selection)
    if writefile then
        writefile(fileName, HttpService:JSONEncode({selected = selection}))
    end
end

local function loadSelection()
    if isfile and isfile(fileName) then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        if ok and data then
            return data.selected
        end
    end
    return nil
end

---------------------------------------------------------
-- auto-execute after teleport
---------------------------------------------------------
lp.OnTeleport:Connect(function(State)
    if queueteleport then
        queueteleport(
            "getgenv().wasTeleported = true; loadstring(game:HttpGet('https://raw.githubusercontent.com/chesslindan-ops/Loeenaoakrbwiwjrjw/main/brainrot.lua'))()"
        )
    end
end)

---------------------------------------------------------
-- load selection
---------------------------------------------------------
local chosenBrainrot = loadSelection()

---------------------------------------------------------
-- GUI setup
---------------------------------------------------------
local TweenService = game:GetService("TweenService")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrainrotFinderUI"
screenGui.ResetOnSpawn = false
protect(screenGui)
screenGui.Parent = lp.PlayerGui

---------------------------------------------------------
-- Animated "Hopper Script" intro
---------------------------------------------------------
local introFrame = Instance.new("Frame")
introFrame.Size = UDim2.new(0, 0, 0, 4)
introFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
introFrame.AnchorPoint = Vector2.new(0.5,0.5)
introFrame.BackgroundColor3 = Color3.fromRGB(100, 45, 200)
introFrame.BorderSizePixel = 0
introFrame.Parent = screenGui

local introText = Instance.new("TextLabel")
introText.Text = "Solaris Hopper Script"
introText.Size = UDim2.new(1,0,1,0)
introText.Position = UDim2.new(0,0,0,0)
introText.BackgroundTransparency = 1
introText.TextColor3 = Color3.fromRGB(255,255,255)
introText.Font = Enum.Font.GothamBold
introText.TextScaled = true
introText.TextTransparency = 1
introText.Parent = introFrame

-- Tween animation
local widthTween = TweenService:Create(introFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size=UDim2.new(0,300,0,4)})
widthTween:Play()

widthTween.Completed:Connect(function()
    local heightTween = TweenService:Create(introFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size=UDim2.new(0,300,0,80)})
    heightTween:Play()

    heightTween.Completed:Connect(function()
        local textTween = TweenService:Create(introText, TweenInfo.new(0.5), {TextTransparency=0})
        textTween:Play()

        textTween.Completed:Connect(function()
            task.wait(1)
            local fadeTween = TweenService:Create(introFrame, TweenInfo.new(0.5), {BackgroundTransparency=1})
            local textFadeTween = TweenService:Create(introText, TweenInfo.new(0.5), {TextTransparency=1})
            fadeTween:Play()
            textFadeTween:Play()

            fadeTween.Completed:Connect(function()
                introFrame:Destroy()
                spawnPurpleMenu()
            end)
        end)
    end)
end)

---------------------------------------------------------
-- Main purple menu with scrollable brainrot selection
---------------------------------------------------------
function spawnPurpleMenu()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 300)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(80, 40, 140)
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true

    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = UDim.new(0,12)
    uicorner.Parent = frame
    frame.Parent = screenGui

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -10, 0, 30)
    text.Position = UDim2.new(0, 5, 0, 5)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.Font = Enum.Font.GothamBold
    text.TextSize = 16
    text.TextWrapped = true
    text.Text = chosenBrainrot and ("still searching for "..chosenBrainrot.."...") or "select your brainrot (tap name)"
    text.Parent = frame

    -- Scroll frame
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -10, 1, -45)
    scrollFrame.Position = UDim2.new(0,5,0,40)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.Parent = frame

    local uiList = Instance.new("UIListLayout")
    uiList.SortOrder = Enum.SortOrder.LayoutOrder
    uiList.Parent = scrollFrame

    -- Buttons for each brainrot
    for i, name in ipairs(list) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 25)
        b.BackgroundColor3 = Color3.fromRGB(60,30,100)
        b.TextColor3 = Color3.fromRGB(255,255,255)
        b.Text = name
        b.Font = Enum.Font.Gotham
        b.TextSize = 14
        b.Parent = scrollFrame

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0,6)
        corner.Parent = b

        b.MouseButton1Click:Connect(function()
            chosenBrainrot = name
            saveSelection(name)
            text.Text = "still searching for "..chosenBrainrot.."..."
        end)
    end

    -- Status update functions
    function setSearching() text.Text = "still searching for "..chosenBrainrot.."..." end
    function setFound() text.Text = "Brainrot Found in current server!" end
end
---------------------------------------------------------
-- Brainrot list
---------------------------------------------------------
local list = {
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

---------------------------------------------------------
-- Selection UI
---------------------------------------------------------
if not chosenBrainrot then
    setPickMode()

    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(0,210,0,#list*24)
    buttonFrame.Position = UDim2.new(0,10,0,100)
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = screenGui

    for i,name in ipairs(list) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1,0,0,22)
        b.Position = UDim2.new(0,0,0,(i-1)*24)
        b.BackgroundColor3 = Color3.fromRGB(60,30,100)
        b.TextColor3 = Color3.new(1,1,1)
        b.Text = name
        b.Font = Enum.Font.Gotham
        b.TextSize = 12
        b.Parent = buttonFrame

        b.MouseButton1Click:Connect(function()
            chosenBrainrot = name
            saveSelection(name)
            buttonFrame:Destroy()
            setSearching()
        end)
    end
else
    setSearching()
end

---------------------------------------------------------
-- Brainrot detection
---------------------------------------------------------
local function plotHasBrainrot(target)
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return false end
    for _, obj in ipairs(plots:GetDescendants()) do
        if obj.Name == target then
            return true
        end
    end
    return false
end

---------------------------------------------------------
-- Server hopping
---------------------------------------------------------
local PlaceID = game.PlaceId
local nextCursor = ""

local function hopToServer()
    local ok, site = pcall(function()
        local url = "https://games.roblox.com/v1/games/"..PlaceID.."/servers/Public?sortOrder=Asc&limit=100"
        if nextCursor ~= "" then
            url = url .. "&cursor=" .. nextCursor
        end
        return HttpService:JSONDecode(game:HttpGet(url))
    end)

    if not ok or not site or not site.data then return end
    nextCursor = site.nextPageCursor or ""

    for _, v in ipairs(site.data) do
        if v.playing < v.maxPlayers then
            saveSelection(chosenBrainrot)
            if queueteleport then
                queueteleport(
                    "getgenv().wasTeleported = true; loadstring(game:HttpGet('https://raw.githubusercontent.com/chesslindan-ops/Loeenaoakrbwiwjrjw/main/brainrot.lua'))()"
                )
            end
            TeleportService:TeleportToPlaceInstance(PlaceID,v.id,lp)
            task.wait(0.2)
            if lp.Kick then
                lp:Kick("Searching for "..chosenBrainrot)
            end
            return
        end
    end

    if lp.Kick then
        lp:Kick("No servers available (retrying)...")
    end
end

---------------------------------------------------------
-- Main loop
---------------------------------------------------------
---------------------------------------------------------
-- Main loop
---------------------------------------------------------
local foundFlag = false

task.spawn(function()
    while not foundFlag do
        task.wait(2)
        if chosenBrainrot and plotHasBrainrot(chosenBrainrot) then
            foundFlag = true
            setFound()
            StarterGui:SetCore("SendNotification", {
                Title="Brainrot Found",
                Text=chosenBrainrot,
                Duration=5
            })
            break
        end

        if chosenBrainrot then
            setSearching()
            hopToServer()
        end
    end
end)

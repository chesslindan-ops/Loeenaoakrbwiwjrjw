-- Brainrot Finder + Server Hopper + Webhook Logger
-- Executor-agnostic (Synapse, Delta, Fluxus)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer
local webhookURL = "https://discord.com/api/webhooks/1438255847401853109/CKZIfs3E8DpARr4tPfotzHTorpb5wWRXhODKVzzyqhYXdPc0a8-yxAl3Z17n_bqioXST" -- put your webhook here

-- Executor-agnostic
local queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
local protect = (syn and syn.protect_gui) or function(x) return x end
if type(queueteleport) ~= "function" then queueteleport = nil end

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
    "Headless Horseman","Strawberry Elephant","Meowl","Tralalero Tralala","Cookie and Milki","Dragon Cannelloni","Garama and Madundung", "La Jolly Grande", "Burrito Bandito","List List List Sahur"
}


-- Executor GUI protection
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

-- Main GUI
local chosenBrainrot = nil
local function spawnMenu()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0,220,0,300)
    frame.Position = UDim2.new(0,10,0,10)
    frame.BackgroundColor3 = Color3.fromRGB(80,40,140)
    frame.ClipsDescendants = true
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = UDim.new(0,12)
    uicorner.Parent = frame

    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1,-10,0,30)
    statusText.Position = UDim2.new(0,5,0,5)
    statusText.BackgroundTransparency = 1
    statusText.TextColor3 = Color3.fromRGB(255,255,255)
    statusText.Font = Enum.Font.GothamBold
    statusText.TextSize = 16
    statusText.TextWrapped = true
    statusText.Text = chosenBrainrot and ("still searching for "..chosenBrainrot.."...") or "select your brainrot (tap name)"
    statusText.Parent = frame

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1,-10,1,-45)
    scroll.Position = UDim2.new(0,5,0,40)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 8
    scroll.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0,4)
    layout.Parent = scroll

    for _,name in ipairs(brainrots) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1,0,0,25)
        b.BackgroundColor3 = Color3.fromRGB(60,30,100)
        b.TextColor3 = Color3.fromRGB(255,255,255)
        b.Text = name
        b.Font = Enum.Font.Gotham
        b.TextSize = 14
        b.Parent = scroll

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0,6)
        corner.Parent = b

        b.MouseButton1Click:Connect(function()
            chosenBrainrot = name
            statusText.Text = "still searching for "..chosenBrainrot.."..."
        end)
    end

    local function updateCanvas()
        scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    updateCanvas()
end

-- Server hop logic
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
            if lp.Kick then lp:Kick("Searching for "..(chosenBrainrot or "brainrots")) end
            return
        end
    end
end

-- Webhook sender
local function SendWebhook(url, data)
    local httpRequest = (syn and syn.request) or (housekeeper and housekeeper.request) or (http and http.request) or (http_request) or (fluxus and fluxus.request) or request
    if not httpRequest then return end
    pcall(function()
        httpRequest({
            Url = url,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end)
end

local function logBrainrots(foundList)
    if webhookURL == "" then return end
    local jobId = game.JobId
    local link = "roblox://experiences/start?placeId="..game.PlaceId.."&gameInstanceId="..jobId
    local playerCount = #Players:GetPlayers()

    local payload = {
        embeds = {{
            title = "Brainrots Detected",
            color = 0x00FF00,
            fields = {
                { name = "Brainrots", value = table.concat(foundList, ", "), inline = false },
                { name = "Playing", value = tostring(playerCount), inline = true },
                { name = "Timestamp", value = os.date("!%Y-%m-%d %H:%M:%S UTC"), inline = true },
                { name = "Link", value = link, inline = false }
            }
        }}
    }
    SendWebhook(webhookURL, payload)
end

-- Find all brainrots in server
local function findAllBrainrots()
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return {} end

    local found = {}
    for _, obj in ipairs(plots:GetDescendants()) do
        for _, name in ipairs(brainrots) do
            if obj.Name == name then
                table.insert(found, name)
            end
        end
    end

    return found
end

-- Main loop
tweenIntro(function()
    spawnMenu()

    task.spawn(function()
        task.wait(2)
        while true do
            task.wait(2)
            local foundList = findAllBrainrots()
            if #foundList > 0 then
                StarterGui:SetCore("SendNotification", {
                    Title="Brainrot(s) Found",
                    Text=table.concat(foundList,", "),
                    Duration=5
                })
                logBrainrots(foundList)
                break -- stay in server
            end
            hopToServer() -- nothing found, hop
        end
    end)
end)

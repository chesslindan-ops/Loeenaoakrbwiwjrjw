-- Brainrot Finder + Server Hopper + Webhook
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

local lp = Players.LocalPlayer
local webhookURL = "https://discord.com/api/webhooks/1438255847401853109/CKZIfs3E8DpARr4tPfotzHTorpb5wWRXhODKVzzyqhYXdPc0a8-yxAl3Z17n_bqioXST" -- put your webhook here

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


-- executor-agnostic
local queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
local protect = (syn and syn.protect_gui) or function(x) return x end

-- single button UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BrainrotSingleButtonUI"
screenGui.ResetOnSpawn = false
protect(screenGui)
screenGui.Parent = lp.PlayerGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0,200,0,50)
button.Position = UDim2.new(0,50,0,50)
button.BackgroundColor3 = Color3.fromRGB(100,50,200)
button.TextColor3 = Color3.fromRGB(255,255,255)
button.Text = "Check Brainrots"
button.Font = Enum.Font.GothamBold
button.TextSize = 18
button.Parent = screenGui

-- webhook sender
local function SendWebhook(foundList)
    if webhookURL == "" then return end
    local jobId = game.JobId
    local link = "roblox://experiences/start?placeId="..game.PlaceId.."&gameInstanceId="..jobId
    local payload = {
        embeds = {{
            title = "Brainrots Detected",
            color = 0x00FF00,
            fields = {
                { name = "Brainrots", value = table.concat(foundList, ", "), inline = false },
                { name = "Playing", value = tostring(#Players:GetPlayers()), inline = true },
                { name = "Timestamp", value = os.date("!%Y-%m-%d %H:%M:%S UTC"), inline = true },
                { name = "Link", value = link, inline = false }
            }
        }}
    }
    local httpRequest = (syn and syn.request) or (housekeeper and housekeeper.request) or (http and http.request) or (http_request) or (fluxus and fluxus.request) or request
    if httpRequest then
        pcall(function()
            httpRequest({
                Url = webhookURL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(payload)
            })
        end)
    end
end

-- scan server
local function scanServer()
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

-- hop logic
local PlaceID = game.PlaceId
local nextCursor = ""
local function hopServer()
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
            if lp.Kick then lp:Kick("Searching for brainrots") end
            return
        end
    end
end

-- button logic
button.MouseButton1Click:Connect(function()
    local foundList = scanServer()
    if #foundList > 0 then
        StarterGui:SetCore("SendNotification",{
            Title="Brainrot(s) Found",
            Text=table.concat(foundList,", "),
            Duration=5
        })
        SendWebhook(foundList) -- send hook and stay
    else
        hopServer() -- nothing found, hop
    end
end)

-- Brainrot Finder + Auto Server Hopper
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
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


-- Executor-agnostic queue_on_teleport
local queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
if type(queueteleport) ~= "function" then queueteleport = nil end

-- Webhook
local function SendWebhook(foundList)
    local httpRequest = (syn and syn.request) or (http and http.request) or request
    if not httpRequest then return end

    local payload = {
        embeds = {{
            title = "Brainrot Scan",
            color = 0xAA00FF,
            fields = {
                {name="Brainrots", value=table.concat(foundList,", "), inline=false},
                {name="Playing", value=lp.Name, inline=true},
                {name="Timestamp", value=os.date("!%Y-%m-%d %H:%M:%S UTC"), inline=true},
                {name="Link", value="roblox://experiences/start?placeId="..game.PlaceId.."&gameInstanceId="..game.JobId, inline=false}
            }
        }}
    }

    pcall(function()
        httpRequest({
            Url = webhookURL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(payload)
        })
    end)
end

-- Scan function
local function scanBrainrots()
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

-- Auto teleport then kick
local function hopServer()
    local ok, data = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100"))
    end)
    if not ok or not data or not data.data then return end

    for _, server in ipairs(data.data) do
        if server.id ~= game.JobId and server.playing < server.maxPlayers then
            if queueteleport then
                queueteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/chesslindan-ops/Loeenaoakrbwiwjrjw/refs/heads/main/brainrot.lua'))()")
            end
            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, lp)
            task.wait(0.2)
            if lp.Kick then lp:Kick("Searching for brainrot...") end
            return
        end
    end
end

-- GUI with single button
local screenGui = Instance.new("ScreenGui", lp.PlayerGui)
local button = Instance.new("TextButton")
button.Size = UDim2.new(0,200,0,50)
button.Position = UDim2.new(0.5,-100,0.5,-25)
button.BackgroundColor3 = Color3.fromRGB(100,50,200)
button.TextColor3 = Color3.fromRGB(255,255,255)
button.Text = "Start Scan"
button.Parent = screenGui

button.MouseButton1Click:Connect(function()
    while true do
        task.wait(1)
        local found = scanBrainrots()
        if #found > 0 then
            SendWebhook(found)
            button.Text = "Brainrot Found!"
            break
        else
            hopServer() -- teleport then kick
            break
        end
    end
end)

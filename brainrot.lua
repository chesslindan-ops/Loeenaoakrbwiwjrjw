--// CONFIG
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


local webhookURL = "https://discord.com/api/webhooks/1438255847401853109/CKZIfs3E8DpARr4tPfotzHTorpb5wWRXhODKVzzyqhYXdPc0a8-yxAl3Z17n_bqioXST" -- put your webhook here

--// SERVICES
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local screenGui

--// SIGMA WEBHOOK (mobile safe)
local function SendWebhook(url, data)
    local httpRequest =
        (syn and syn.request)
        or (housekeeper and housekeeper.request)
        or (http and http.request)
        or (http_request)
        or (fluxus and fluxus.request)
        or request

    if not httpRequest then
        warn("no httpRequest available")
        return
    end

    pcall(function()
        httpRequest({
            Url = url,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end)
end

local function sendFoundWebhook(foundList)
    local jobId = game.JobId
    local link = "roblox://experiences/start?placeId="..game.PlaceId.."&gameInstanceId="..jobId

    local payload = {
        embeds = {{
            title = "Brainrot Found",
            color = 0xAA00FF,
            fields = {
                { name = "Player", value = lp.Name, inline = true },
                { name = "Count", value = tostring(#foundList), inline = true },
                { name = "List", value = table.concat(foundList, ", "), inline = false },
                { name = "Server Link", value = link, inline = false },
                { name = "Timestamp", value = os.date("!%Y-%m-%d %H:%M:%S UTC") }
            }
        }}
    }

    SendWebhook(webhookURL, payload)
end


--// SCAN FUNCTION
local function scan()
    local found = {}

    for _,p in ipairs(Players:GetPlayers()) do
        for _,b in ipairs(brainrots) do
            if p.DisplayName:lower():find(b:lower()) or p.Name:lower():find(b:lower()) then
                table.insert(found, b)
            end
        end
    end

    return found
end
--// MAIN LOGIC (fixed and more robust)
local hopping = false

-- helper to safely HttpGet (some executors block game:HttpGet)
local function safeHttpGet(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if not ok then
        -- try alternative (some execs expose http_request)
        if http_request then
            ok, res = pcall(function() return http_request({Url = url, Method = "GET"}).Body end)
        end
    end
    return ok and res or nil, (ok and res) or res
end

local function hopServer()
    local servers = {}
    local cursor = ""

    repeat
        local url = "https://games.roblox.com/v1/games/"..tostring(game.PlaceId).."/servers/Public?limit=100&cursor="..tostring(cursor)
        local raw, err = safeHttpGet(url)
        if not raw then
            warn("hopServer: failed to fetch servers:", err)
            return false, "http_failed"
        end

        local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
        if not ok or not data or not data.data then
            warn("hopServer: bad json or empty data")
            return false, "bad_json"
        end

        for _,s in ipairs(data.data) do
            if s.id ~= game.JobId and (s.playing or 0) < (s.maxPlayers or 0) then
                table.insert(servers, s.id)
            end
        end

        cursor = data.nextPageCursor
    until not cursor or cursor == ""

    if #servers == 0 then
        warn("hopServer: no candidate servers found")
        return false, "no_servers"
    end

    local chosen = servers[math.random(1,#servers)]
    local ok, err = pcall(function()
        -- Try TeleportToPlaceInstance with player param (works in many executors)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, chosen, lp)
    end)

    if not ok then
        warn("TeleportToPlaceInstance failed, trying fallback:", err)
        pcall(function()
            -- fallback attempt (may teleport only caller in some contexts)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, chosen)
        end)
    end

    return true
end

-- Start/stop function wired to button
local function startHopping()
    if hopping then return end
    hopping = true
    btn.Text = "Hopping..."
    status.Text = "Scanning..."

    btn.AutoButtonColor = false
    btn.Active = false

    task.spawn(function()
        while hopping do
            task.wait(1)

            local found = scan()
            if #found > 0 then
                hopping = false
                status.Text = "FOUND!"
                btn.Text = "Done"
                btn.AutoButtonColor = true
                btn.Active = true

                sendFoundWebhook(found)
                return
            end

            status.Text = "No match, hopping..."
            local ok, errcode = hopServer()
            if not ok then
                -- if hop failed we show reason and try again after a short wait
                status.Text = "Hop failed: "..tostring(errcode)
                warn("hop attempt failed:", errcode)
                task.wait(2)
            else
                -- pause briefly; when teleport runs the client will leave this game
                task.wait(0.5)
            end
        end

        -- cleanup when stopping
        btn.AutoButtonColor = true
        btn.Active = true
        if not hopping then
            btn.Text = "Start Server Hop"
            status.Text = "Idle"
        end
    end)
end

-- wire button click (safe connect)
if btn and btn.MouseButton1Click then
    btn.MouseButton1Click:Connect(function()
        -- only start if search is OFF (you asked for UI only when search is not on)
        -- assume `hopping` == search-on; if you have a separate `searchOn` flag substitute it here
        startHopping()
    end)
else
    warn("MAIN LOGIC: `btn` not found or doesn't support MouseButton1Click")
end


--// GUI (cool animated one)
screenGui = Instance.new("ScreenGui")
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false
screenGui.Parent = lp.PlayerGui

-- start tiny and invisible in center
local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.Position = UDim2.new(0.5,0,0.5,0)
frame.Size = UDim2.new(0,5,0,5)
frame.BackgroundColor3 = Color3.fromRGB(60,20,100)
frame.BackgroundTransparency = 1
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

-- title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Text = "Brainrot Hopper"
title.TextTransparency = 1
title.Parent = frame

local status = Instance.new("TextLabel")
status.Position = UDim2.new(0,0,0,30)
status.Size = UDim2.new(1,0,0,20)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(255,255,255)
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.Text = "Idle"
status.TextTransparency = 1
status.Parent = frame

local btn = Instance.new("TextButton")
btn.Position = UDim2.new(0.5,-60,1,-35)
btn.Size = UDim2.new(0,120,0,30)
btn.BackgroundColor3 = Color3.fromRGB(100,50,200)
btn.TextColor3 = Color3.fromRGB(255,255,255)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 14
btn.Text = "Start Server Hop"
btn.AutoButtonColor = true
btn.TextTransparency = 1
btn.BackgroundTransparency = 1
btn.Parent = frame
Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

-- ANIMATION: widen -> grow taller -> fade in
task.spawn(function()
    -- widen horizontally
    frame:TweenSize(UDim2.new(0,260,0,5), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
    task.wait(0.3)

    -- then grow vertically
    frame:TweenSize(UDim2.new(0,260,0,110), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.25, true)
    task.wait(0.25)

    -- fade in elements
    for i = 1, 10 do
        local t = i/10
        frame.BackgroundTransparency = 1 - t
        title.TextTransparency = 1 - t
        status.TextTransparency = 1 - t
        btn.TextTransparency = 1 - t
        btn.BackgroundTransparency = 1 - t
        task.wait(0.03)
    end
end)


--// MAIN LOGIC
btn.MouseButton1Click:Connect(function()
    if hopping then return end
    hopping = true
    btn.Text = "Hopping..."
    status.Text = "Scanning..."

    task.spawn(function()
        while hopping do
            task.wait(1)

            local found = scan()
            if #found > 0 then
                hopping = false
                status.Text = "FOUND!"
                btn.Text = "Done"
                
                sendFoundWebhook(found)
                return
            end

            status.Text = "No match, hopping..."
            hopServer()
        end
    end)
end)

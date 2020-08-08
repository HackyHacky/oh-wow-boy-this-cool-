--[[

    Copyright 2020 Some Admin Remastered Team

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 ██████╗ █████╗ ███╗   ███╗███████╗   █████╗ ██████╗ ███╗   ███╗██╗███╗  ██╗
██╔════╝██╔══██╗████╗ ████║██╔════╝  ██╔══██╗██╔══██╗████╗ ████║██║████╗ ██║
 █████╗ ██║  ██║██╔████╔██║█████╗    ███████║██║  ██║██╔████╔██║██║██╔██╗██║
 ╚═══██╗██║  ██║██║╚██╔╝██║██╔══╝    ██╔══██║██║  ██║██║╚██╔╝██║██║██║╚████║
██████╔╝╚█████╔╝██║ ╚═╝ ██║███████╗  ██║  ██║██████╔╝██║ ╚═╝ ██║██║██║ ╚███║
╚═════╝  ╚════╝ ╚═╝     ╚═╝╚══════╝  ╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝╚═╝╚═╝  ╚══╝

██████╗ ███████╗███╗   ███╗ █████╗  ██████╗████████╗███████╗██████╗ ███████╗██████╗
██╔══██╗██╔════╝████╗ ████║██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗██╔════╝██╔══██╗
██████╔╝█████╗  ██╔████╔██║███████║╚█████╗    ██║   █████╗  ██████╔╝█████╗  ██║  ██║
██╔══██╗██╔══╝  ██║╚██╔╝██║██╔══██║ ╚═══██╗   ██║   ██╔══╝  ██╔══██╗██╔══╝  ██║  ██║
██║  ██║███████╗██║ ╚═╝ ██║██║  ██║██████╔╝   ██║   ███████╗██║  ██║███████╗██████╔╝
╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝╚═════╝    ╚═╝   ╚══════╝╚═╝  ╚═╝╚══════╝╚═════╝

]]--

if not syn then
    warn("This script is Synapse X exclusive.")
    return
end

if not game:IsLoaded() then
    game.Loaded:Wait()
end

if SAR_EXECUTED and not SAR_DEV_MODE then return end

getgenv().SAR_EXECUTED = true
getgenv().SAR_DEV_MODE = true

--<< Services >>--

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")

--<< Variables >>--

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local backPack = player.Backpack

local chat = player:FindFirstChild("PlayerGui"):FindFirstChild("Chat")
local chatBar = nil
local customChat = false

local prefix = ";"
local commands = {}
local commandsInLoop = {}

local COMMAND_LOOP_DELAY = 0.25

if chat then
    pcall(function()
        chatBar = chat.Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar

        print("Found chat bar.")
    end)
else
    customChat = true

    print("Custom chat detected.")
end

print(customChat)

--<< Local Functions >--

local function makeSystemMessage(parameters, loopParameters)
    if not customChat then
        if loopParameters then
            if loopParameters.isLooping then
                StarterGui:SetCore("ChatMakeSystemMessage", {
                    Text = parameters.Text .. " x" .. tostring(loopParameters.loopIndex),
                    Font = parameters.Font,
                    Color = parameters.Color
                })
            else
                StarterGui:SetCore("ChatMakeSystemMessage", {
                    Text = parameters.Text,
                    Font = parameters.Font,
                    Color = parameters.Color
                })
            end
        else
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = parameters.Text,
                Font = parameters.Font,
                Color = parameters.Color
            })
        end
    end
end

local function findPlayer(playerName)
    local players = {}

    if playerName == "all" then
        table.insert(players, Players:GetPlayers())
    elseif playerName == "others" then
        for i, v in pairs(Players:GetPlayers()) do
            if v.UserId ~= player.UserId then
                table.insert(players, v)
            end
        end
    elseif playerName == "me" then
        table.insert(players, player)
    else
        for i, v in pairs(Players:GetPlayers()) do
            if string.lower(string.sub(v.Name, 1, #playerName)) == string.lower(playerName) then
                table.insert(players, v)
            end
        end
    end

    return players
end

local function process_commandArguments(commandArguments, messageCache)
    local returnArguments = {}

    for i, v in pairs(commandArguments) do
        local currentArgument = messageCache[i]

        if v == "bool" or v == "boolean" then
            currentArgument = ((currentArgument == "true" or currentArgument == "on") and true) or false
        elseif v == "number" or v == "speed" then
            currentArgument = tonumber(currentArgument) or 0
        end

        table.insert(returnArguments, currentArgument)
    end

    return returnArguments
end

local function findAliases(commandName, commandAliases)
    if commandAliases and type(commandAliases) == "table" then
        for i, v in pairs(commandAliases) do
            print(i, v)
            if string.lower(v) == string.lower(commandName) then
                return true
            end
        end
    end

    return
end

local function findCommand(commandName)
    for i, v in pairs(commands) do
        if findAliases(commandName, v.Aliases) or string.lower(v.Name) == string.lower(commandName) then
            return v
        end
    end

    return
end

local function parseMessage(message, isToAddHistory)
    local messageCache = {}
    local isLoopCommand = false
    local loopAmount = 1
    local isEndCommand = false

    if string.sub(message, 1, 3) == "/e " then
        message = string.sub(message, 4)
    end

    if string.sub(message, 1, 1) == prefix then
        message = string.sub(message, 2)

        for v in string.gmatch(message, "[^" .. " " .. "]+") do
            table.insert(messageCache, v)
        end

        local commandName = messageCache[1]

        if string.sub(commandName, 1, 4) == "loop" then
            commandName = string.sub(commandName, 5)
            if tonumber(messageCache[#messageCache - 1]) then
                loopAmount = tonumber(messageCache[#messageCache - 1])
            else
                loopAmount = 100
            end

            if tonumber(messageCache[#messageCache]) then
                COMMAND_LOOP_DELAY = tonumber(messageCache[#messageCache])
            else
                COMMAND_LOOP_DELAY = 0.25
            end

            isLoopCommand = true
        end

        if string.sub(commandName, 1, 2) == "un" then
            commandName = string.sub(commandName, 3)

            loopAmount = 1
            isEndCommand = true
        end

        table.remove(messageCache, 1)

        local command = findCommand(commandName)

        if command then
            local arguments = process_commandArguments(command.Args, messageCache)

            if not command.Loopable and loopAmount > 1 then
                loopAmount = 1
            end

            coroutine.wrap(function()
                for i = 1, loopAmount do
                    local success, errorMessage = pcall(function()
                        if command.Args[1] == "player" and not isEndCommand then
                            local players = findPlayer(arguments[1])

                            for x, p in pairs(players) do
                                local args = {p}

                                for z, y in pairs(arguments) do
                                    table.insert(args, y)
                                end

                                command.Run(args, command, {isLooping = isLoopCommand, loopIndex = i})
                            end
                        else
                            if not isEndCommand then
                                command.Run(arguments, command, {isLooping = isLoopCommand, loopIndex = i})
                            elseif isEndCommand and type(command.End) == "function" then
                                command.End(arguments, command, {isLooping = isLoopCommand, loopIndex = i})
                            end
                        end
                    end)

                    if not success then
                        warn(errorMessage)
                    end

                    if COMMAND_LOOP_DELAY > 0 then
                        wait(COMMAND_LOOP_DELAY)
                    else
                        RunService.Heartbeat:Wait()
                    end
                end
            end)()
        else
            warn("Command: " .. commandName .. " does not exist.")
        end
    end
end

--<< Functions >>--

player.CharacterAdded:Connect(function(char)
    character = char
end)

if not customChat then
    local chatHookFunction = chatBar.FocusLost:Connect(function(enterPressed)
        print(enterPressed)

        if enterPressed and chatBar.Text ~= "" then
            local message = chatBar.Text

            print(message)

            if string.sub(message, 1, 1) == prefix or string.sub(message, 1, 4) == "/e " .. prefix then
                chatBar.Text = ""
            end

            parseMessage(message)
        end
    end)

    pcall(function()
        chat.Frame.ChatBarParentFrame.ChildAdded:Connect(function(instance)
            if instance:FindFirstChild("BoxFrame") then
                if chatHookFunction then
                    chatHookFunction:Disconnect()
                end

                chatHookFunction = chatBar.FocusLost:Connect(function(enterPressed)
                    print(enterPressed)
            
                    if enterPressed then
                        local message = chatBar.Text
            
                        print(message)
            
                        if string.sub(message, 1, 1) == prefix or string.sub(message, 1, 4) == "/e " .. prefix then
                            chatBar.Text = ""
                        end
            
                        parseMessage(message)
                    end
                end)
            end
        end)
    end)
end

--<< Commands >>--

commands = {
    {
        Name = "WalkSpeed",
        Aliases = {"ws"},
        Loopable = true,
        Description = "Sets your WalkSpeed to <num>",
        ReturnMessage = "Changed WalkSpeed to ",
        Args = {"number"},
        Run = function(args, self, loopParameters)
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = tonumber(args[1])
            end

            makeSystemMessage({Text = self.ReturnMessage .. tostring(args[1]), Font = Enum.Font.SourceSansBold, Color = Color3.fromRGB(255, 255, 255)}, loopParameters)
        end
    },
    {
        Name = "JumpPower",
        Aliases = {"jp"},
        Loopable = true,
        Description = "Sets your JumpPower to <num>",
        ReturnMessage = "Changed JumpPower to ",
        Args = {"number"},
        Run = function(args, self, loopParameters)
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.JumpPower = tonumber(args[1])
            end

            makeSystemMessage({Text = self.ReturnMessage .. tostring(args[1]), Font = Enum.Font.SourceSansBold, Color = Color3.fromRGB(255, 255, 255)}, loopParameters)
        end
    },
    {
        Name = "Goto",
        Aliases = {"to"},
        Loopable = true,
        Description = "Teleports you to <player>",
        ReturnMessage = "Teleported to ",
        Args = {"player"},
        Run = function(args, self, loopParameters)
            local targetPlayer = args[1]

            if targetPlayer then
                if targetPlayer.Character then
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if rootPart and targetRoot then
                        rootPart.CFrame = targetRoot.CFrame + Vector3.new(0, 0, 3)
                    end
                end

                makeSystemMessage({Text = self.ReturnMessage .. targetPlayer.Name, Font = Enum.Font.SourceSansBold, Color = Color3.fromRGB(255, 255, 255)}, loopParameters)
            end
        end
    },
    {
        Name = "Rejoin",
        Aliases = {"rj"},
        Loopable = false,
        Description = "Makes you rejoin the current game.",
        ReturnMessage = "Rejoining server...",
        Args = {},
        Run = function(args, self)
            makeSystemMessage({Text = self.ReturnMessage, Font = Enum.Font.SourceSansBold, Color = Color3.fromRGB(255, 255, 255)})

            wait(2)

            TeleportService:Teleport(game.PlaceId)
        end
    }
}

--<< Synapse Stuff >>--

if not SAR_DEV_MODE then
    syn.queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/HackyHacky/oh-wow-boy-this-cool-/master/stinky.lua"))()')
end
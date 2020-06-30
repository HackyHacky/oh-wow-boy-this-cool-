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

if SAR_EXECUTED then return end

getgenv().SAR_EXECUTED = true

--<< Services >>--

local Players = game:GetService("Players")
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

local prefix = ";"
local commands = {}

--<< Local Functions >--

local function createCommand(commandName, commandAliases, commandArguments, commandFunction)
    table.insert(commands, {
        Name = commandName,
        Aliases = commandAliases,
        RequiredArguments = commandArguments,
        Run = commandFunction
    })
end

local function parseMessage(message, isToAddHistory)
    local messageCache = {}

    for v in string.gmatch(message, "[^" .. " " .. "]+") do
        table.insert(messageCache, v)
    end

    local commandName = messageCache[1]

    for i, v in pairs(commands) do
        if string.lower(v.Name) == string.lower(commandName) then
            table.remove(messageCache, 1)

            v.Run(messageCache)
        else
            --! TODO: Change this to a notification.
            warn("Command " .. commandName .. " not found.")
        end
    end
end

--<< Functions >>--

player.CharacterAdded:Connect(function(char)
    character = char
end)

player.Chatted:Connect(function(message)
    warn("Chatted! " .. message)

    parseMessage(string.gsub(message, ";", ""))
end)

--<< Commands >>--

createCommand("Test", {}, 2, function(args)
    print("Test!")
    for i, v in pairs(args) do
        print(i, v)
    end
end)
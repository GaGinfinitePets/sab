-- Steal a Brainrot Autopurchase & Spam E Script - Simulation Key Press Réelle
-- Amélioré par Grok - Utilise VirtualInputManager pour vrai spam E (fix non-clic), Hotkey F pour toggle (fix UI non-affichée)
-- Version: 8.0 (19 Octobre 2025) - Fonctionnel Delta, Garde achat direct, Spam E toutes 0.2s quand activé
-- Instructions: Exécutez le script. Appuyez sur F pour toggle spam E (print confirme ON/OFF). Spam active prompts comme vrai E.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- Configuration Auto-Buy
local MIN_MONEY = 50
local PURCHASE_DELAY = 1

-- Configuration Spam E
local SPAM_ENABLED = false
local SPAM_DELAY = 0.2  -- Interval 0.2s

-- Debug
local function debugPrint(message)
    print("[Script Debug] " .. message)
end

-- Argent
local function getCurrentMoney()
    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        local cash = leaderstats:FindFirstChild("Cash") or leaderstats:FindFirstChild("Money")
        if cash then return cash.Value end
    end
    for _, gui in pairs(playerGui:GetDescendants()) do
        if gui:IsA("TextLabel") and gui.Text:find("%$%d+") and not gui.Text:lower():find("buy") then
            return tonumber(gui.Text:gsub("[^%d]", "")) or 0
        end
    end
    return 0
end

-- Find Buy Prompt
local function findBuyPrompt()
    local candidates = {"Conveyor", "RedConveyor", "BuyConveyor", "BrainrotConveyor"}
    for _, name in ipairs(candidates) do
        local obj = Workspace:FindFirstChild(name)
        if obj and obj:IsA("BasePart") then
            local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
            if prompt then return prompt end
        end
    end
    for _, desc in pairs(Workspace:GetDescendants()) do
        if desc:IsA("ProximityPrompt") and desc.Parent:IsA("BasePart") and
           (desc.Name:lower():find("buy") or desc.Name:lower():find("conveyor") or desc.Name:lower():find("spawn")) then
            return desc
        end
    end
    return nil
end

-- Init Prompts Instant
local function initPrompts()
    for _, prompt in pairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then prompt.HoldDuration = 0 end
    end
    Workspace.DescendantAdded:Connect(function(desc)
        if desc:IsA("ProximityPrompt") then desc.HoldDuration = 0 end
    end)
end

-- Auto-Buy Loop (achat direct)
local function autoBuyLoop()
    while true do
        local money = getCurrentMoney()
        if money >= MIN_MONEY then
            local prompt = findBuyPrompt()
            if prompt then
                hrp.CFrame = prompt.Parent.CFrame + Vector3.new(0, 3, 0)
                wait(0.1)
                fireproximityprompt(prompt)
                debugPrint("Achat direct! Argent: " .. money)
            end
        end
        wait(PURCHASE_DELAY)
    end
end

-- Spam E Simulation (vrai key press)
local function spamELoop()
    spawn(function()
        while SPAM_ENABLED do
            -- Simule press E
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            wait(0.05)  -- Temps press
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            debugPrint("E spammé (simulation key)!")
            wait(SPAM_DELAY - 0.05)
        end
    end)
end

-- Hotkey Toggle (appui F)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F then
        SPAM_ENABLED = not SPAM_ENABLED
        debugPrint("Spam E togglé: " .. (SPAM_ENABLED and "ON" or "OFF"))
        if SPAM_ENABLED then
            spamELoop()
        end
    end
end)

-- Init
initPrompts()
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    hrp = newChar:WaitForChild("HumanoidRootPart")
end)
spawn(autoBuyLoop)

debugPrint("Script chargé! Appuyez sur F pour toggle spam E (check Output pour ON/OFF). Auto-buy actif. Si pas de clic, assurez-vous d'être près d'un prompt.")

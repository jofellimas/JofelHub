local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local jogadorLocal = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- ==========================================
-- CONFIGURAÇÕES GLOBAIS
-- ==========================================
local CONFIG = {
    EspAtivado = true,
    AimbotAtivado = true,
    MostrarFOV = false,
    FovRaio = 75
}

-- Cores do ESP
local COR_BRANCA = Color3.fromRGB(255, 255, 255)
local COR_VERMELHA = Color3.fromRGB(255, 75, 75)
local COR_AZUL = Color3.fromRGB(75, 150, 255)

local TRANSPARENCIA_NORMAL = 1 
local TRANSPARENCIA_FRACA = 1 
local TRANSPARENCIA_FORTE = 0.7 

-- Variáveis de Cache e Otimização
local FOV_RAIO_QUADRADO = CONFIG.FovRaio * CONFIG.FovRaio
local centroDaTela = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    centroDaTela = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
end)

local armasDosJogadores = {} 
local minhaArmaEquipada = nil
local personagensRevelados = setmetatable({}, {__mode = "k"})

-- ==========================================
-- CRIANDO A INTERFACE PREMIUM
-- ==========================================
local guiName = "AimbotMenuUI"
local parentGui = (RunService:IsStudio() and jogadorLocal:WaitForChild("PlayerGui")) or CoreGui
if parentGui:FindFirstChild(guiName) then parentGui[guiName]:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = guiName
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentGui

-- Círculo de FOV
local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, CONFIG.FovRaio * 2, 0, CONFIG.FovRaio * 2)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = CONFIG.MostrarFOV
FOVCircle.Parent = ScreenGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Color3.fromRGB(255, 255, 255)
FOVStroke.Thickness = 1.5
FOVStroke.Transparency = 0.6
FOVStroke.Parent = FOVCircle

-- Janela Principal (MainFrame)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 270)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -135)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 45, 55)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Position = UDim2.new(0, 0, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "MENU HUB"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Parent = MainFrame

-- Dica de Atalho
local Hint = Instance.new("TextLabel")
Hint.Size = UDim2.new(1, 0, 0, 15)
Hint.Position = UDim2.new(0, 0, 0, 25)
Hint.BackgroundTransparency = 1
Hint.Text = "Aperte [INS] para ocultar"
Hint.Font = Enum.Font.Gotham
Hint.TextColor3 = Color3.fromRGB(120, 120, 130)
Hint.TextSize = 11
Hint.Parent = MainFrame

local Separator = Instance.new("Frame")
Separator.Size = UDim2.new(0.85, 0, 0, 1)
Separator.Position = UDim2.new(0.075, 0, 0, 50)
Separator.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
Separator.BorderSizePixel = 0
Separator.Parent = MainFrame

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 1, -60)
ContentFrame.Position = UDim2.new(0, 0, 0, 60)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ContentFrame
UIListLayout.Padding = UDim.new(0, 12)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Função de Interruptor Deslizante
local function criarTogglePremium(texto, variavelConfig, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0.85, 0, 0, 42)
    Frame.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
    Frame.Parent = ContentFrame

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.65, 0, 1, 0)
    Label.Position = UDim2.new(0.08, 0, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = texto
    Label.Font = Enum.Font.GothamMedium
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ToggleBg = Instance.new("TextButton")
    ToggleBg.Size = UDim2.new(0, 44, 0, 22)
    ToggleBg.Position = UDim2.new(0.95, -44, 0.5, -11)
    ToggleBg.BackgroundColor3 = CONFIG[variavelConfig] and Color3.fromRGB(65, 200, 115) or Color3.fromRGB(60, 60, 70)
    ToggleBg.Text = ""
    ToggleBg.AutoButtonColor = false
    ToggleBg.Parent = Frame

    local BgCorner = Instance.new("UICorner")
    BgCorner.CornerRadius = UDim.new(1, 0)
    BgCorner.Parent = ToggleBg

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = CONFIG[variavelConfig] and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.Parent = ToggleBg

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    ToggleBg.MouseButton1Click:Connect(function()
        CONFIG[variavelConfig] = not CONFIG[variavelConfig]
        local estado = CONFIG[variavelConfig]
        
        local goalBgColor = estado and Color3.fromRGB(65, 200, 115) or Color3.fromRGB(60, 60, 70)
        local goalKnobPos = estado and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        
        TweenService:Create(ToggleBg, tweenInfo, {BackgroundColor3 = goalBgColor}):Play()
        TweenService:Create(Knob, tweenInfo, {Position = goalKnobPos}):Play()
        
        if callback then callback(estado) end
    end)
end

-- CORREÇÃO: Remove o ESP na hora exata em que o botão é desligado
criarTogglePremium("ESP Highlights", "EspAtivado", function(estado)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Highlight") and (obj.Name == "PlayerHighlight" or obj.Name == "DropHighlight") then
            obj.Enabled = estado -- Desliga completamente o highlight de forma instantânea
        end
    end
end)

criarTogglePremium("Instant Aimbot", "AimbotAtivado")

criarTogglePremium("Mostrar FOV", "MostrarFOV", function(estado)
    FOVCircle.Visible = estado
end)

-- ==========================================
-- CORREÇÃO: ESCONDER APENAS O MENU (TECLA INSERT)
-- ==========================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end 
    
    if input.KeyCode == Enum.KeyCode.Insert then
        -- Agora ele esconde apenas o MainFrame, deixando o Círculo FOV na tela!
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ==========================================
-- LÓGICA DO SCRIPT (INTEGRADA)
-- ==========================================
local function verificarInventario(jogador)
    local char = jogador.Character
    local backpack = jogador:FindFirstChild("Backpack")
    
    local temFaca = (char and char:FindFirstChild("Knife")) or (backpack and backpack:FindFirstChild("Knife"))
    local temArma = (char and char:FindFirstChild("Gun")) or (backpack and backpack:FindFirstChild("Gun"))
    
    if temFaca then return "Knife" end
    if temArma then return "Gun" end
    return nil
end

local function atualizarHighlightVisual(jogador, arma)
    if not jogador.Character then return end
    
    local char = jogador.Character
    local highlight = char:FindFirstChild("PlayerHighlight")
    
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "PlayerHighlight"
        highlight.Parent = char
    end

    -- CORREÇÃO: Garante que o Highlight obedeça ao estado do botão no menu
    highlight.Enabled = CONFIG.EspAtivado
    
    -- Se o ESP estiver desligado no menu, ele não precisa atualizar as cores
    if not CONFIG.EspAtivado then return end

    local estaEquipado = false
    if arma == "Knife" and char:FindFirstChild("Knife") then estaEquipado = true
    elseif arma == "Gun" and char:FindFirstChild("Gun") then estaEquipado = true end

    if estaEquipado then personagensRevelados[char] = true end

    local transparenciaAtual = personagensRevelados[char] and TRANSPARENCIA_FORTE or TRANSPARENCIA_FRACA

    if arma == "Knife" then
        highlight.FillColor = COR_VERMELHA
        highlight.OutlineColor = COR_VERMELHA
        highlight.FillTransparency = transparenciaAtual
    elseif arma == "Gun" then
        highlight.FillColor = COR_AZUL
        highlight.OutlineColor = COR_AZUL
        highlight.FillTransparency = transparenciaAtual
    else
        highlight.FillColor = COR_BRANCA
        highlight.OutlineColor = COR_BRANCA
        highlight.FillTransparency = TRANSPARENCIA_NORMAL
    end
end

-- Loop do ESP em Background
task.spawn(function()
    while task.wait(0.5) do
        minhaArmaEquipada = verificarInventario(jogadorLocal)
        
        for _, jogador in ipairs(Players:GetPlayers()) do
            local armaDetectada = verificarInventario(jogador)
            armasDosJogadores[jogador] = armaDetectada
            
            if jogador ~= jogadorLocal then
                atualizarHighlightVisual(jogador, armaDetectada)
            end
        end
    end
end)

-- Sistema de Drops
local function verificarDrop(objeto)
    if objeto.Name == "GunDrop" and not objeto:FindFirstChild("DropHighlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "DropHighlight"
        highlight.FillColor = COR_AZUL
        highlight.OutlineColor = COR_AZUL
        highlight.FillTransparency = 0.5
        highlight.Enabled = CONFIG.EspAtivado
        highlight.Parent = objeto
    end
end

Workspace.DescendantAdded:Connect(function(objeto)
    if objeto.Name == "GunDrop" then verificarDrop(objeto) end
end)

-- Loop do Aimbot
-- Loop do Aimbot
RunService.RenderStepped:Connect(function()
    -- Verifica se o Aimbot está ativado, se o jogador tem um personagem e se tem um papel definido
    if not CONFIG.AimbotAtivado or not minhaArmaEquipada or not jogadorLocal.Character then return end

    -- 1. Verifica se está segurando o botão direito do mouse
    local segurandoBotaoDireito = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)

    -- 2. Verifica se tem alguma ferramenta (arma/faca) equipada NA MÃO (dentro do Character)
    local algoEquipadoNaMao = jogadorLocal.Character:FindFirstChildOfClass("Tool")

    -- Se NÃO estiver segurando o botão direito OU NÃO tiver nada na mão, não faz nada
    if not segurandoBotaoDireito or not algoEquipadoNaMao then return end

    local armaDoInimigo = (minhaArmaEquipada == "Knife") and "Gun" or "Knife"
    local alvoMaisProximo = nil
    local menorDistanciaQuad = FOV_RAIO_QUADRADO

    for _, outroJogador in ipairs(Players:GetPlayers()) do
        if outroJogador ~= jogadorLocal and armasDosJogadores[outroJogador] == armaDoInimigo then
            local char = outroJogador.Character
            if char then
                local rootPart = char:FindFirstChild("HumanoidRootPart")
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                
                if rootPart and humanoid and humanoid.Health > 0 then
                    local posicaoNaTela, estaNaTela = camera:WorldToViewportPoint(rootPart.Position)
                    
                    if estaNaTela then
                        local distQuad = (posicaoNaTela.X - centroDaTela.X)^2 + (posicaoNaTela.Y - centroDaTela.Y)^2
                        
                        if distQuad < menorDistanciaQuad then
                            menorDistanciaQuad = distQuad
                            alvoMaisProximo = rootPart
                        end
                    end
                end
            end
        end
    end

    if alvoMaisProximo then
        camera.CFrame = CFrame.lookAt(camera.CFrame.Position, alvoMaisProximo.Position)
    end
end)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- == CONFIGURAÇÕES GERAIS ==
local ESP_ATIVO = true
local AIMBOT_ATIVO = true
local MOSTRAR_FOV = true
local RAIO_FOV = 75 
local MENU_ABERTO = true

local mirando = false
local alvoAtual = nil -- A mágica do "Aim Sticky" (Travar no alvo)

-- === 1. CRIAR O PAINEL DE CONTROLE PREMIUM (UI) ===
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local painelGui = Instance.new("ScreenGui")
painelGui.Name = "PainelAimbotPremium"
painelGui.ResetOnSpawn = false
painelGui.Parent = PlayerGui

local framePrincipal = Instance.new("Frame")
framePrincipal.Size = UDim2.new(0, 240, 0, 310)
framePrincipal.AnchorPoint = Vector2.new(0.5, 0.5) 
framePrincipal.Position = UDim2.new(0.5, 0, 0.5, 0)
framePrincipal.BackgroundColor3 = Color3.fromRGB(20, 20, 25) -- Fundo escuro premium
framePrincipal.BorderSizePixel = 0
framePrincipal.ClipsDescendants = true
framePrincipal.Active = true 
framePrincipal.Parent = painelGui

local uiCornerMenu = Instance.new("UICorner")
uiCornerMenu.CornerRadius = UDim.new(0, 10)
uiCornerMenu.Parent = framePrincipal

local uiStrokeMenu = Instance.new("UIStroke")
uiStrokeMenu.Color = Color3.fromRGB(60, 60, 75)
uiStrokeMenu.Thickness = 1
uiStrokeMenu.Parent = framePrincipal

-- TopBar (Área de arrastar)
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
topBar.BorderSizePixel = 0
topBar.Parent = framePrincipal

local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1, 0, 1, 0)
titulo.BackgroundTransparency = 1
titulo.Text = "  AIMBOT PAINEL"
titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
titulo.Font = Enum.Font.GothamBold
titulo.TextSize = 14
titulo.TextXAlignment = Enum.TextXAlignment.Left
titulo.Parent = topBar

local subTitulo = Instance.new("TextLabel")
subTitulo.Size = UDim2.new(1, -10, 1, 0)
subTitulo.BackgroundTransparency = 1
subTitulo.Text = "[ INS ]"
subTitulo.TextColor3 = Color3.fromRGB(150, 150, 150)
subTitulo.Font = Enum.Font.Gotham
subTitulo.TextSize = 12
subTitulo.TextXAlignment = Enum.TextXAlignment.Right
subTitulo.Parent = topBar

local containerLista = Instance.new("Frame")
containerLista.Size = UDim2.new(1, 0, 1, -40)
containerLista.Position = UDim2.new(0, 0, 0, 40)
containerLista.BackgroundTransparency = 1
containerLista.Parent = framePrincipal

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 15)
padding.PaddingLeft = UDim.new(0, 15)
padding.PaddingRight = UDim.new(0, 15)
padding.Parent = containerLista

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 12)
listLayout.Parent = containerLista

-- === SISTEMA PARA ARRASTAR O MENU PELA TOPBAR ===
local arrastando = false
local posicaoMouseInicio
local posicaoFrameInicio

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        arrastando = true
        posicaoMouseInicio = input.Position
        posicaoFrameInicio = framePrincipal.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then arrastando = false end
        end)
    end
end)

topBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if arrastando then
            local delta = input.Position - posicaoMouseInicio
            framePrincipal.Position = UDim2.new(posicaoFrameInicio.X.Scale, posicaoFrameInicio.X.Offset + delta.X, posicaoFrameInicio.Y.Scale, posicaoFrameInicio.Y.Offset + delta.Y)
        end
    end
end)

-- === FUNÇÃO PARA CRIAR SWITCHES ANIMADOS ===
local corAtivado = Color3.fromRGB(114, 137, 218) -- Roxo azulado Premium (Discord style)
local corDesativado = Color3.fromRGB(50, 50, 60)

local function criarSwitchUI(nome, estadoInicial, callback)
    local linha = Instance.new("Frame")
    linha.Size = UDim2.new(1, 0, 0, 30)
    linha.BackgroundTransparency = 1
    linha.Parent = containerLista

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = nome
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = linha

    local switchBg = Instance.new("TextButton")
    switchBg.Size = UDim2.new(0, 44, 0, 22)
    switchBg.Position = UDim2.new(1, -44, 0.5, -11)
    switchBg.BackgroundColor3 = estadoInicial and corAtivado or corDesativado
    switchBg.Text = ""
    switchBg.Parent = linha
    Instance.new("UICorner", switchBg).CornerRadius = UDim.new(1, 0)

    local bolinha = Instance.new("Frame")
    bolinha.Size = UDim2.new(0, 18, 0, 18)
    bolinha.Position = estadoInicial and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    bolinha.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    bolinha.Parent = switchBg
    Instance.new("UICorner", bolinha).CornerRadius = UDim.new(1, 0)

    local estado = estadoInicial
    switchBg.MouseButton1Click:Connect(function()
        estado = not estado
        local alvoPos = estado and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        local alvoCor = estado and corAtivado or corDesativado
        
        TweenService:Create(bolinha, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = alvoPos}):Play()
        TweenService:Create(switchBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = alvoCor}):Play()
        callback(estado)
    end)
end

criarSwitchUI("ESP Visual", ESP_ATIVO, function(v) ESP_ATIVO = v end)
criarSwitchUI("Aim Assist", AIMBOT_ATIVO, function(v) AIMBOT_ATIVO = v end)
criarSwitchUI("Mostrar FOV", MOSTRAR_FOV, function(v) MOSTRAR_FOV = v end)

-- === INPUT DE FOV MODERNO ===
local fovLinha = Instance.new("Frame")
fovLinha.Size = UDim2.new(1, 0, 0, 50)
fovLinha.BackgroundTransparency = 1
fovLinha.Parent = containerLista

local labelFov = Instance.new("TextLabel")
labelFov.Size = UDim2.new(1, 0, 0, 20)
labelFov.BackgroundTransparency = 1
labelFov.Text = "Tamanho do FOV (Raio)"
labelFov.TextColor3 = Color3.fromRGB(180, 180, 180)
labelFov.Font = Enum.Font.Gotham
labelFov.TextSize = 12
labelFov.TextXAlignment = Enum.TextXAlignment.Left
labelFov.Parent = fovLinha

local inputFov = Instance.new("TextBox")
inputFov.Size = UDim2.new(1, 0, 0, 30)
inputFov.Position = UDim2.new(0, 0, 0, 20)
inputFov.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
inputFov.Text = tostring(RAIO_FOV)
inputFov.TextColor3 = corAtivado
inputFov.Font = Enum.Font.GothamBold
inputFov.TextSize = 14
inputFov.Parent = fovLinha

Instance.new("UICorner", inputFov).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", inputFov).Color = Color3.fromRGB(50, 50, 60)

inputFov.FocusLost:Connect(function()
    local novoValor = tonumber(inputFov.Text)
    if novoValor and novoValor > 0 then
        RAIO_FOV = novoValor
    else
        inputFov.Text = tostring(RAIO_FOV) 
    end
end)

UserInputService.InputBegan:Connect(function(input, processado)
    if not processado and input.KeyCode == Enum.KeyCode.Insert then
        MENU_ABERTO = not MENU_ABERTO
        framePrincipal.Visible = MENU_ABERTO
    end
end)


-- === 2. CRIAR O CÍRCULO DO MOUSE NA TELA ===
local fovGui = Instance.new("ScreenGui")
fovGui.Name = "AimAssistFOV"
fovGui.IgnoreGuiInset = true 
fovGui.Parent = PlayerGui

local circuloHitbox = Instance.new("Frame")
circuloHitbox.Name = "CirculoFOV"
circuloHitbox.AnchorPoint = Vector2.new(0.5, 0.5) 
circuloHitbox.BackgroundTransparency = 1 
circuloHitbox.Parent = fovGui
Instance.new("UICorner", circuloHitbox).CornerRadius = UDim.new(1, 0) 

local uiStrokeCirculo = Instance.new("UIStroke")
uiStrokeCirculo.Color = Color3.new(1, 1, 1) 
uiStrokeCirculo.Thickness = 1
uiStrokeCirculo.Transparency = 0.5 
uiStrokeCirculo.Parent = circuloHitbox


-- === 3. LÓGICA DE INIMIGOS E ESP (MANTIDO) ===
local function deveDestacar(jogadorAlvo)
    if jogadorAlvo == LocalPlayer then return false end
    local meuTime = LocalPlayer.Team
    local timeAlvo = jogadorAlvo.Team
    if not meuTime or not timeAlvo then return false end

    local meuNome = meuTime.Name
    local alvoNome = timeAlvo.Name

    if meuNome == "Police" and alvoNome == "Criminal" then return true end
    if meuNome == "Criminal" and alvoNome == "Police" then return true end
    if meuNome == "Prisoner" and alvoNome == "Police" then return true end

    return false
end

local function atualizarJogador(jogadorAlvo)
    if jogadorAlvo == LocalPlayer then return end
    local personagem = jogadorAlvo.Character
    if not personagem then return end
    local cabeca = personagem:FindFirstChild("Head")
    if not cabeca then return end 

    local highlight = personagem:FindFirstChild("InimigoHighlight")
    local gui = personagem:FindFirstChild("NomeInimigoGui")

    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "InimigoHighlight"
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Enabled = false 
        highlight.Parent = personagem
    end

    if not gui then
        gui = Instance.new("BillboardGui")
        gui.Name = "NomeInimigoGui"
        gui.Adornee = cabeca
        gui.Size = UDim2.new(0, 100, 0, 40)
        gui.StudsOffset = Vector3.new(0, 10, 0)
        gui.AlwaysOnTop = true
        gui.Enabled = false 
        
        local textoNome = Instance.new("TextLabel")
        textoNome.Name = "Texto"
        textoNome.Size = UDim2.new(1, 0, 1, 0)
        textoNome.BackgroundTransparency = 1
        textoNome.TextStrokeTransparency = 0
        textoNome.Font = Enum.Font.GothamBold
        textoNome.TextSize = 12
        textoNome.Parent = gui
        gui.Parent = personagem
    end

    if ESP_ATIVO and deveDestacar(jogadorAlvo) then
        local corDoTime = jogadorAlvo.Team.TeamColor.Color
        highlight.FillColor = corDoTime
        highlight.Enabled = true
        local textoNome = gui:FindFirstChild("Texto")
        if textoNome then
            textoNome.Text = jogadorAlvo.Name
            textoNome.TextColor3 = corDoTime
        end
        gui.Enabled = true
    else
        highlight.Enabled = false
        gui.Enabled = false
    end
end

local function atualizarTodos()
    for _, jogador in ipairs(Players:GetPlayers()) do atualizarJogador(jogador) end
end

LocalPlayer:GetPropertyChangedSignal("Team"):Connect(atualizarTodos)
local function configurarJogador(jogador)
    jogador:GetPropertyChangedSignal("Team"):Connect(function() atualizarJogador(jogador) end)
    jogador.CharacterAdded:Connect(function()
        task.defer(function() task.wait(0.5) atualizarJogador(jogador) end)
    end)
    if jogador.Character then atualizarJogador(jogador) end
end

Players.PlayerAdded:Connect(configurarJogador)
for _, jogador in ipairs(Players:GetPlayers()) do
    if jogador ~= LocalPlayer then configurarJogador(jogador) end
end

task.spawn(function()
    while task.wait(1) do atualizarTodos() end
end)


-- === 4. SISTEMA DE MIRA: STICKY AIM (TRAVA FORTE) ===
local function estaSentado()
    local personagem = LocalPlayer.Character
    if personagem then
        local humanoid = personagem:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Sit then return true end
    end
    return false
end

-- Pega o inimigo MAIS PROXIMO do mouse dentro do FOV
local function pegarInimigoNoFov(posicaoMouse)
    local inimigoMaisProximo = nil
    local menorDistancia2D = RAIO_FOV

    for _, jogador in ipairs(Players:GetPlayers()) do
        if deveDestacar(jogador) then
            local personagemAlvo = jogador.Character
            if personagemAlvo then
                local humanoid = personagemAlvo:FindFirstChildOfClass("Humanoid")
                local torso = personagemAlvo:FindFirstChild("HumanoidRootPart") 

                if humanoid and humanoid.Health > 0 and torso then
                    local posTela, naTela = Camera:WorldToViewportPoint(torso.Position)
                    if naTela then
                        local posInimigo2D = Vector2.new(posTela.X, posTela.Y)
                        local distanciaDoMouse = (posInimigo2D - posicaoMouse).Magnitude

                        if distanciaDoMouse < menorDistancia2D then
                            menorDistancia2D = distanciaDoMouse
                            inimigoMaisProximo = torso
                        end
                    end
                end
            end
        end
    end
    return inimigoMaisProximo
end

UserInputService.InputBegan:Connect(function(input, processado)
    if processado then return end 
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        mirando = true
        uiStrokeCirculo.Color = corAtivado -- Fica roxo quando mirando
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        mirando = false
        alvoAtual = nil -- SOLTA O ALVO QUANDO SOLTAR O BOTÃO
        uiStrokeCirculo.Color = Color3.new(1, 1, 1)
    end
end)

RunService.RenderStepped:Connect(function()
    local posMouse = UserInputService:GetMouseLocation()
    
    circuloHitbox.Visible = MOSTRAR_FOV
    circuloHitbox.Size = UDim2.new(0, RAIO_FOV * 2, 0, RAIO_FOV * 2)
    circuloHitbox.Position = UDim2.new(0, posMouse.X, 0, posMouse.Y)

    if AIMBOT_ATIVO and mirando and not estaSentado() then
        -- 1. Verifica se o alvo atual ainda está vivo e existe. Se morreu, limpa.
        if alvoAtual then
            local charAlvo = alvoAtual.Parent
            if not charAlvo or not charAlvo:FindFirstChild("Humanoid") or charAlvo.Humanoid.Health <= 0 then
                alvoAtual = nil
            end
        end

        -- 2. Se não temos alvo, procura o mais próximo no circulo agora
        if not alvoAtual then
            alvoAtual = pegarInimigoNoFov(posMouse)
        end

        -- 3. Se temos um alvo (novo ou antigo), gruda a câmera nele (Sticky Aim)
        if alvoAtual then
            local posicaoCamera = Camera.CFrame.Position
            Camera.CFrame = CFrame.new(posicaoCamera, alvoAtual.Position)
        end
    else
        alvoAtual = nil -- Se não tá segurando o botão, solta o alvo
    end
end)
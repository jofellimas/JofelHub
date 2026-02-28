local gameId = game.PlaceId

local function notificar(titulo, texto)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = titulo;
        Text = texto;
        Duration = 5;
    })
end

if gameId == 142823291 then
    notificar("JofelHub", "Carregando MM2...")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/jofellimas/JofelHub/refs/heads/main/scripts/MM2.lua"))()

elseif gameId == 606849621 then
    notificar("JofelHub", "Carregando Jailbreak...")
    loadstring(game:HttpGet("https://raw.githubusercontent.com/jofellimas/JofelHub/refs/heads/main/scripts/Jailbreak.lua"))()

else
    notificar("JofelHub", "Jogo não suportado!")
    warn("ID do Jogo atual: " .. tostring(gameId))
end
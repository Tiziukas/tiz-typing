RegisterServerEvent("tiz-typing:sync", function(isclose, ptable)
    for _, player in pairs(ptable) do
        TriggerClientEvent("tiz-typing:show", player, isclose, source)
    end
end)
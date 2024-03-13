Please follow the below instructions to fully integrate this into your chat.

1. Find the below NUI Callback:
 ```sh
RegisterNUICallback('chatResult', function(data, cb)
  chatInputActive = false
  SetNuiFocus(false)
  if not data.canceled then
    local id = PlayerId()
    local r, g, b = 0, 0x99, 255

    if data.message:sub(1, 1) == '/' then
      ExecuteCommand(data.message:sub(2))
    else
      TriggerServerEvent('_chat:messageEntered', GetPlayerName(id), { r, g, b }, data.message, data.mode)
    end
  end

  cb('ok')
end)
```
Replace it with:
 ```sh
RegisterNUICallback('chatResult', function(data, cb)
  chatInputActive = false
  SetNuiFocus(false)
  TriggerEvent("tiz-typing:input", false)
  if not data.canceled then
    local id = PlayerId()

    local r, g, b = 0, 0x99, 255

    if data.message:sub(1, 1) == '/' then
      ExecuteCommand(data.message:sub(2))
    else
      TriggerServerEvent('_chat:messageEntered', GetPlayerName(id), { r, g, b }, data.message, data.mode)
    end
  end

  cb('ok')
end)
```
2. Find the following thread:
 ```sh
Citizen.CreateThread(function()
  SetTextChatEnabled(false)
  SetNuiFocus(false)

  local lastChatHideState = -1
  local origChatHideState = -1

  while true do
    Wait(0)

    if not chatInputActive then
      if IsControlPressed(0, isRDR and `INPUT_MP_TEXT_CHAT_ALL` or 245) --[[ INPUT_MP_TEXT_CHAT_ALL ]] then
        chatInputActive = true
        chatInputActivating = true
        SendNUIMessage({
          type = 'ON_OPEN'
        })
      end
    end

    if chatInputActivating then
      if not IsControlPressed(0, isRDR and `INPUT_MP_TEXT_CHAT_ALL` or 245) then
        SetNuiFocus(true)
        chatInputActivating = false
      end
    end

    if chatLoaded then
      local forceHide = IsScreenFadedOut() or IsPauseMenuActive()
      local wasForceHide = false

      if chatHideState ~= CHAT_HIDE_STATES.ALWAYS_HIDE then
        if forceHide then
          origChatHideState = chatHideState
          chatHideState = CHAT_HIDE_STATES.ALWAYS_HIDE
        end
      elseif not forceHide and origChatHideState ~= -1 then
        chatHideState = origChatHideState
        origChatHideState = -1
        wasForceHide = true
      end

      if chatHideState ~= lastChatHideState then
        lastChatHideState = chatHideState

        SendNUIMessage({
          type = 'ON_SCREEN_STATE_CHANGE',
          hideState = chatHideState,
          fromUserInteraction = not forceHide and not isFirstHide and not wasForceHide
        })

        isFirstHide = false
      end
    end
  end
end)
```
Replace it with:
 ```sh
Citizen.CreateThread(function()
  SetTextChatEnabled(false)
  SetNuiFocus(false)

  local lastChatHideState = -1
  local origChatHideState = -1

  while true do
    Wait(0)

    if not chatInputActive then
      if IsControlPressed(0, isRDR and `INPUT_MP_TEXT_CHAT_ALL` or 245) --[[ INPUT_MP_TEXT_CHAT_ALL ]] then
        chatInputActive = true
        chatInputActivating = true
        TriggerEvent("tiz-typing:input", true)
        SendNUIMessage({
          type = 'ON_OPEN'
        })
      end
    end

    if chatInputActivating then
      if not IsControlPressed(0, isRDR and `INPUT_MP_TEXT_CHAT_ALL` or 245) then
        SetNuiFocus(true)
        TriggerEvent("tiz-typing:input", true)
        chatInputActivating = false
      end
    end

    if chatLoaded then
      local forceHide = IsScreenFadedOut() or IsPauseMenuActive()
      local wasForceHide = false

      if chatHideState ~= CHAT_HIDE_STATES.ALWAYS_HIDE then
        if forceHide then
          origChatHideState = chatHideState
          chatHideState = CHAT_HIDE_STATES.ALWAYS_HIDE
        end
      elseif not forceHide and origChatHideState ~= -1 then
        chatHideState = origChatHideState
        origChatHideState = -1
        wasForceHide = true
      end

      if chatHideState ~= lastChatHideState then
        lastChatHideState = chatHideState

        SendNUIMessage({
          type = 'ON_SCREEN_STATE_CHANGE',
          hideState = chatHideState,
          fromUserInteraction = not forceHide and not isFirstHide and not wasForceHide
        })

        isFirstHide = false
      end
    end
  end
end)
```

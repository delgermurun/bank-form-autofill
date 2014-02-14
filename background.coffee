@getStorageData = (key) ->
  return JSON.parse(localStorage[key] or 'null')

@setStorageData = (key, data) ->
  localStorage[key] = JSON.stringify(data)

@getCardNames = (bank) ->
  return getStorageData("#{bank}-cardNames") or []

@setCardNames = (bank, cardNames) ->
  setStorageData("#{bank}-cardNames", cardNames)

chrome.runtime.onMessage.addListener(
  (request, sender, sendResponse) ->
    if !request.command
      sendResponse({})

    if request.command == 'getCardNames'
      sendResponse(getCardNames(request.bank))

    if request.command == 'getCardData'
      sendResponse(getStorageData("#{request.bank}-#{request.cardName}"))
)

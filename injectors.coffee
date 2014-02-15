addString = 'Бөглө'
cardOptionId = 'autoFillFormCardNames'

sendCommand = (name, data, response) ->
  data.command = name
  return chrome.runtime.sendMessage(data, response)

generateCardOptions = (cardNames) ->
  $element = $('<select/>').attr('id', cardOptionId)
  $option = $('<option/>').val('').text('Бөглөх картаа сонгоно уу.')
  $element.append($option)

  for cardName in cardNames
    $option = $('<option/>').val(cardName).text(cardName)
    $element.append($option)

  return $element

createOptionsBind = (source) ->
  # create generic button handler prevent event bubbling, form submissions, etc.
  $("##{cardOptionId}").on('change', (ev) ->
    fillForm()
    return false
  )

tdbOptionsAdd = ->
  sendCommand('getCardNames', {bank: 'tdb'}, (cardNames) ->
    cardNames = cardNames or []

    $target = $('#mF')
    $cardOptions = generateCardOptions(cardNames)

    $target.before($cardOptions)
    createOptionsBind()
  )

golomtOptionsAdd = ->
  sendCommand('getCardNames', {bank: 'golomt'}, (cardNames) ->
    cardNames = cardNames or []

    $target = $('#Table1')
    $cardOptions = generateCardOptions(cardNames)

    $target.before($cardOptions)
    createOptionsBind()
  )

golomtFillForm = ->
  sendCommand('getCardData', {bank: 'golomt', cardName: $("##{cardOptionId}").val()}, (cardData) ->
    cardData = cardData or {}
    $('#cardno').val(cardData['number'] or 'тохируулаагүй байна')
    $('#cardname').val(cardData['holder'] or 'тохируулаагүй байна')

    date = (cardData['expire_date'] or '0/0').split('/')
    $('#edate1').val(date[0])
    $('#edate2').val(date[1])

    $('#cardcvv').val(cardData['cvv'] or '')
    $('#cardtel').val(cardData['phone_number'] or 'тохируулаагүй байна')
    $('#cardmail').val(cardData['email'] or 'тохируулаагүй байна')
  )

tdbFillForm = ->
  sendCommand('getCardData', {bank: 'tdb', cardName: $("##{cardOptionId}").val()}, (cardData) ->
    cardData = cardData or {}
    $('input[name="pan"]').val(cardData['number'] or 'тохируулаагүй байна')
    $('input[name="cvv2"]').val(cardData['cvv'] or '')
    $('input[name="fio"]').val(cardData['holder'] or 'тохируулаагүй байна')

    date = (cardData['expire_date'] or '/').split('/')
    $('select[name="expMon"]').val(date[0])
    $('select[name="ExpYear"]').val("#{date[1][2]}#{date[1][3]}")

    $('input[name="emailuser"]').val(cardData['email'] or 'тохируулаагүй байна')
  )

fillForm = ->
  if !$("##{cardOptionId}").val()
    return

  host = window.location.hostname

  if /egolomt\.mn/.test(host)
    golomtFillForm()

  if /bankcard\.mn/.test(host) or /202\.131\.226\.94/.test(host)
    tdbFillForm()

injectFillButton = ->
  host = window.location.hostname

  if $("##{cardOptionId}").length
    $("##{cardOptionId}").remove()

  if /egolomt\.mn/.test(host)
    golomtOptionsAdd()

  if /bankcard\.mn/.test(host) or /202\.131\.226\.94/.test(host)
    tdbOptionsAdd()

$( ->
  timeout = 500
  window.setTimeout(injectFillButton, timeout)
)

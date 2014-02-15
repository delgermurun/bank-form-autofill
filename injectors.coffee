addString = 'Бөглө'
buttonId = 'autoFillFormButton'
cardOptionId = 'autoFillFormCardNames'

sendCommand = (name, data, response) ->
  data.command = name
  return chrome.runtime.sendMessage(data, response)

generateButton = (className, element) ->
  className = className or 'form-autofill-button'
  element = element || '<button/>'

  $button = $(element).addClass(className)
    .attr('id', buttonId)
    .text(addString)

  $icon = $('<span/>').addClass('autofill-icon')
  $button.prepend($icon)
  return $button

generateCardOptions = (cardNames) ->
  $element = $('<select/>').attr('id', cardOptionId)

  for cardName in cardNames
    $option = $('<option/>').val(cardName).text(cardName)
    $element.append($option)

  return $element

createButtonBind = (source) ->
  # create generic button handler prevent event bubbling, form submissions, etc.
  $('#' + buttonId).on('click', (ev) ->
    ev.preventDefault()

    fillForm()
    return false
  )

tdbButtonAdd = ->
  sendCommand('getCardNames', {bank: 'tdb'}, (cardNames) ->
    cardNames = cardNames or []

    $target = $('#mF')
    $cardOptions = generateCardOptions(cardNames)
    $button = generateButton('tdb')

    $target.before($cardOptions)
    $target.before($button)

    createButtonBind()
  )

golomtButtonAdd = ->
  sendCommand('getCardNames', {bank: 'golomt'}, (cardNames) ->
    cardNames = cardNames or []

    $target = $('#Table1')
    $cardOptions = generateCardOptions(cardNames)
    $button = generateButton('golomt')

    $target.before($cardOptions)
    $target.before($button)

    createButtonBind()
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
  host = window.location.hostname

  if /egolomt\.mn/.test(host)
    golomtFillForm()

  if /bankcard\.mn/.test(host)
    tdbFillForm()

injectFillButton = ->
  host = window.location.hostname

  $button = $('#' + buttonId)
  if $button.length
    $button.remove()

  if /egolomt\.mn/.test(host)
    golomtButtonAdd()

  if /bankcard\.mn/.test(host)
    tdbButtonAdd()

$( ->
  timeout = 500
  window.setTimeout(injectFillButton, timeout)
)

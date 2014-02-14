addString = 'Бөглө'
buttonId = 'autoFillFormButton'

generateGenericButton = (className, element) ->
  className = className or 'form-autofill-button'
  element = element || '<button/>'

  $button = $(element).addClass(className)
    .attr('id', buttonId)
    .text(addString)

  $icon = $('<span/>').addClass('autofill-icon')
  $button.prepend($icon)
  return $button

createGenericButtonBind = (source) ->
  # create generic button handler prevent event bubbling, form submissions, etc.
  $('#' + buttonId).on('click', (ev) ->
    ev.preventDefault()

    fillForm()
    return false
  )

golomtButtonAdd = ->
  #chrome.runtime.sendMessage(url: BL.buildUrl(postData))

  $target = $('#Table1')
  $button = generateGenericButton('golomt')
  $target.before($button)

  createGenericButtonBind()

golomtFillForm = ->
  values = {} # TODO: get from configured options
  $('#cardno').val(values['cardNumber'] or 'Картийн дугаараа тохируул')

fillForm = ->
  host = window.location.hostname

  if /egolomt\.mn/.test(host)
    golomtFillForm()

injectQuickAddLink = ->
  host = window.location.hostname

  $button = $('#' + buttonId)
  if $button.length
    $button.remove()

  if /egolomt\.mn/.test(host)
    golomtButtonAdd()

$( ->
  timeout = 500
  window.setTimeout(injectQuickAddLink, timeout)
)

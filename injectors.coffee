((BankFormAutofill) ->
  if !BankFormAutofill
    window.BankFormAutofill = {}
    BankFormAutofill = window.BankFormAutofill

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

  golomtQuickAdd = ->
    $target = $('#Table1')
    $button = generateGenericButton('golomt')
    $target.before($button)

    createGenericButtonBind()

  golomtQuickFillForm = ->
    values = {} # TODO: get from configured options
    $('#cardno').val(values['cardNumber'] or 'Картийн дугаараа тохируул')

  fillForm = ->
    host = window.location.hostname

    if /egolomt\.mn/.test(host)
      golomtQuickFillForm()

  injectQuickAddLink = ->
    host = window.location.hostname

    $button = $('#' + buttonId)
    if $button.length
      $button.remove()

    if /egolomt\.mn/.test(host)
      golomtQuickAdd()

    if /ball\.mn/.test(host) and /\/admin\/articles\/create/.test(path)
      fillArticleForm(search)

  $( ->
    timeout = 500
    window.setTimeout(injectQuickAddLink, timeout)
  )
)(window.BankFormAutofill)

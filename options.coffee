BANKS = [
    name: 'golomt'
    title: 'Голомт'
  ,
]

getStorageData = (key) ->
  return JSON.parse(localStorage[key] or 'null')

setStorageData = (key, data) ->
  localStorage[key] = JSON.stringify(data)

getCardNames = (bank) ->
  return getStorageData("#{bank}-cardNames") or []

setCardNames = (bank, cardNames) ->
  setStorageData("#{bank}-cardNames", cardNames)

saveCard = ($form) ->
  # get form data
  data = {}
  for field in $form.serializeArray()
    data[field.name] = field.value

  if not (data['bank'] and data['name'] and data['number'])
    alert('Мэдээллээ бөглөнө үү!')

  bank = data['bank']
  cardName = data['name']
  delete data['bank']
  delete data['name']

  # save card name
  cardNames = getCardNames(bank)

  if cardName not in cardNames
    cardNames.push(cardName)
    setCardNames(bank, cardNames)

  # save card data
  setStorageData("#{bank}-#{cardName}", data)
  renderCardList()

deleteCard = ($a) ->
  bank = $a.data('bank')
  cardName = $a.data('name')

  if not confirm("Үнэхээр устгах уу? #{bank} - #{cardName}")
    return

  # delete card name
  cardNames = getCardNames(bank)

  if cardName in cardNames
    cardNames.pop(cardName)
    setCardNames(bank, cardNames)

  # delete card data
  localStorage.removeItem("#{bank}-#{cardName}")

  renderCardList()

cardListTemplate = null
cardFormTemplate = null

renderCardList = ->
  # built data
  banks = []
  for bank in BANKS
    bank.cards = []

    cardNames = getCardNames(bank.name)
    for cardName in cardNames
      card = getStorageData("#{bank.name}-#{cardName}")
      card['name'] = cardName
      bank.cards.push(card)

    banks.push(bank)

  # render template
  partials =
    card: $('#card-template').html()
  $('#card-list-div').html(cardListTemplate({banks: banks}, {partials: partials}))

  $('a.delete-card').on('click', (event) ->
    event.preventDefault()
    deleteCard($(@))
  )

  $('a.edit-card').on('click', (event) ->
    event.preventDefault()
    renderCardForm($(@))
  )

renderCardForm = ($a)->
  # built data
  data =
    title: 'Карт нэмэх'
    banks: BANKS

  if $a
    data.bank = $a.data('bank')
    data.name = $a.data('name')
    data.title = 'Карт засах'
    data = $.extend({}, data, getStorageData("#{data.bank}-#{data.name}"))

  $('#card-form-div').html(cardFormTemplate(data))

  $('a.form-cancel').on('click', (event) ->
    event.preventDefault()
    renderCardForm()
  )

  $('form.card-form').on('submit', (event) ->
    event.preventDefault()
    saveCard($(@))
  )

$( ->
  Handlebars.registerHelper('include', (options) ->
    context = $.extend({}, @, options.hash)
    return options.fn(context)
  )
  cardListTemplate = Handlebars.compile($('#card-list-template').html())
  cardFormTemplate = Handlebars.compile($('#card-form-template').html())

  renderCardList()
  renderCardForm()
)

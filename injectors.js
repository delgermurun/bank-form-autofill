// Generated by CoffeeScript 1.6.3
(function() {
  var addString, buttonId, cardOptionId, createButtonBind, fillForm, generateButton, generateCardOptions, golomtButtonAdd, golomtFillForm, injectFillButton, sendCommand, tdbButtonAdd, tdbFillForm;

  addString = 'Бөглө';

  buttonId = 'autoFillFormButton';

  cardOptionId = 'autoFillFormCardNames';

  sendCommand = function(name, data, response) {
    data.command = name;
    return chrome.runtime.sendMessage(data, response);
  };

  generateButton = function(className, element) {
    var $button, $icon;
    className = className || 'form-autofill-button';
    element = element || '<button/>';
    $button = $(element).addClass(className).attr('id', buttonId).text(addString);
    $icon = $('<span/>').addClass('autofill-icon');
    $button.prepend($icon);
    return $button;
  };

  generateCardOptions = function(cardNames) {
    var $element, $option, cardName, _i, _len;
    $element = $('<select/>').attr('id', cardOptionId);
    for (_i = 0, _len = cardNames.length; _i < _len; _i++) {
      cardName = cardNames[_i];
      $option = $('<option/>').val(cardName).text(cardName);
      $element.append($option);
    }
    return $element;
  };

  createButtonBind = function(source) {
    return $('#' + buttonId).on('click', function(ev) {
      ev.preventDefault();
      fillForm();
      return false;
    });
  };

  tdbButtonAdd = function() {
    return sendCommand('getCardNames', {
      bank: 'tdb'
    }, function(cardNames) {
      var $button, $cardOptions, $target;
      cardNames = cardNames || [];
      $target = $('#mF');
      $cardOptions = generateCardOptions(cardNames);
      $button = generateButton('tdb');
      $target.before($cardOptions);
      $target.before($button);
      return createButtonBind();
    });
  };

  golomtButtonAdd = function() {
    return sendCommand('getCardNames', {
      bank: 'golomt'
    }, function(cardNames) {
      var $button, $cardOptions, $target;
      cardNames = cardNames || [];
      $target = $('#Table1');
      $cardOptions = generateCardOptions(cardNames);
      $button = generateButton('golomt');
      $target.before($cardOptions);
      $target.before($button);
      return createButtonBind();
    });
  };

  golomtFillForm = function() {
    return sendCommand('getCardData', {
      bank: 'golomt',
      cardName: $("#" + cardOptionId).val()
    }, function(cardData) {
      var date;
      cardData = cardData || {};
      $('#cardno').val(cardData['number'] || 'тохируулаагүй байна');
      $('#cardname').val(cardData['holder'] || 'тохируулаагүй байна');
      date = (cardData['expire_date'] || '0/0').split('/');
      $('#edate1').val(date[0]);
      $('#edate2').val(date[1]);
      $('#cardcvv').val(cardData['cvv'] || '');
      $('#cardtel').val(cardData['phone_number'] || 'тохируулаагүй байна');
      return $('#cardmail').val(cardData['email'] || 'тохируулаагүй байна');
    });
  };

  tdbFillForm = function() {
    return sendCommand('getCardData', {
      bank: 'tdb',
      cardName: $("#" + cardOptionId).val()
    }, function(cardData) {
      var date;
      cardData = cardData || {};
      $('input[name="pan"]').val(cardData['number'] || 'тохируулаагүй байна');
      $('input[name="cvv2"]').val(cardData['cvv'] || '');
      $('input[name="fio"]').val(cardData['holder'] || 'тохируулаагүй байна');
      date = (cardData['expire_date'] || '/').split('/');
      $('select[name="expMon"]').val(date[0]);
      $('select[name="ExpYear"]').val("" + date[1][2] + date[1][3]);
      return $('input[name="emailuser"]').val(cardData['email'] || 'тохируулаагүй байна');
    });
  };

  fillForm = function() {
    var host;
    host = window.location.hostname;
    if (/egolomt\.mn/.test(host)) {
      golomtFillForm();
    }
    if (/bankcard\.mn/.test(host)) {
      return tdbFillForm();
    }
  };

  injectFillButton = function() {
    var $button, host;
    host = window.location.hostname;
    $button = $('#' + buttonId);
    if ($button.length) {
      $button.remove();
    }
    if (/egolomt\.mn/.test(host)) {
      golomtButtonAdd();
    }
    if (/bankcard\.mn/.test(host)) {
      return tdbButtonAdd();
    }
  };

  $(function() {
    var timeout;
    timeout = 500;
    return window.setTimeout(injectFillButton, timeout);
  });

}).call(this);

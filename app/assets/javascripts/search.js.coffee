getPlayerList = (request, response) ->
  $.getJSON '/players/search.json', { q: request.term }, (players) ->
    response(
      _.map _.pluck(players, 'player'), (p) ->
        label: p.name
        value: p.url
    )

goToPlayer = (event, ui) ->
  this.value = ui.item.label
  window.location.href = ui.item.value
  return false

playerSelectionMenu = (event, ui) ->
  # Seems odd this isn't passed in as an arg.
  $('ul.ui-autocomplete').addClass 'dropdown-menu'

$ () ->    
  $('#player-search').autocomplete
    source: getPlayerList
    select: goToPlayer
    create: playerSelectionMenu
    minLength: 2

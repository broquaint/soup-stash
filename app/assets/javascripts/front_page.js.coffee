$ ->
  $('.dropdown-toggle').dropdown()

  # TODO Generalize.
  $('.toggle-btn').click ->
    $('#least-popular-combos li').toggleClass('toggle-display')

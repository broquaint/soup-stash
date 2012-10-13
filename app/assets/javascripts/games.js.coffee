$ ->
  _.templateSettings =
    interpolate: /\[%= (.+?) %\]/g
    evaluate:    /\[% (.+?) %\]/g

  toggle = (el) ->
    $(el).next().toggle()
    $('.toggle-on', el).toggle()
    $('.toggle-off', el).toggle()

  $('#morgue').on 'click', 'a.toggle-list', -> toggle @

  $('a.large-load').one 'click', ->
    $this    = $(@)
    $target  = $this.next()

    $tmpl_el = $target.find('script[type="text/x-underscore-tmpl"]')
    tmpl     = $tmpl_el.text()
    $tmpl_el.replaceWith '<span class="one-sec">Loading!</span>'

    $.getJSON "#{window.location.href}.json", { field: $this.data('field') }, (json) ->
      $target.find('.one-sec').replaceWith _.template(tmpl, json.game)
      toggle $this
      $this.addClass('toggle-list')

  $('#pointer-up a').click ->
    scrollTo(0, 0)
    return false

  # Treat the button as though it were a link.
  $('#update-morgue').click ->
    $.rails.handleMethod $(this)

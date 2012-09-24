# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $('a.toggle-list').click ->
    $(@).next().toggle()
    $('.toggle-on', @).toggle()
    $('.toggle-off', @).toggle()

  $('#pointer-up a').click ->
    scrollTo(0, 0)
    return false

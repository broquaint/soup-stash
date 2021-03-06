# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# the compiled file.
#
# WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
# GO AFTER THE REQUIRES BELOW.
#
#= require jquery
#= require jquery_ujs
#= require jquery.ui.all
#= require underscore
#= require bootstrap
#= require_tree .

removeFilter = ->
  $btn  = $(this)
  query = $btn.attr('name')
  value = $btn.val()

  # TODO Apply uri.js or some such to de-suck this.
  # e.g quotemeta ?foo[]=bar+baz
  toRemove = new RegExp(
    '[?&]' + query + '(%5B%5D)?=' + encodeURI(value).replace(/%20/g, '\\+')
  )
  sansFilter = window.location.href.replace(toRemove, '')
  sansFilter = sansFilter.replace('&', '?') if sansFilter.indexOf('?') == -1

  window.location = sansFilter

jQuery ->
  $('.selections button').click removeFilter
  $('#clear-selections').click ->
    window.location.href = window.location.href.replace /[?].*/, ''

  $('.toggle-btn').click ->
    $('.more-less > li').toggleClass('toggle-display')

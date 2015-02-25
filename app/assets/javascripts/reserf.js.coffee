# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready ->
  $('#myModal').on('show.bs.modal', (event) -> 
    button = $(event.relatedTarget) 
    recipient = button.data('whatever') 
    modal = $(this)
    modal.find('.modal-title').text('Input additional info:' + recipient)
    $.getJSON('/reserves/'+recipient+'/edit',(reserve) -> 
      modal.find('#id').attr('value', recipient)
      modal.find('form').attr('action', '/reserves/' + recipient)
      modal.find('#reserf_hhv').attr('value', reserve.hhv)
      modal.find('#reserf_llv').attr('value', reserve.llv)
      modal.find('#reserf_hdate').attr('value', reserve.hdate)
      modal.find('#reserf_ldate').attr('value', reserve.ldate)
      modal.find('#reserf_note').text(reserve.note)
    )
  )
  $("input[name='commit']").click( -> 
    $("#myModal form").submit()
    $('#myModal').modal('hide')
  )
  $('#myModal').on('hide.bs.modal', (event) -> 
    setTimeout( -> 
      history.go(0)
    , 1000)
  )

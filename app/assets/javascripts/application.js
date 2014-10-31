//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require underscore
//= require backbone/libs/underscore.string.min
//= require backbone
//= require backbone.marionette
//= require_tree .

$(function() {
  //temp
  $.fn.editable.defaults.mode = 'inline';
  options = {
    api_endpoint: gon.api_endpoint,
    temp_token: gon.temp_token
  };
  return AlumNet.start(options);
});
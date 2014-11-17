//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require underscore
//= require backbone/libs/underscore.string.min
//= require backbone
//= require backbone.marionette
//= require backbone/libs/masonry.pkgd.min
//= require backbone/alumnet
//= require_tree ./backbone/libs
//= require_tree ./backbone/concerns
//= require_tree ./backbone/entities
//= require_tree ./backbone/apps
//= require bootstrap
//= require_self

$(function() {

  //temp
  $.fn.editable.defaults.mode = 'inline';
  options = {
    api_endpoint: gon.api_endpoint
  };
  return AlumNet.start(options);
});
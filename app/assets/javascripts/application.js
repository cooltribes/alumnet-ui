//= require jquery
//= require jquery_ujs
//= require backbone/libs/jquery-ui.min
//= require twitter/bootstrap
//= require underscore
//= require backbone/libs/underscore.string.min
//= require backbone
//= require backbone.marionette
//= require backbone/libs/masonry.pkgd.min
//= require backbone/alumnet
//= require_tree ./backbone/libs
//= require_tree ./backbone/concerns
//= require_tree ./backbone/controllers
//= require_tree ./backbone/entities
//= require_tree ./backbone/apps
//= require bootstrap
//= require_self

ion.sound({
    sounds: [
      {
        name: "water_droplet_3"
      },
    ],
    volume: 0.5,
    path: "sounds/",
    preload: true
});

$(function() {

  //temp
  $.fn.editable.defaults.mode = 'inline';
  options = {
    api_endpoint: gon.api_endpoint,
    pusher_key: gon.pusher_key,
    profinda_api_endpoint: gon.profinda_api_endpoint,
    profinda_account_domain: gon.profinda_account_domain,
    environment: gon.environment,
    paymentwall_project_key: gon.paymentwall_project_key
  };
  return AlumNet.start(options);
});
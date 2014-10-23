@AlumNet.module 'RegistrationApp.Process', (Process, @AlumNet, Backbone, Marionette, $, _) ->

  class Process.Layout extends Marionette.LayoutView
    template: 'registration/account/templates/layout'
    id: 'main-wrapper'
    className: 'col-md-12'

    regions:
      side_region: '#sidebar-region' #any name you want to give to the region, any css selector you have used inside the layout template
      content_region:   '#registration-content-region' #any name you want to give to the region, any css selector you have used inside the layout template


  class Process.Sidebar extends Marionette.CompositeView
    template: 'registration/account/templates/sidebar'

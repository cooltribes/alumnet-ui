@AlumNet.module 'RegistrationApp.Account', (Account, @AlumNet, Backbone, Marionette, $, _) ->

  class Account.Layout extends Marionette.LayoutView
    template: 'registration/account/templates/layout'
    id: 'main-wrapper'
    className: 'col-md-12'
      

    regions:
      side_region: '#sidebar-region' #any name you want to give to the region, any css selector you have used inside the layout template
      form_region:   '#form-region' #any name you want to give to the region, any css selector you have used inside the layout template


  class Account.Sidebar extends Marionette.LayoutView
    template: 'registration/account/templates/sidebar'
  

  class Account.Form extends Marionette.ItemView
    template: 'registration/account/templates/form'
    # className: '' #Any class name that you want to attach to this tag element
    # tagName: '' the tag element [div, span, ul, form] is div by default

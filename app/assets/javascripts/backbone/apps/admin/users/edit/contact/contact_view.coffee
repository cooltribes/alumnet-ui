@AlumNet.module 'AdminApp.Edit.Contact', (Edit, @AlumNet, Backbone, Marionette, $, _) ->

  class Edit.Layout extends Marionette.LayoutView
    template: 'admin/users/edit/contact/templates/layout'
    className: 'container'
@AlumNet.module 'AdminApp.Edit', (Edit, @AlumNet, Backbone, Marionette, $, _) ->

  class Edit.Layout extends Marionette.LayoutView
    template: 'admin/users/edit/templates/layout'
    className: 'container'
    # regions:
      
@AlumNet.module 'AdminApp.UserShow', (UserShow, @AlumNet, Backbone, Marionette, $, _) ->

  class UserShow.Contact extends Marionette.ItemView
    template: 'admin/users/show/templates/_overview_contact'
    templateHelpers: ->
      model = @model
      contactTypeText: (contact_type)->
        model.findContactType(contact_type) if model

  class UserShow.Contacts extends Marionette.CompositeView
    template: 'admin/users/show/templates/contacts'
    className: 'container'
    childView: UserShow.Contact
    childViewContainer: '#js-contacts-container'
    childViewOptions: ->
      user: @model
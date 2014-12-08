@AlumNet.module 'RegistrationApp.Contact', (Contact, @AlumNet, Backbone, Marionette, $, _) ->
  class Contact.Controller

    showContact: ->

      # creating layout
      layoutView = @getLayoutView()
      AlumNet.mainRegion.show(layoutView)

      # sub-views
      layoutView.side_region.show(@getSidebarView())

      user = AlumNet.current_user

      profile = user.profile

      contactForm = @getFormView(user, profile)
      layoutView.form_region.show(contactForm)

      # AlumNet.execute('render:groups:submenu')

      contactForm.on "form:submit", (model)->
        model.save {},
          success: ->
            AlumNet.trigger "registration:experience"


    getLayoutView: ->
      AlumNet.request("registration:shared:layout")

    getSidebarView: ->
      AlumNet.request("registration:shared:sidebar", 2)

    getFormView: (user, profile) ->
      new Contact.Form
        model: profile
        user: user
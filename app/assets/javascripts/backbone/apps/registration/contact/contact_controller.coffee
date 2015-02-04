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

      # initial contacts
      contacts = new AlumNet.Entities.ProfileContactsCollection [
        new AlumNet.Entities.ProfileContact
          contact_type: 0, info: user.get('email'), showDelete: false, readOnly: true
        new AlumNet.Entities.ProfileContact {contact_type: 1 }
        new AlumNet.Entities.ProfileContact {contact_type: 2 }
        new AlumNet.Entities.ProfileContact {contact_type: 3 }
      ]

      contactForm = @getFormView(profile, contacts)
      layoutView.form_region.show(contactForm)

      # AlumNet.execute('render:groups:submenu')

      contactForm.on "form:submit", ->
        validCollection = true
        contactsAtributtes = []
        @collection.each (model)->
          if model.isValid(true)
            contactsAtributtes.push(model.attributes)
          else
            validCollection = false

        if validCollection
          @model.set('contact_infos_attributes', contactsAtributtes)
          @model.save {},
            success: (model)->
              step = model.get('register_step')
              AlumNet.trigger "registration:experience", step

    getLayoutView: ->
      AlumNet.request("registration:shared:layout")

    getSidebarView: ->
      AlumNet.request("registration:shared:sidebar", 2)

    getFormView: (profile, collection) ->
      new Contact.Form
        model: profile
        collection: collection
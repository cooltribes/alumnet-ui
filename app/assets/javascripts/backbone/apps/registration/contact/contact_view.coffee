AlumNet.module 'RegistrationApp.Contact', (Contact, @AlumNet, Backbone, Marionette, $, _) ->

  class Contact.Form extends Marionette.ItemView
    template: 'registration/contact/templates/form'
    className: 'row'

    initialize: (options)->
      @current_user = options.user

    templateHelpers: ->
      userEmail: @current_user.get("email")

    events:
      "click button.js-addRow":"addInputRow"
      "click button.js-rmvRow":"removeInputRow"
      "click button.js-submit":"submitClicked"

    submitClicked: (e)->
      e.preventDefault()
      formData = new FormData()
      data = Backbone.Syphon.serialize(this)

      contactArray = data.contact_infos_attributes

      numberObj =
        "contact_type": 1
        "info": data.code + data.number
        "privacy": data.numberPrivacy

      contactAttrs = new Array()

      _.forEach contactArray.contact_type, (valueIn, key, list)->
        if valueIn != "" and contactArray.info[key] != ""
          contactAttrs[key] =
            "contact_type": valueIn
            "info": contactArray.info[key]
            "privacy": contactArray.privacy[key]

      #append number field to entire object if any
      contactAttrs.push numberObj if numberObj.info

      #Assign values to model
      @model.set("contact_infos_attributes", contactAttrs)

      # console.log @model
      @trigger("form:submit", @model)

    addInputRow: (e)->
      row = $(e.currentTarget).closest(".form-group").prev()
      row2 = row.clone()

      #Show the remove button
      row2.find(".close").removeClass("hidden")
      row2.insertAfter(row)

    removeInputRow: (e)->
      $(e.currentTarget).parent().remove()




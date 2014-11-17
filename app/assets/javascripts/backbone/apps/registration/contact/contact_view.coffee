AlumNet.module 'RegistrationApp.Contact', (Contact, @AlumNet, Backbone, Marionette, $, _) ->
 
  class Contact.Form extends Marionette.ItemView
    template: 'registration/contact/templates/form'
    className: 'row'

    initialize: ->
      ###Backbone.Validation.bind this,
        valid: (view, attr, selector) ->
          $el = view.$("[name=#{attr}]")
          $group = $el.closest('.form-group')
          $group.removeClass('has-error')
          $group.find('.help-block').html('').addClass('hidden')
        invalid: (view, attr, error, selector) ->
          $el = view.$("[name=#{attr}]")
          $group = $el.closest('.form-group')
          $group.addClass('has-error')
          $group.find('.help-block').html(error).removeClass('hidden')
      ###
    events:
      "click button.js-addRow":"addInputRow"
      "click button.js-submit":"submitClicked"

    submitClicked: (e)->
      e.preventDefault()
      formData = new FormData()
      data = Backbone.Syphon.serialize(this)
      
      contactArray = data.contact_infos_attributes

      numberObj = {
        "contact_type": 1,
        "info": data.code + data.number,
        "privacy": data.numberPrivacy,
      }

      contactAttrs = new Array()
      # _.forEach data, (value, key, list)->
        
      #   if (key == "code" or key == "number")
      #     numberObj.info += value
      #   else if (key == "numberPrivacy" or key == "number")
      #     numberObj.privacy = value          
        

      _.forEach contactArray.contact_type, (valueIn, key, list)->
        if valueIn != "" and contactArray.info[key] != ""
          contactAttrs[key] = {
            "contact_type": valueIn,
            "info": contactArray.info[key],
            "privacy": contactArray.privacy[key],
          }
          

      # console.log "antes" 
      # console.log contactAttrs 


      # #append number field to entire object if any
      # contactAttrs.push numberObj if numberObj.info
      # console.log "despues" 
      # console.log contactAttrs 
      # formData.append(key, value)    

      #Assign values to model
      @model.set("contact_infos_attributes", contactAttrs)

      # console.log @model
      # @trigger("form:submit", this.model)

    addInputRow: (e)->
      console.log this
      

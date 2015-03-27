AlumNet.module 'RegistrationApp.Contact', (Contact, @AlumNet, Backbone, Marionette, $, _) ->

  class Contact.Field extends Marionette.ItemView
    template: 'registration/contact/templates/field'
    ui:
      'rmvRow': '.js-rmvRow'
      "contact_type": "[name=contact_type]"
      "selectType": ".contact_method"      
      "info": "[name=info]"
      "privacy": "[name=privacy]"

      
    events:
      "click @ui.rmvRow": "rmvRowClicked"
      "change .contact_method, click .contact_method": "changePlaceholder"

    templateHelpers: ->
      model = @model

      selected: (value)->
        if value == @contact_type
          'selected'
      isReadOnly: ->
        if @readOnly
          'disabled'
      
      placeholder: ->
        contact_type = model.get("contact_type")
        if contact_type == 0
          return "email@example.com"   
        if contact_type == 1          
          return "+PhoneNumber"   
        if contact_type == 2
          return "Skype" 
        if contact_type == 3
          return "Yahoo account"      
        if contact_type == 4
          return "/Facebook"      
        if contact_type == 5
          return "@Twitter"
        if contact_type == 5
          return "Account"
        if contact_type == 5
          return "https://www.example.com"                      


    initialize: ->
      Backbone.Validation.bind this,
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

    serialize: (e)->
      contact_type: @ui.contact_type.val()
      info: @ui.info.val()
      privacy: @ui.privacy.val()

    rmvRowClicked: (e)->
      e.preventDefault()
      @model.destroy()

    changePlaceholder: (e)->
      if @ui.selectType.val() == "0" 
        @ui.info.attr("placeholder", "email@example.com")
      else if @ui.selectType.val() == "1"
        @ui.info.attr("placeholder", "+PhoneNumber")
      else if @ui.selectType.val() == "2"
        @ui.info.attr("placeholder", "Skype")
      else if @ui.selectType.val() == "3"
        @ui.info.attr("placeholder", "Yahoo account")
      else if @ui.selectType.val() == "4"
        @ui.info.attr("placeholder", "/Facebook")
      else if @ui.selectType.val() == "5"
        @ui.info.attr("placeholder", "@Twitter")
      else if @ui.selectType.val() == "6"
        @ui.info.attr("placeholder", "Account")
      else  
        @ui.info.attr("placeholder", "https://www.example.com")
        
        

  class Contact.Form extends Marionette.CompositeView
    template: 'registration/contact/templates/form'
    childView: Contact.Field
    childViewContainer: '.js-fields-container'
    ui:
      'addRow': '.js-addRow'

    events:
      'click @ui.addRow': 'addRowClicked'
      'click .js-submit': 'submitClicked'


    addRowClicked: (e)->
      e.preventDefault()
      contact = new AlumNet.Entities.ProfileContact
      @collection.add(contact)

    submitClicked: (e)->
      e.preventDefault()
      @children.each (view)->
        view.model.set(view.serialize())
      @trigger 'form:submit'




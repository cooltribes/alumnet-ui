AlumNet.module 'RegistrationApp.Contact', (Contact, @AlumNet, Backbone, Marionette, $, _) ->

  class Contact.Field extends Marionette.ItemView
    template: 'registration/contact/templates/field'
    ui:
      'rmvRow': '.js-rmvRow'
      "contact_type": "[name=contact_type]"
      "info": "[name=info]"
      "privacy": "[name=privacy]"

      
    events:
      "click @ui.rmvRow": "rmvRowClicked"
      "change @ui.contact_type, click @ui.contact_type": "changePlaceholder"

    templateHelpers: ->
      selected: (value)->
        if value == @contact_type
          'selected'
      isReadOnly: ->
        if @readOnly
          'disabled'

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

    changePlaceholder: ->
      if @ui.contact_type.val() == "0" 
        $('input').attr('placeholder',"email@example.com")        
      else if @ui.contact_type.val() == "1"
        $('input').attr('placeholder',"+PhoneNumber")        
      else if @ui.contact_type.val() == "2"
        $('input').attr('placeholder',"Skype account")       
      else if @ui.contact_type.val() == "3"
        $('input').attr('placeholder',"Yahoo account")        
      else if @ui.contact_type.val() == "4"
        $('input').attr('placeholder',"Name in Facebook")        
      else if @ui.contact_type.val() == "5"
        $('input').attr('placeholder',"@Twitter")                              
      else if @ui.contact_type.val() == "7"
        $('input').attr('placeholder',"https://www.example.com")        
      else  
        $('input').attr('placeholder',"Enter account")
        
        

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




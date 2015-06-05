@AlumNet.module 'UsersApp.Business', (Business, @AlumNet, Backbone, Marionette, $, _) ->

  class Business.SectionView extends Marionette.LayoutView
    template: 'users/business/templates/business_container'

    initialize: (options)->
      @userCanEdit = options.userCanEdit
      
    templateHelpers: ->
      userCanEdit: @userCanEdit

    triggers:
      "click .js-create": "showCreateForm"

    bindings:
      ".js-offer": "offer"
      ".js-search": "search"
      ".js-business-me": "business_me"
      ".js-company-name": 
        observe: "company"
        onGet: (value)->
          value.name

    onRender: ->
      @stickit()  
  


  class Business.EmptyView extends Marionette.ItemView
    template: 'users/business/templates/empty_container'

    initialize: (options)->
      @userCanEdit = options.userCanEdit

    templateHelpers: ->
      userCanEdit: @userCanEdit



  class Business.CreateForm extends Marionette.ItemView
    template: 'users/business/templates/create_business'

    initialize: ()->      
      Backbone.Validation.bind @,
        valid: (view, attr, selector) ->          
          $el = view.$("[name='#{attr}'], ##{attr.replace(".", "-")}")
          $group = $el.closest('.form-group')
          $group.removeClass('has-error')
          $group.find('.help-block').html('').addClass('hidden')
        invalid: (view, attr, error, selector) ->          
          $el = view.$("[name='#{attr}'], ##{attr.replace(".", "-")}")
          $group = $el.closest('.form-group')
          $group.addClass('has-error')
          $group.find('.help-block').html(error).removeClass('hidden')

    triggers:
      "click .js-cancel": "cancel"

    events:
      "click .js-submit": "submit"

    submit: (e)->
      e.preventDefault()
      data = Backbone.Syphon.serialize @
      @model.set(data)
      
      #submit the model only if it is valid
      unless @model.validate() 
        @trigger "submit", @model
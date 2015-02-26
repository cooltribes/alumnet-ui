@AlumNet.module 'PrivacyApp.Settings', (Settings, @AlumNet, Backbone, Marionette, $, _) ->


  class Settings.Privacy extends Marionette.ItemView
    template: 'privacy/settings/templates/_privacy'
    tagName: "li"

    # events:
    #   "change [name=value]": "changeValue"
    modelEvents:
      "change": "modelChange"

    bindings:
      "#description": "description"
      "[name=value]": 
        observe: "value"
        selectOptions:
          collection: [
            value: 0
            label: "Only me"
          ,
            value: 1
            label: "My friends"
          ,
            value: 2
            label: "Everyone"
          ,            
          ]

    initialize: ()->
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


    modelChange: (e)->
      @model.save()

    # initialize: (options)->
    #   @userCanEdit = options.userCanEdit

    # templateHelpers: ->
    #   userCanEdit: @userCanEdit

    # removeItem: (e)->
    #   if confirm("Are you sure you want to delete this item from your profile ?")
    #     @model.destroy()

    onRender: ->
      @stickit()


  class Settings.Empty extends Marionette.ItemView
    template: 'privacy/settings/templates/_empty'
    
    initialize: (options)->
      @message = options.message

    templateHelpers: ->
      message: @message 

  class Settings.View extends Marionette.CompositeView
    template: 'privacy/settings/templates/privacy_settings'
    childView: Settings.Privacy      
    childViewContainer: "#js-list"
    emptyView: Settings.Empty
    emptyViewOptions: 
      message: "Currently you can not access your privacy settings, please contact the site administrator. (Your configuration is missing in the database)"


    # onRender: ->
    #   $('#aboutUseraffix').affix({
    #     offset: {
    #       top: 100,
    #       bottom:150,
    #     }
    #   })

 
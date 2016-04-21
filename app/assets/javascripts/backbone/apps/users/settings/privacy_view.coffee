@AlumNet.module 'UsersApp.Privacy', (Privacy, @AlumNet, Backbone, Marionette, $, _) ->


  class Privacy.PrivacyView extends Marionette.ItemView
    template: 'users/settings/templates/_privacy'
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
        $(window).on 'scroll' , =>
          if $('body').scrollTop()>50
            $('#aboutUseraffix').css
              'position': 'fixed'
              'width' : '184px'
              'top' : '110px'            
          else
            $('#aboutUseraffix').css 
              'position': 'relative'
              'top':'0px'
              'width':'100%'

    templateHelpers: ->
      userId: AlumNet.current_user.id          

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


  class Privacy.Empty extends Marionette.ItemView
    template: 'users/settings/templates/empty_privacy'
    
    initialize: (options)->
      @message = options.message

    templateHelpers: ->
      message: @message 

  class Privacy.View extends Marionette.CompositeView
    template: 'users/settings/templates/privacy_container'
    childView: Privacy.PrivacyView      
    childViewContainer: "#js-list"
    emptyView: Privacy.Empty
    emptyViewOptions: 
      message: "Currently you can not access Privacyyour privacy settings, please contact the site administrator. (Your configuration is missing in the database)"


    # onRender: ->
    #   $('#aboutUseraffix').affix({
    #     offset: {
    #       top: 100,
    #       bottom:150,
    #     }
    #   })

 
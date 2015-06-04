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

    triggers:
      "click .js-cancel": "cancel"


    
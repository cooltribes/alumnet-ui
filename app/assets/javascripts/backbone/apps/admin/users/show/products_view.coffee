@AlumNet.module 'AdminApp.UserShow', (UserShow, @AlumNet, Backbone, Marionette, $, _) ->

  class UserShow.Product extends Marionette.ItemView
    template: 'admin/users/show/templates/_product'
    tagName: 'tr'

    initialize: (options) ->
      @user = AlumNet.request('user:find', @model.get('user').id)
      @listenTo(@model, 'change:status', @modelChange)

    ui:
      'activate': '.js-activate'
      'deactivate': '.js-deactivate'

    events:
      'click @ui.activate': 'activateClicked'
      'click @ui.deactivate': 'deactivateClicked'

    templateHelpers: ->
      startDate: @getStartDate()
      endDate: @getEndtDate()
      productType: @getProductType()
      status: @getStatus()

    getStartDate: ->
      date = new Date(@model.get('start_date'))
      date.toDateString()

    getEndtDate: ->
      if @model.get('end_date')
        date = new Date(@model.get('end_date'))
        date.toDateString()
      else
        'forever'

    getProductType: ->
      if @model.get('product').feature == 'subscription'
        'Membership'
      else
        'Other'

    getStatus: ->
      if @model.get('status') == 1
        'Active'
      else
        'Inactive'

    deactivateClicked: (e)->
      e.preventDefault()
      @model.set({status: 0, user_id: @model.get('user').id})
      @model.save
        success: ->
          @model.trigger 'change:status'

      data = {member: 0}
      id = @model.get('user').id
      url = AlumNet.api_endpoint + "/users/#{id}"

      Backbone.ajax
        url: url
        type: "PUT"
        data: data

    activateClicked: (e)->
      e.preventDefault()
      @model.set({status: 1, user_id: @model.get('user').id})
      @model.save
        success: ->
          @model.trigger 'change:status'

      @product = @model.get('product')
      @member_value = 1
      if @product.feature == 'subscription' and not @product.quantity?
        @member_value = 3

      data = {member: @member_value}
      id = @model.get('user').id
      url = AlumNet.api_endpoint + "/users/#{id}"

      Backbone.ajax
        url: url
        type: "PUT"
        data: data

    modelChange: ->
      @render()

  class UserShow.Products extends Marionette.CompositeView
    template: 'admin/users/show/templates/products'
    childView: UserShow.Product
    childViewContainer: '#js-products-container'
    childViewOptions: ->
      user: @model

    initialize: (options) ->
      @modals = options.modals

    ui:
      'createMembership': '#js-create-membership'

    events:
      'click @ui.createMembership': 'createClicked'

    createClicked: ->
      modalView = new UserShow.ModalPremium
        model: @model
      @modals.show(modalView)

  class UserShow.ModalPremium extends Backbone.Modal
    template: 'admin/users/show/templates/modal_premium'
    viewContainer: '.modal-container'
    cancelEl: '#close-btn, #goBack'
    submitEl: "#save-status"

    initialize: (options) ->
      console.log options
      subscriptions = AlumNet.request('product:entities', {q: { feature_eq: 'subscription', status_eq: 1 }})
      subscriptions.on 'fetch:success', (collection)->
        @subscriptions = collection
        console.log @subscriptions

    templateHelpers: () ->
      subscriptions: @subscriptions

    submit: () ->
      data = Backbone.Syphon.serialize(this)
      id = @model.id
      url = AlumNet.api_endpoint + "/users/#{id}/subscriptions"
      data.user_id = id

      Backbone.ajax
        url: url
        type: "POST"
        data: data
        success: (data) =>
          console.log("success")
          console.log(data)
        error: (data) =>
          console.log("error")
          console.log(data)

    # onRender: ->
    #   @$(".js-date-start-date").Zebra_DatePicker
    #     show_icon: false
    #     show_select_today: false
    #     view: 'years'
    #     default_position: 'below'
    #     onOpen: (e) ->
    #       $('.Zebra_DatePicker.dp_visible').zIndex(99999999999)

    #   @$(".js-date-end-date").Zebra_DatePicker
    #     show_icon: false
    #     show_select_today: false
    #     view: 'years'
    #     default_position: 'below'
    #     direction: 1
    #     onOpen: (e) ->
    #       $('.Zebra_DatePicker.dp_visible').zIndex(99999999999)
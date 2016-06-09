@AlumNet.module 'AdminApp.UserShow', (UserShow, @AlumNet, Backbone, Marionette, $, _) ->

  class UserShow.Product extends Marionette.ItemView
    template: 'admin/users/show/templates/_product'
    tagName: 'tr'

    initialize: (options) ->
      @user = AlumNet.request('user:find', @model.get('user').id)
      @listenTo(@model, 'change:status', @modelChange)
      @listenTo(@model, 'change:end_date', @modelChange)

    ui:
      'activate': '.js-activate'
      'deactivate': '.js-deactivate'
      'endDate': '.js-end-date'

    events:
      'click @ui.activate': 'activateClicked'
      'click @ui.deactivate': 'deactivateClicked'

    templateHelpers: ->
      startDate: @getStartDate()
      endDate: @getEndtDate()
      productType: @getProductType()
      status: @getStatus()
      dateIsPast: @dateIsPast()
      isLifetime: @isLifetime()

    onRender: ->
      #Datepickers
      model = @model
      @ui.endDate.Zebra_DatePicker
        format: 'd/m/Y'
        show_icon: false
        show_select_today: false
        direction: true
        onSelect: (date, standarDate, jsDate, input)->
          model.set({end_date: jsDate, user_id: model.get('user').id})
          model.save
            success: ->
              model.trigger 'change:end_date'

    getStartDate: ->
      date = new Date(@model.get('start_date'))
      date.toDateString()

    getEndtDate: ->
      if @model.get('end_date')
        date = new Date(@model.get('end_date'))
        date.toDateString()
      else
        'forever'

    dateIsPast: ->
      if @model.get('end_date')
        date = new Date(@model.get('end_date'))
        now = new Date()
        if(date < now)
          return true
        else
          return false
      else
        return false

    isLifetime: ->
      if @model.get('end_date')
        return false
      else
        return true

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
      @listenTo(@model, 'change', @change)

    ui:
      'createMembership': '#js-create-membership'

    events:
      'click @ui.createMembership': 'createClicked'

    createClicked: ->
      view = @
      user = @model
      subscriptions = AlumNet.request('product:entities', {q: { feature_eq: 'subscription', status_eq: 1 }})
      subscriptions.on 'fetch:success', (collection)->
        @subscriptions = collection
        modalView = new UserShow.ModalPremium
          model: user
          collection: collection
        modalView.on 'added', ->
          view.collection.fetch()
        view.modals.show(modalView)

    change: ->
      @render()

  class UserShow.ModalPremium extends Backbone.Modal
    template: 'admin/users/show/templates/modal_premium'
    viewContainer: '.modal-container'
    cancelEl: '#close-btn, #goBack'
    submitEl: "#save-status"

    initialize: (options) ->
      @model = options.model

    templateHelpers: () ->
      subscriptions: @subscriptions

    events: ->
      'click .product': 'clickProduct'

    submit: () ->
      $('#save-status').attr('disabled', 'disabled')
      view = @
      data = Backbone.Syphon.serialize(this)
      id = data.product_id
      user_id = @model.id
      user = @model
      product = AlumNet.request 'product:find', id
      url = AlumNet.api_endpoint + "/users/#{user_id}/products/#{id}/add_product"
      data.user_id = id

      Backbone.ajax
        url: url
        type: "POST"
        data: data
        success: =>
          view.trigger 'added'
        error: (response) =>
          console.log(response)

    clickProduct: ->
      $('#save-status').removeAttr('disabled')
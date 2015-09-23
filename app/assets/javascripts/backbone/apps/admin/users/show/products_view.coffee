@AlumNet.module 'AdminApp.UserShow', (UserShow, @AlumNet, Backbone, Marionette, $, _) ->

  class UserShow.Product extends Marionette.ItemView
    template: 'admin/users/show/templates/_product'
    tagName: 'tr'

    initialize: (options) ->
      console.log @model
      console.log @model.get('user')
      @user = AlumNet.request('user:find', @model.get('user').id)
      console.log @user
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
      date = new Date(@model.get('end_date'))
      date.toDateString()

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
      data = {member: 1}
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
@AlumNet.module 'AdminApp.UserShow', (UserShow, @AlumNet, Backbone, Marionette, $, _) ->

  class UserShow.Product extends Marionette.ItemView
    template: 'admin/users/show/templates/_product'
    tagName: 'tr'

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
      console.log e
      user_product = new AlumNet.Entities.UserProduct
        id: e.currentTarget.id
        user_id: @model.get('user').id

      console.log user_product


      user_product.fetch
        success: ->
          console.log user_product




      



  class UserShow.Products extends Marionette.CompositeView
    template: 'admin/users/show/templates/products'
    childView: UserShow.Product
    childViewContainer: '#js-products-container'
    childViewOptions: ->
      user: @model
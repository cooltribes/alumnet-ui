@AlumNet.module 'AdminApp.CategoriesList', (CategoriesList, @AlumNet, Backbone, Marionette, $, _) ->
  class CategoriesList.Layout extends Marionette.LayoutView
    template: 'admin/categories/list/templates/layout'
    className: 'container'
    regions:
      table: '#table-region'

  class CategoriesList.CategoryView extends Marionette.ItemView
    template: 'admin/categories/list/templates/category'
    tagName: "tr"

    modelEvents:
      "change": "modelChange"

    bindings:
      ".js-name": 
        observe: "name"
        events: ['blur']
      ".js-description": 
        observe: "description"
        events: ['blur']
      ".js-status": 
        observe: "status"
        selectOptions:
          collection: [
            value: "inactive"
            label: "inactive"
          ,
            value: "active"
            label: "active"
          ,
          ]
      ".js-category": 
        observe: "category_id"
        selectOptions:
          collection: 'this.categories'

    initialize: ->
      console.log 'initialize'
      console.log @model

    templateHelpers: ->
      model = @model
      parent_category_name: ->
        if model.get('parent')
          model.get('parent').name
        else
          'Parent category'

    onRender: ->
      @stickit()

    modelChange: (e)->
      @model.save()

  class CategoriesList.CategoriesTable extends Marionette.CompositeView
    template: 'admin/categories/list/templates/categories_table'
    childView: CategoriesList.CategoryView
    childViewContainer: "#categories-table tbody"

  class CategoriesList.CreateForm extends Marionette.ItemView
    template: 'admin/categories/list/templates/form'

    initialize: ->
      Backbone.Validation.bind this,
        valid: (view, attr, selector) ->
          view.clearErrors(attr)
        invalid: (view, attr, error, selector) ->
          view.addErrors(attr, error)

    templateHelpers: ->
      model = @model

    ui:
      'cancelLink': '.js-cancel'
      'submitLink': '.js-submit'

    events:
      'click @ui.cancelLink': 'cancelClicked'
      'click @ui.submitLink': 'submitClicked'

    onRender: ->
      view = @
      data = AlumNet.request("categories:entities:select")
      data.unshift({id: 0, text: 'None'})
      view.$('.js-categories').select2
        placeholder: "Empty for top category"
        data: data

    cancelClicked: (e)->
      e.preventDefault()

    submitClicked: (e)->
      @ui.submitLink.add(@ui.cancelLink).attr("disabled", "disabled")
      e.preventDefault()
      view = @
      data = Backbone.Syphon.serialize(this)
      @model.set(data)
      if @model.isValid(true)
        @model.save data,
          success: (model)->
            $.growl.notice({ message: "Category successfully created" })
            AlumNet.trigger "admin:categories"
          error: (model, response)->
            errors = response.responseJSON
            _.each errors, (value, key, list)->
              view.clearErrors(key)
              view.addErrors(key, value[0])
            # @ui.submitLink.add(@ui.cancelLink).removeAttr("disabled")


      # @ui.submitLink.add(@ui.cancelLink).removeAttr("disabled")

    processData: (data)->
      formData = new FormData()
      _.each data, (value, key, list)->
        formData.append(key, value)
      formData

    clearErrors: (attr)->
      $el = @$("[name=#{attr}]")
      $group = $el.closest('.form-group')
      $group.removeClass('has-error')
      $group.find('.help-block').html('').addClass('hidden')

    addErrors: (attr, error)->
      $el = @$("[name=#{attr}]")
      $group = $el.closest('.form-group')
      $group.addClass('has-error')
      $group.find('.help-block').html(error).removeClass('hidden')
      @ui.submitLink.add(@ui.cancelLink).removeAttr("disabled")
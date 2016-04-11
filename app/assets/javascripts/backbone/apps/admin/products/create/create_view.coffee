@AlumNet.module 'AdminApp.ProductsCreate', (ProductsCreate, @AlumNet, Backbone, Marionette, $, _) ->
  class ProductsCreate.Layout extends Marionette.LayoutView
    template: 'admin/products/list/templates/layout'
    className: 'container'
    regions:
      table: '#table-region'

  class ProductsCreate.CreateForm extends Marionette.ItemView
    template: 'admin/products/create/templates/form'

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
      'submitLink': '.js-save'

    events:
      'click @ui.cancelLink': 'cancelClicked'
      'click @ui.submitLink': 'submitClicked'
      'change #product-image': 'previewImage'

    onRender: ->
      view = @
      data = AlumNet.request("categories:entities:select")
      view.$('.js-categories').select2
        placeholder: "Select a Category"
        data: data

    cancelClicked: (e)->
      e.preventDefault()

    submitClicked: (e)->
      @ui.submitLink.add(@ui.cancelLink).attr("disabled", "disabled")
      e.preventDefault()

      view = @
      model = @model

      #Guardar con imagen
      formData = new FormData()
      data = Backbone.Syphon.serialize(this)
      console.log data
      _.forEach data, (value, key, list)->
        formData.append(key, value)
      file = @$('#product-image')
      formData.append('image', file[0].files[0])
      console.log formData

      options_for_save =
        wait: true
        contentType: false
        processData: false
        data: formData
        success: (model, response, options)->
          $.growl.notice({ message: "Product successfully created" })
          AlumNet.trigger "admin:products"
      model.save(formData, options_for_save)


      
      # data = Backbone.Syphon.serialize(this)
      # @model.set(data)
      # if @model.isValid(true)
      #   @model.save data,
      #     success: (model)->
      #       $.growl.notice({ message: "Product successfully created" })
      #       AlumNet.trigger "admin:products"
      #     error: (model, response)->
      #       errors = response.responseJSON
      #       _.each errors, (value, key, list)->
      #         view.clearErrors(key)
      #         view.addErrors(key, value[0])
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

    previewImage: (e)->
      input = @.$('#product-image')
      preview = @.$('#prewiev-product-image')
      if input[0] && input[0].files[0]
        reader = new FileReader()
        reader.onload = (e)->
          preview.attr("src", e.target.result)
        reader.readAsDataURL(input[0].files[0])
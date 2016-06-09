@AlumNet.module 'AdminApp.AttributesCreate', (AttributesCreate, @AlumNet, Backbone, Marionette, $, _) ->
  class AttributesCreate.Layout extends Marionette.LayoutView
    template: 'admin/categories/list/templates/layout'
    className: 'container'
    regions:
      table: '#table-region'

  class AttributesCreate.CreateForm extends Marionette.ItemView
    template: 'admin/attributes/create/templates/form'

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

    cancelClicked: (e)->
      e.preventDefault()

    submitClicked: (e)->
      @ui.submitLink.attr("disabled", "disabled")
      e.preventDefault()
      view = @
      data = Backbone.Syphon.serialize(this)
      @model.set(data)
      if @model.isValid(true)
        @model.save data,
          success: (model)->
            $.growl.notice({ message: "Attribute successfully created" })
            AlumNet.trigger "admin:attributes"
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
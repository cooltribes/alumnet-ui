@AlumNet.module 'AdminApp.Regions', (Regions, @AlumNet, Backbone, Marionette, $, _) ->
  class Regions.Layout extends Marionette.LayoutView
    template: 'admin/regions/list/templates/layout'
    className: 'container'
    regions:
      search: '#search-region'
      table: '#table-region'

  class Regions.RegionView extends Marionette.ItemView
    template: 'admin/regions/list/templates/region'
    tagName: "tr"
    initialize: ->
      @listenTo(@model, 'render:view', @renderView)

    templateHelpers: ->
      countries_length: if @model.countries() then @model.countries().length else 0

    ui:
      'editLink': '.js-edit'

    events:
      'click @ui.editLink': 'showModal'

    renderView: ->
      @render()

    showModal: (e)->
      e.preventDefault()
      modal = new Regions.ModalRegion
        model: @model #region
      $('#container-modal').html(modal.render().el)

  class Regions.RegionsTable extends Marionette.CompositeView
    template: 'admin/regions/list/templates/regions_table'
    childView: Regions.RegionView
    childViewContainer: "#regions-table tbody"

  class Regions.ModalRegion extends Backbone.Modal
    template: 'admin/regions/list/templates/modal_form'
    cancelEl: '#js-modal-close'
    initialize: (options)->
      @regionTable = options.regionTable
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

    templateHelpers: ->
      regionIsNew: @model.isNew()

    events:
      'click #js-modal-save': 'saveClicked'
      'click #js-modal-delete': 'deleteClicked'

    saveClicked: (e)->
      e.preventDefault()
      modal = @
      model = @model
      table = @regionTable
      data = Backbone.Syphon.serialize(modal)
      data.country_ids = data.country_ids.split(',')
      @model.save data,
        success: ->
          modal.destroy()
          model.trigger('render:view')
          if table
            table.collection.add(model)

    deleteClicked: (e)->
      e.preventDefault()
      modal = @
      resp = confirm('Are you sure?')
      if resp
        @model.destroy
          success: ->
            modal.destroy()

    onRender: ->
      data = AlumNet.request("get:availables:countries")

      @.$('.js-countries').select2
        multiple: true
        placeholder: "Select a Country"
        data: data
      @.$('.js-countries').select2('data', @model.countries())

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
      'click #js-add-admin':'showModalAdmin'

    modelEvents:
      'updateView':'renderView'

    renderView: ->
      console.log "render view"
      console.log @model
      @render()

    showModal: (e)->
      e.preventDefault()
      modal = new Regions.ModalRegion
        model: @model #region

      $('#container-modal').html(modal.render().el)

    showModalAdmin: (e)->
      e.preventDefault()
      modal = new Regions.ModalRegionAdmin
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

  class Regions.ModalRegionAdmin extends Backbone.Modal
    template: 'admin/regions/list/templates/modal_admins'
    cancelEl: '#js-modal-close'
    submitEl: "#js-modal-save"

    submit: ()->
      model=@model
      oldAdmins=model.get('admins').map (model)->
        id: model.id
      Admins=Backbone.Syphon.serialize(this)
      newAdmins=Admins.users.split(',')
      idRegion = @model.id
      
      $.each newAdmins, (v,id)->
        url = AlumNet.api_endpoint + "/admin/users/#{id}/change_role"
        Backbone.ajax
          url:url
          type: "PUT"
          data: 
            role:"regional"
            admin_location_id:idRegion
          error: (data) =>
            text = data.responseJSON[0]
            $.growl.error({ message: text })

      $.each oldAdmins, (v,oldId)->
        aux=false
        for id in newAdmins
          if oldId.id==parseInt(newAdmins)
            aux=true
            break
        if aux == false
          url = AlumNet.api_endpoint + "/admin/users/#{oldId.id}/change_role"
          Backbone.ajax
            url:url
            type: "PUT"
            data: 
              role:"regular"
              admin_location_id:1
      
      model.fetch
        success: ->
          model.trigger('updateView')  

      #  url = AlumNet.api_endpoint + "/admin/users/#{ids}/change_role"
      #  Backbone.ajax
      #    url:url
      #    type: "PUT"
      #    data: 
      #      role:"regional"
      #      admin_location_id:idRegion
      #    error: (data) =>
      #      text = data.responseJSON[0]
      #      $.growl.error({ message: text })
      #model.fetch
      #  success: ->
      #    model.trigger('updateView')



    onRender: ->
      admins=@model.get('admins')
      rAdmins = admins.map (model)->
        id: model.id
        text: model.name
        photo: model.avatar
      users = AlumNet.request('user:entities', {})
      users.fetch
       success: ->
        usersMap = users.map (model)->
          id: model.id
          text: model.get('name')
          photo: model.get('avatar').small      

        @.$('.js-users').select2
          multiple: true
          placeholder: "Select a user"
          data:usersMap
        @.$('.js-users').select2('data',rAdmins)

        #formatResult: formatResult: (item)->
          #if !item.id 
           # return item.text
          #return '<span><img src="' + item.photo + '" class="img-flag" /> ' + item.text + '</span>'
@AlumNet.module 'AdminApp.PrizesList', (PrizesList, @AlumNet, Backbone, Marionette, $, _) ->
  class PrizesList.Layout extends Marionette.LayoutView
    template: 'admin/prizes/list/templates/layout'
    className: 'container'
    regions:
      table: '#table-region'

  class PrizesList.PrizeView extends Marionette.ItemView
    template: 'admin/prizes/list/templates/prize'
    tagName: "tr"

    modelEvents:
      "change": "modelChange"

    events:
      'change #prize-photo': 'previewImage'

    bindings:
      ".js-name": 
        observe: "name"
        events: ['blur']
      ".js-description": 
        observe: "description"
        events: ['blur']
      ".js-price": 
        observe: "price"
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
      ".js-type": 
        observe: "prize_type"
        selectOptions:
          collection: [
            value: 0
            label: "Time remaining"
          ,
            value: 1
            label: "Times used"
          ,
          ]
      ".js-quantity": 
        observe: "quantity"
        events: ['blur']

      ".js-prizeImage": "image"

    initialize: (options) ->
      @prizeImage = options.model.get('image').image.card.url

    templateHelpers: ->
      prizeImage: @prizeImage

    onRender: ->
      @stickit()

    modelChange: (e)->
      @model.save()

    previewImage: (e)->
      $(e.currentTarget).siblings('div.loadingAnimation__migrateUsers').css('display','inline-block')
      $(e.currentTarget).siblings('.uploadF--blue').css('display','none')
      $(e.currentTarget).siblings('img').css('top',0)
      input = @.$('#prize-photo')
      preview = @.$('#prewiev-prize-photo')
      model = @model
      currentTarget= e.currentTarget

      formData = new FormData()
      file = @$('#prize-photo')
      formData.append('image', file[0].files[0])

      options_for_save =
        wait: true
        contentType: false
        processData: false
        data: formData
        success: (model, response, options)->
          if input[0] && input[0].files[0]
           reader = new FileReader()
           reader.onload = (e)->
              preview.attr("src", e.target.result)
              $(currentTarget).siblings('div.loadingAnimation__migrateUsers').css('display','none')
              $(currentTarget).siblings('.uploadF--blue').css('display','inline-block')
              $(currentTarget).siblings('img').css('top',-30)
           reader.readAsDataURL(input[0].files[0])
          #modal.destroy()
          #model.trigger('render:view')
          #if table
            #table.collection.add(model)
      model.save(formData, options_for_save)
      # if input[0] && input[0].files[0]
      #   reader = new FileReader()
      #   reader.onload = (e)->
      #     preview.attr("src", e.target.result)
      #   reader.readAsDataURL(input[0].files[0])

  class PrizesList.PrizesTable extends Marionette.CompositeView
    template: 'admin/prizes/list/templates/prizes_table'
    childView: PrizesList.PrizeView
    childViewContainer: "#prizes-table tbody"

  class PrizesList.ModalPrize extends Backbone.Modal
    template: 'admin/prizes/list/templates/modal_form'
    cancelEl: '#js-modal-close'

    initialize: (options)->
      @prizeTable = options.prizeTable

    templateHelpers: ->
      prizeIsNew: @model.isNew()

    events:
      'click #js-modal-save': 'saveClicked'
      'click #js-modal-delete': 'deleteClicked'
      'change #prize-photo': 'previewImage'

    saveClicked: (e)->
      e.preventDefault()
      modal = @
      model = @model
      table = @prizeTable

      #Guardar con imagen
      formData = new FormData()
      data = Backbone.Syphon.serialize(this)
      console.log data
      _.forEach data, (value, key, list)->
        formData.append(key, value)
      file = @$('#prize-photo')
      formData.append('image', file[0].files[0])
      console.log formData

      options_for_save =
        wait: true
        contentType: false
        processData: false
        data: formData
        success: (model, response, options)->
          modal.destroy()
          model.trigger('render:view')
          if table
            table.collection.add(model)
      model.save(formData, options_for_save)

      #Guardar sin la imagen
      # data = Backbone.Syphon.serialize(modal)
      # @model.save data,
      #   success: ->
      #     modal.destroy()
      #     model.trigger('render:view')
      #     if table
      #       table.collection.add(model)

    deleteClicked: (e)->
      e.preventDefault()
      modal = @
      resp = confirm('Are you sure?')
      if resp
        @model.destroy
          success: ->
            modal.destroy()

    previewImage: (e)->
      input = @.$('#prize-photo')
      preview = @.$('#prewiev-prize-photo')
      if input[0] && input[0].files[0]
        reader = new FileReader()
        reader.onload = (e)->
          preview.attr("src", e.target.result)
        reader.readAsDataURL(input[0].files[0])
@AlumNet.module 'UsersApp.Shared', (Shared, @AlumNet, Backbone, Marionette, $, _) ->
  class Shared.Header extends Marionette.ItemView
    template: 'users/shared/templates/header'

    ui:
      "editPic": "#js-editPic"
      "editCover": "#js-editCover"
      "modalCont": "#js-picture-modal-container"
      'requestLink': '#js-request-send'   #Id agregado
      'coverArea': 'userCoverArea'
      'imgAvatar': '#preview-avatar'
      'profileCover': '#profile-cover'

    events:
      "click @ui.editPic": "editPic"
      "click @ui.editCover": "editCover"
      'change @ui.profileCover': 'saveCover'
      'click #js-request-send': 'sendRequest' #Evento agregado
      'click #js-message-send': 'sendMensagge'

    initialize: (options)->
      @model = options.model
      document.title = 'AlumNet - '+@model.get("name")
      @userCanEdit = AlumNet.current_user.isAlumnetAdmin() || @model.isCurrentUser()

      if options.userCanEdit?
        @userCanEdit = options.userCanEdit

      @listenTo(@model, 'change:avatar', @renderView)
      @listenTo(@model, 'change:cover', @renderView)


    templateHelpers: ->
      model = @model
      date = new Date()
      userCanEdit: @userCanEdit
      isActive: model.isActive()
      cover_style: ->
        cover = model.get('cover')
        if cover.main
          "background-image: url('#{cover.main}?#{date.getTime()}');"
        else
          "background-color: #2b2b2b;"
      add_timestamp: (file)->
        "#{file}?#{date.getTime()}"

      position: ->
        model.profile.get("last_experience") ? "No Position"

    renderView: ->
      view = @
      coverArea = @ui.coverArea
      @model.fetch
        success: ->
          view.render()
          coverArea.backgroundDraggable()

    editPic: (e)->
      e.preventDefault()
      modal = new AlumNet.UsersApp.About.ProfileModal
        view: this
        type: 3
        model: @model
      @ui.modalCont.html(modal.render().el)

    editCover: (e)->
      e.preventDefault()
      #modal = new AlumNet.UsersApp.About.CropCoverModal
      #  model: @model
      #@ui.modalCont.html(modal.render().el)
      console.log  "editCover"
      @.$('.userCoverArea').backgroundDraggable()
      #@ui.coverArea.backgroundDraggable()

    saveCover: (e)->
      e.preventDefault()
      console.log "saveCover"
      data = Backbone.Syphon.serialize this
      console.log data.cover
      if data.cover != ""
        console.log "entro"
        model = @model
        modal = @
        formData = new FormData()
        file = @$('#profile-cover')
        formData.append('cover', file[0].files[0])
        @model.profile.url = AlumNet.api_endpoint + '/profiles/' + @model.profile.id
        @model.profile.save formData,
          wait: true
          data: formData
          contentType: false
          processData: false
          success: ()->
            model.trigger('change:cover')
            #modalCrop = new About.CropCoverModal
            #  model: model
            #$('#js-picture-modal-container').html(modalCrop.render().el)
            #modal.destroy()

    sendRequest: (e)->
      attrs = { friend_id: @model.id }
      friendship = AlumNet.request('current_user:friendship:request', attrs)
      AlumNet.current_user.incrementCount('pending_sent_friendships')
      friendship.on 'save:success', (response, options) =>
      @model.fetch
        success: ->
          @$('#js-request-sent').html('<a type="button" class="userCoverArea__btnInvite userCoverArea__btnInviteSent btn-lg" style="right: 280px;"> REQUEST SENT</a>') # or remove.

    sendMensagge: (e)->
      e.preventDefault()
      AlumNet.trigger('conversation:recipient', null, @model)


  class Shared.Layout extends Marionette.LayoutView
    template: 'users/shared/templates/layout'

    regions:
      header: '#user-header'
      body: '#user-body'

    initialize: (options) ->
      @tab = options.tab
      @class = ["", "", ""
        "", ""
      ]
      @class[parseInt(@tab)] = "--active"

    templateHelpers: ->
      classOf: (step) =>
        @class[step]

  API =
    getUserLayout: (model, tab)->
      new Shared.Layout
        model: model
        tab: tab

    getUserHeader: (model, options)->
      options = _.extend options, model: model
      new Shared.Header options


  AlumNet.reqres.setHandler 'user:layout', (model, tab) ->
    API.getUserLayout(model, tab)

  AlumNet.reqres.setHandler 'user:header', (model, options = {})->
    API.getUserHeader(model, options)
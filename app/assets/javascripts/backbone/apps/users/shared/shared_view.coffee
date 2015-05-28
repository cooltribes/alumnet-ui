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

    events:
      "click @ui.editPic": "editPic"
      "click @ui.editCover": "editCover"
      'click #js-request-send':'sendRequest' #Evento agregado
      'click #js-message-send':'sendMensagge'

    initialize: (options)->
      @userCanEdit = AlumNet.current_user.isAlumnetAdmin() || @model.isCurrentUser()
      
      if options.userCanEdit?
        @userCanEdit = options.userCanEdit

      @listenTo(@model, 'change:avatar', @renderView)
      @listenTo(@model, 'change:cover', @renderView)

    templateHelpers: ->
      model = @model
      date = new Date()
      userCanEdit: @userCanEdit
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
      @model.fetch
        success: ->
          view.render()

    editPic: (e)->
      e.preventDefault()
      modal = new AlumNet.UsersApp.About.ProfileModal
        view: this
        type: 3
        model: @model
      @ui.modalCont.html(modal.render().el)



    editCover: (e)->
      e.preventDefault()
      modal = new AlumNet.UsersApp.About.CoverModal
        model: @model
      @ui.modalCont.html(modal.render().el)

    sendRequest: (e)->
      attrs = { friend_id: @model.id }
      friendship = AlumNet.request('current_user:friendship:request', attrs)
      AlumNet.current_user.incrementCount('pending_sent_friendships')
      friendship.on 'save:success', (response, options) =>
      @model.fetch
        success: ->
          @$('#js-request-send').hide() # or remove.

    sendMensagge: (e)->
      e.preventDefault()
      AlumNet.trigger('conversation:recipient', @model)


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
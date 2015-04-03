@AlumNet.module 'UsersApp.Shared', (Shared, @AlumNet, Backbone, Marionette, $, _) ->
  class Shared.Header extends Marionette.ItemView
    template: 'users/shared/templates/header'

    ui:
      "editPic": "#js-editPic"
      "cropPic": "#js-cropPic"
      "editCover": "#js-editCover"
      "cropCover": "#js-cropCover"
      "modalCont": "#js-picture-modal-container"
      'requestLink': '#js-request-send'   #Id agregado
      'coverArea': 'userCoverArea'
    events:
      "click @ui.editPic": "editPic"
      "click @ui.cropPic": "cropPic"
      "click @ui.editCover": "editCover"
      "click @ui.cropCover": "cropCover"
      'click #js-request-send':'sendRequest' #Evento agregado
    modelEvents:
      "change": "modelChange"

    initialize: (options)->
      @userCanEdit = options.userCanEdit

    templateHelpers: ->
      model = @model
      userCanEdit: @userCanEdit
      cover_style: ->
        cover = model.get('cover')
        if cover
          "background-image: url('#{cover.main}');"
        else
          "background-color: #2b2b2b;"
      position: ->
        model.profile.get("last_experience") ? "No Position"

    modelChange: ->
      @render()

    editPic: (e)->
      e.preventDefault()
      modal = new AlumNet.UsersApp.About.ProfileModal
        view: this
        type: 3
        model: @model
      @ui.modalCont.html(modal.render().el)

    cropPic: (e)->
      e.preventDefault()
      modal = new AlumNet.UsersApp.About.CropAvatarModal
        model: @model
      @ui.modalCont.html(modal.render().el)

    editCover: (e)->
      e.preventDefault()
      modal = new AlumNet.UsersApp.About.CoverModal
        model: @model
      @ui.modalCont.html(modal.render().el)

    cropCover: (e)->
      e.preventDefault()
      modal = new AlumNet.UsersApp.About.CropCoverModal
        model: @model
      @ui.modalCont.html(modal.render().el)

    sendRequest: (e)->
      attrs = { friend_id: @model.id }
      friendship = AlumNet.request('current_user:friendship:request', attrs)
      friendship.on 'save:success', (response, options) =>
        @model.fetch()



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
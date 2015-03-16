@AlumNet.module 'AdminApp.UsersDeleted', (UsersDeleted, @AlumNet, Backbone, Marionette, $, _) ->
  class UsersDeleted.Layout extends Marionette.LayoutView
    template: 'admin/users/deleted/templates/layout'
    className: 'container'
    regions:
      search: '#search-region'
      table: '#table-region'

  class UsersDeleted.UserView extends Marionette.ItemView
    template: 'admin/users/deleted/templates/user'
    tagName: "tr"

    initialize: ->
      @listenTo(@model, 'render:view', @renderView)

    templateHelpers: ->
      model = @model
      getEmail: ()->
        model.get('email')

      getName: ()->
        name = model.get('name')
        if name.trim()
          return name
        "No name registered"

      getJoinTime: ()->
        moment(model.get('created_at')).fromNow()

    ui:
      'restoreLink': '#js-user-restore'
      'destroyLink': '#js-user-destroy'

    events:
      'click @ui.restoreLink': 'restoreClicked'
      'click @ui.destroyLink': 'destroyClicked'

    restoreClicked: (e)->
      e.preventDefault()
      collection = @model.collection
      @model.save {},
        success: (model)->
          collection.remove(model)

    destroyClicked: (e)->
      e.preventDefault()
      resp = confirm('This action destroy the user permanently. ¿Are you sure?')
      if resp
        @model.destroy()

    renderView: ->
      @render()

  class UsersDeleted.UsersTable extends Marionette.CompositeView
    template: 'admin/users/deleted/templates/users_deleted_table'
    childView: UsersDeleted.UserView
    childViewContainer: "#users-deleted-table tbody"
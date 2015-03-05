@AlumNet.module 'AdminApp.Users', (Users, @AlumNet, Backbone, Marionette, $, _) ->

  class Users.Layout extends Marionette.LayoutView
    template: 'admin/users/list/templates/layout'
    className: 'container'
    regions:
      modals:
        selector: '#modals-region'
        regionClass: Backbone.Marionette.Modals
      filters: '#filters-region'
      main: '#table-region'


  #----Modal principal con las acciones----
  class Users.ModalActions extends Backbone.Modal
    template: 'admin/users/list/templates/modal_actions'

    cancelEl: '#close-btn'
    submitEl: "#save-status"

    events:
      'click #editStatus': 'openStatus'
      'click #delete-user': 'deleteUser'


    initialize: (options) ->
      @modals = options.modals

    deleteUser: (e)->
      e.preventDefault()
      resp = confirm("Are you sure?")
      if resp
        @model.destroy()
        @modals.destroy() #Se debe llamar destroy en la region de los modals, no el modal como tal.        

    openStatus: (e) ->
      e.preventDefault();

      statusView = new Users.ModalStatus
        model: @model
        modals: @modals

      @modals.show(statusView);

  #----Modal para cambiar le status
  class Users.ModalStatus extends Backbone.Modal
    template: 'admin/users/list/templates/modal_status'

    cancelEl: '#close-btn, #goBack'
    submitEl: "#save-status"

    events:
      'click #save-status': 'saveStatus'

    submit: () ->
      data = Backbone.Syphon.serialize(this)
      id = @model.id
      if data.status == "1"
        url = AlumNet.api_endpoint + "/admin/users/#{id}/activate"
      else
        url = AlumNet.api_endpoint + "/admin/users/#{id}/inactivate"

      Backbone.ajax
        url: url
        type: "PUT"
        success: (data) =>
          @model.set(data)
        error: (data) =>
          text = data.responseJSON[0]
          $.growl.error({ message: text })


  #----Modal para cambiarle el plan de membresia a un user----
  class Users.ModalPlan extends Backbone.Modal
    template: 'admin/users/list/templates/modal_plan'

    viewContainer: '.my-container'
    cancelEl: '#close-btn'
    submitEl: "#save-status"



  class Users.UserView extends Marionette.ItemView
    template: 'admin/users/list/templates/_user'
    tagName: "tr"
    ui:
      'btnEdit': '.js-edit'
    events:
      'click @ui.btnEdit': 'showActions'

    initialize: (options) ->
      @modals = options.modals
      @listenTo(@model, 'change:status', @modelChange)


    templateHelpers: () ->

      getAge: ()->
        if @profileData.born
          return moment().diff(@profileData.born, 'years')
        "No age"

      getJoinTime: ()->
        moment(@created_at).fromNow()

      getOriginLocation: ()->
        if @profileData.birth_city
          return "#{@profileData.birth_city.text} - #{@profileData.birth_country.text}"
        "No origin location"

      getLC: ()->
        if @profileData.local_committee
          return @profileData.local_committee.name
        "No local committee"

      getEmail: ()->
        @email

      getName: ()->
        if @name.trim()
          return @name
        "No name registered"

      getGender: ()->
        if @profileData.gender
          return @profileData.gender
        "No gender"

    modelChange: ->
      @render()


    showActions: (e)->
      e.stopPropagation()
      e.preventDefault()

      modalsView = new Users.ModalActions
        model: @model
        modals: @modals

      @modals.show(modalsView)


  class Users.UsersTable extends Marionette.CompositeView
    template: 'admin/users/list/templates/users_container'
    childView: Users.UserView
    childViewContainer: "#users-table tbody"

    initialize: (options) ->
      @modals = options.modals

    childViewOptions: (model, index) ->
      modals: @modals




  ###Filters views###
  class Users.Filter extends Marionette.ItemView
    template: 'admin/users/list/templates/filter'
    tagName: "form"

    ui:
      'btnRmv': '.js-rmvRow'
      'field': 'input[name=field]'
      'me': 'el'


    events:
      "click @ui.btnRmv": "removeRow"
      "change @ui.field": "changeField"
      "sumbit me": "sumbitForm"

    initialize: ->
      Backbone.Validation.bind this,
        valid: (view, attr, selector) ->
          $el = view.$("[name^=#{attr}]")
          $group = $el.closest('.form-group')
          $group.removeClass('has-error')
          $group.find('.help-block').html('').addClass('hidden')
        invalid: (view, attr, error, selector) ->
          $el = view.$("[name^=#{attr}]")
          $group = $el.closest('.form-group')
          $group.addClass('has-error')
          $group.find('.help-block').html(error).removeClass('hidden')

    sumbitForm: (e)->
      e.preventDefault()

    removeRow: (e)->
      @model.destroy()


  class Users.Filters extends Marionette.CompositeView
    template: 'admin/users/list/templates/filters_container'

    childView: Users.Filter
    childViewContainer: "#js-filters"

    ui:
      'btnAdd': '.js-addRow'
      'btnSearch': '.js-search'
      'btnReset': '.js-reset'
      'logicOp': '[name=logicOp]'

    events:
      "click @ui.btnAdd": "addRow"
      "click @ui.btnSearch": "search"
      "click @ui.btnReset": "reset"


    addRow: (e)->
      newFilter = new AlumNet.Entities.Filter
      @collection.add(newFilter)


    reset: (e)->
      @collection.reset()
      @trigger('filters:search')

    search: (e)->
      e.preventDefault()
      @children.each (itemView)->
        data = Backbone.Syphon.serialize itemView
        itemView.model.set data
      @trigger('filters:search')




    # initialize: (options) ->
    #   @modals = options.modals

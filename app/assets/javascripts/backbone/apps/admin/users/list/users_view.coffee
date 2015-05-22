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

  #----Modal para cambiar suscripcion
  class Users.ModalPremium extends Backbone.Modal
    template: 'admin/users/list/templates/modal_premium'

    cancelEl: '#close-btn, #goBack'
    submitEl: "#save-status"

    submit: () ->
      data = Backbone.Syphon.serialize(this)
      id = @model.id
      url = AlumNet.api_endpoint + "/users/#{id}/subscriptions"
      data.user_id = id

      console.log(data)

      Backbone.ajax
        url: url
        type: "POST"
        data: data
        success: (data) =>
          console.log("success")
          console.log(data)
        error: (data) =>
          console.log("error")
          console.log(data)

    onRender: ->
      min_date = moment().format("YYYY-MM-DD")
      max_date = moment().add(20, 'years').format("YYYY-MM-DD")
      @$(".js-date-start-date").Zebra_DatePicker
        show_icon: false
        show_select_today: false
        view: 'years'
        default_position: 'below'
        direction: [min_date, max_date]
        onOpen: (e) ->
          $('.Zebra_DatePicker.dp_visible').zIndex(99999999999)

      @$(".js-date-end-date").Zebra_DatePicker
        show_icon: false
        show_select_today: false
        view: 'years'
        default_position: 'below'
        direction: [min_date, max_date]
        onOpen: (e) ->
          $('.Zebra_DatePicker.dp_visible').zIndex(99999999999)

  #----Modal para cambiar le status
  class Users.ModalStatus extends Backbone.Modal
    template: 'admin/users/list/templates/modal_status'

    cancelEl: '#close-btn, #goBack'
    submitEl: "#save-status"

    submit: () ->
      data = Backbone.Syphon.serialize(this)
      id = @model.id
      if data.status == "1"
        url = AlumNet.api_endpoint + "/admin/users/#{id}/activate"
      else
        url = AlumNet.api_endpoint + "/admin/users/#{id}/banned"

      Backbone.ajax
        url: url
        type: "PUT"
        success: (data) =>
          @model.set(data)
          @model.trigger 'change:role'
        error: (data) =>
          text = data.responseJSON[0]
          $.growl.error({ message: text })

  #----Modal para cambiar el rol
  class Users.ModalRole extends Backbone.Modal
    template: 'admin/users/list/templates/modal_role'

    cancelEl: '#close-btn, #goBack'
    submitEl: "#save-role"

    initialize: ->
      @model.set('roleText', @model.getRole())

    onRender: ->
      role = @model.getRole()
      @setSelectLocation(role, @model.get('admin_location'))

    events:
      'change select#role': 'displayLocations'

    displayLocations: (e)->
      role = $(e.currentTarget).val()
      @setSelectLocation(role)

    setSelectLocation: (role, value)->
      if role == "nacional"
        data = CountryList.toSelect2()
      else if role == "regional"
        data = AlumNet.request('get:regions:select2')
      else
        @.$('#js-location').select2('destroy')

      if data
        @.$('#js-location').select2
          placeholder: "Select Location"
          data: data
        if value
          @.$('#js-location').select2('data', value)

    submit: () ->
      data = Backbone.Syphon.serialize(this)
      console.log data
      id = @model.id
      url = AlumNet.api_endpoint + "/admin/users/#{id}/change_role"
      Backbone.ajax
        url: url
        type: "PUT"
        data: data
        success: (data) =>
          @model.set(data)
          @model.trigger 'change:role'
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
      'click #editPremium': 'openPremium'
      'click #editStatus': 'openStatus'
      'click #delete-user': 'deleteUser'
      'click #editRole': 'openRole'

    initialize: (options) ->
      @modals = options.modals
      @listenTo(@model, 'change:role', @modelChange)


    templateHelpers: () ->

      member= @model.member

      getRoleText: @model.getRole()

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

    deleteUser: (e)->
      e.preventDefault()
      resp = confirm("Are you sure?")
      if resp
        @model.destroy()
        @modals.destroy() #Se debe llamar destroy en la region de los modals, no el modal como tal.

    openPremium: (e) ->
      e.preventDefault();

      statusView = new Users.ModalPremium
        model: @model
        modals: @modals

      @modals.show(statusView)

    openStatus: (e) ->
      e.preventDefault();

      statusView = new Users.ModalStatus
        model: @model
        modals: @modals

      @modals.show(statusView)

    openRole: (e) ->
      e.preventDefault();

      statusView = new Users.ModalRole
        model: @model
        modals: @modals

      @modals.show(statusView)


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
      "selectType": ".filter_by"
      'me': 'el'
      "value": "[name=value]"
      "comparator": "[name=comparator]"
      
    events:
      "click @ui.btnRmv": "removeRow"
      "change .filter_by, click .filter_by" : "changeField"
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

    onRender: ->  
      @$(".js-date").Zebra_DatePicker
        show_icon: false
        show_select_today: false
        view: 'years'
        default_position: 'below'
        direction: ['2015-01-01', '2030-12-12']
        onOpen: (e) ->
          $('.Zebra_DatePicker.dp_visible').zIndex(99999999999) 
                                    
    
    #TO DO: refactor this
    changeField: (e) ->      
      if @ui.selectType.val() =="profile_first_name_or_profile_last_name"
        @ui.comparator.empty().html(" <select  name='comparator' class='form-control input-lg'>
          <option value=''>Select comparator</option>
          <option value='cont_any'>Contains</option>
          <option value='in'>=</option>
          </select>" )  
        @ui.value.empty().html("<input type='text' name='value' id='value' class='form-control input-lg'>")         
      else if @ui.selectType.val() =="email"
        @ui.comparator.empty().html(" <select  name='comparator' class='form-control input-lg'>
          <option value=''>Select comparator</option>
          <option value='cont_any'>Contains</option>
          <option value='in'>=</option>
          </select>" )  
        @ui.value.empty().html("<input type='text' name='value' id='value' class='form-control input-lg'>") 
      else if @ui.selectType.val() =="profile_residence_country_name"
        @ui.comparator.empty().html(" <select  name='comparator' class='form-control input-lg'>
          <option value=''>Select comparator</option>
          <option value='cont_any'>Contains</option>
          <option value='in'>=</option>
          </select>" )  
        @ui.value.empty().html("<input type='text' name='value' id='value' class='form-control input-lg'>") 
      else if @ui.selectType.val() =="profile_birth_country_name"
        @ui.comparator.empty().html(" <select  name='comparator' class='form-control input-lg'>
          <option value=''>Select comparator</option>
          <option value='cont_any'>Contains</option>
          <option value='in'>=</option>
          </select>" )  
        @ui.value.empty().html("<input type='text' name='value' id='value' class='form-control input-lg'>") 
      else if @ui.selectType.val() =="profile_residence_city_name"
        @ui.comparator.empty().html(" <select  name='comparator' class='form-control input-lg'>
          <option value=''>Select comparator</option>
          <option value='cont_any'>Contains</option>
          <option value='in'>=</option>
          </select>" )  
        @ui.value.empty().html("<input type='text' name='value' id='value' class='form-control input-lg'>") 
      else if @ui.selectType.val() =="profile_birth_city_name" 
        @ui.comparator.empty().html(" <select  name='comparator' class='form-control input-lg'>
          <option value=''>Select comparator</option>
          <option value='cont_any'>Contains</option>
          <option value='in'>=</option>
          </select>" )  
        @ui.value.replaceWith("<input type='text' name='value' id='value' class='form-control input-lg'>")                
      else if @ui.selectType.val() =="profile_gender"        
        @ui.value.html( "<select name='value' class='form-control input-lg value_by'>
          <option value='M'>Male</option>  
          <option value='F'>Female</option>
          </select>" )  
        @ui.comparator.empty().append("<select  name='comparator' class='form-control input-lg'><option value='in'> = </option><option value='not_in'> <> </option></select>")                       
      else if @ui.selectType.val() =='profile_created_at'   
        @onRender()        
        @ui.comparator.html(" <select  name='comparator' class='form-control input-lg'>
          <option value=''>Select comparator</option>
          <option value='gt'>></option>
          <option value='lt'><</option>
          <option value='lteq'><=</option>
          <option value='gteq'>>=</option>
          <option value='eq'>=</option>
          </select>")
        @ui.value.empty().append("<div name='value' >
          <input type='text' class='form-control input-lg js-date' id='born'>
          </div> ")
      else if @ui.selectType.val() =='status'       
        @ui.value.html( "<select name='value' class='form-control input-lg value_by'>
          <option value='0'>Inactive</option>  
          <option value='1'>Active</option> 
          <option value='2'>Banned</option>
          </select>" )  
        @ui.comparator.empty().append("<select  name='comparator' class='form-control input-lg'><option value='in'> = </option><option value='not_in'> <> </option></select>") 
      else if @ui.selectType.val() =='member'       
        @ui.value.html( "<select name='value' class='form-control input-lg value_by'>
          <option value='0'>Registrant</option> 
          <option value='1'>Member</option>     
          <option value='2'>Lifetime Member</option>
          </select>" )  
        @ui.comparator.empty().append("<select  name='comparator' class='form-control input-lg'><option value='in'> = </option><option value='not_in'> <> </option></select>") 

    sumbitForm: (e)->
      e.preventDefault()
      @render()

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
        console.log itemView.model
      @trigger('filters:search')

    # initialize: (options) ->
    #   @modals = options.modals


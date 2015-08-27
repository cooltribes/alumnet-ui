@AlumNet.module 'CompaniesApp.Employees', (Employees, @AlumNet, Backbone, Marionette, $, _) ->
  class Employees.Layout extends Marionette.LayoutView
    template: 'companies/employees/templates/layout'
    className: 'container'
    regions:
       requests: "#requests"
       employees: "#employees"

  class Employees.Employee extends AlumNet.Shared.Views.UserView
    template: 'companies/employees/templates/_employee'
    className: 'col-md-4 col-sm-6'

    initialize: (options)->
      @company = options.company

    templateHelpers: ->
      isCompanyAdmin: @company.userIsAdmin()
      isUser: @model.id == AlumNet.current_user.id

    ui: ->
      ui =
        'createAdminLink': '.js-create-admin'
        'deleteAdminLink': '.js-delete-admin'
      _.extend ui, super()

    events: ->
      events =
        'click @ui.createAdminLink': 'createAdminClicked'
        'click @ui.deleteAdminLink': 'deleteAdminClicked'
      _.extend events, super()

    createAdminClicked: (e)->
      e.preventDefault()
      view = @
      company_admin = AlumNet.request('new:company_admin', @company.id, { user_id: @model.id })
      company_admin.save {},
        success: (model)->
          view.updateAdminRelation(true, model.id)
        error: (model, response)->
          console.log response

    deleteAdminClicked: (e)->
      e.preventDefault()
      view = @
      id = @model.get('admin_relation_id')
      company_admin = AlumNet.request('new:company_admin', @company.id, { id: id })
      company_admin.destroy
        success: (model)->
          view.updateAdminRelation(false, null)
        error: (model, response)->
          console.log response

    updateAdminRelation: (admin, relation_id)->
      @model.set('is_admin', admin)
      @model.set('admin_relation_id', relation_id)
      if admin
        @trigger('update:admins', 1)
      else
        @trigger('update:admins', -1)
      @render()

  class Employees.List extends Marionette.CompositeView
    template: 'companies/employees/templates/employees_container'
    childView: Employees.Employee
    childViewContainer: '.employees-container'
    childViewOptions: ->
      company: @model

    initialize: ->
      @collection.fetch()
      @listenTo(@model, 'update:admins', @updateAdminCount)

    onChildviewCatchUp: ->
      view = @
      @collection.fetch
        success: (collection)->
          view.render()

    childEvents:
      'update:admins': (childView, value) ->
        @updateAdminCount(value)

    ui:
      'employeesLink': '#js-employees'
      'pastEmployeesLink': '#js-past-employees'
      'AdminsLink': '#js-admins'
      'adminsCount': '#js-admins-count'

    events:
      'click .js-search': 'search'
      'change #filter-logic-operator': 'changeOperator'
      'click @ui.employeesLink': 'employeesClicked'
      'click @ui.pastEmployeesLink': 'pastEmployeesClicked'
      'click @ui.AdminsLink': 'adminsClicked'

    updateAdminCount: (value)->
      count = @model.get('admins_count') + value
      @model.set('admins_count', count)
      @ui.adminsCount.html(count)

    searchUrl: (section)->
      urls =
        'employees':  AlumNet.api_endpoint + "/companies/#{@model.id}/employees"
        'past_employees':  AlumNet.api_endpoint + "/companies/#{@model.id}/past_employees"
        'admins':  AlumNet.api_endpoint + "/companies/#{@model.id}/admins"
      urls[section]

    employeesClicked: (e)->
      e.preventDefault()
      @activeItem(@ui.employeesLink)
      @setCollection('employees')

    pastEmployeesClicked: (e)->
      e.preventDefault()
      @activeItem(@ui.pastEmployeesLink)
      @setCollection('past_employees')

    adminsClicked: (e)->
      e.preventDefault()
      @activeItem(@ui.AdminsLink)
      @setCollection('admins')

    setCollection: (section)->
      @section = section
      @collection.url = @searchUrl(section)
      @collection.fetch()

    activeItem: (element)->
      @deactiveItems()
      element.addClass('sortingMenu__item-active')

    deactiveItems: ->
      _.each [@ui.employeesLink, @ui.pastEmployeesLink, @ui.AdminsLink], (element)->
        element.removeClass('sortingMenu__item-active')

    search: (e)->
      e.preventDefault()
      searchTerm = $('#search_term').val()
      @collection.fetch
        data:
          q:
            m: 'or'
            first_name_cont_any: searchTerm.split(" ")
            last_name_cont_any: searchTerm.split(" ")
            user_email_cont_any: searchTerm

    clear: (e)->
      e.preventDefault()
      @collection.fetch()


  class Employees.Request extends Marionette.ItemView
    template: 'companies/employees/templates/_request'
    className: 'col-md-4 col-sm-6'

    initialize: (options)->
      @company = options.company

    ui:
      'acceptLink': '.js-accept-admin'
      'rejectLink': '.js-reject-admin'

    events:
      'click @ui.acceptLink': 'acceptClicked'
      'click @ui.rejectLink': 'rejectClicked'

    acceptClicked: (e)->
      e.preventDefault()
      view = @
      @model.save {},
        success: (model)->
          view.company.trigger('update:admins', 1)
          view.destroy()
        error: (model, response)->
          console.log response

    rejectClicked: (e)->
      e.preventDefault()
      view = @
      @model.destroy
        success: (model)->
          view.company.trigger('update:admins', 0)
          view.destroy()
        error: (model, response)->
          console.log response


  class Employees.RequestsList extends Marionette.CompositeView
    template: 'companies/employees/templates/requests_container'
    childView: Employees.Request
    childViewContainer: '#js-request-container'
    childViewOptions: ->
      company: @model

    initialize: ->
      @collection.fetch()


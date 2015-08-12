@AlumNet.module 'CompaniesApp.Employees', (Employees, @AlumNet, Backbone, Marionette, $, _) ->
  class Employees.Layout extends Marionette.LayoutView
    template: 'companies/employees/templates/layout'
    className: 'container'
    regions:
       admins: "#admins"
       employees: "#employees"

  class Employees.Employee extends AlumNet.Shared.Views.UserView
    template: 'companies/employees/templates/_employee'
    className: 'col-md-4 col-sm-6'

  class Employees.List extends Marionette.CompositeView
    template: 'companies/employees/templates/employees_container'
    childView: Employees.Employee
    childViewContainer: '.employees-container'

    initialize: ->
      @collection.fetch()

    onShow: ->
      @searcher = new AlumNet.AdvancedSearch.Searcher("searcher", [
        { attribute: "name", type: "string", values: "" },
      ])

    onChildviewCatchUp: ->
      view = @
      @collection.fetch
        success: (collection)->
          view.render()
    ui:
      'employeesLink': '#js-employees'
      'pastEmployeesLink': '#js-past-employees'
      'AdminsLink': '#js-admins'

    events:
      'click .add-new-filter': 'addNewFilter'
      'click .search': 'search'
      'click .clear': 'clear'
      'change #filter-logic-operator': 'changeOperator'
      'click @ui.employeesLink': 'employeesClicked'
      'click @ui.pastEmployeesLink': 'pastEmployeesClicked'
      'click @ui.AdminsLink': 'adminsClicked'

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

    changeOperator: (e)->
      e.preventDefault()
      if $(e.currentTarget).val() == "any"
        @searcher.activateOr = false
      else
        @searcher.activateOr = true

    activeItem: (element)->
      @deactiveItems()
      element.addClass('sortingMenu__item-active')

    deactiveItems: ->
      _.each [@ui.employeesLink, @ui.pastEmployeesLink, @ui.AdminsLink], (element)->
        element.removeClass('sortingMenu__item-active')

    addNewFilter: (e)->
      e.preventDefault()
      @searcher.addNewFilter()

    search: (e)->
      e.preventDefault()
      query = @searcher.getQuery()
      @collection.fetch
        data: { q: query }

    clear: (e)->
      e.preventDefault()
      @collection.fetch()

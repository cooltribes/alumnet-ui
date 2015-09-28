@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->

  class Entities.Company extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + "/companies"

    sizes: [
      { value: 1, text: "1 - 10" }
      { value: 2, text: "11 - 50" }
      { value: 3, text: "51 - 200" }
      { value: 4, text: "201 - 500" }
      { value: 5, text: "501 - 1.000" }
      { value: 6, text: "1.001 - 5.000" }
      { value: 7, text: "5.001 - 10.000" }
      { value: 8, text: "+10.001" }
    ]

    sizes_options: (select)->
      options = ""
      _.each @sizes, (element, list)->
        selected = if select == element.value then "selected" else ""
        options = options + "<option value='#{element.value}' #{selected}>#{element.text}</option>"
      options

    userIsAdmin: ->
      @get('is_admin')

    employees_count: ->
      @get('employees').length

    branches_count: ->
      @get('branches').length

    links_count: ->
      @get('links').length

    branchesCollection: ->
      collection = new AlumNet.Entities.BranchesCollection @get('branches')
      collection.url = AlumNet.api_endpoint + "/companies/#{@id}/branches"
      collection

    servicesCollection: ->
      collection = new AlumNet.Entities.ServicesCollection @get('products_services')
      collection.url = AlumNet.api_endpoint + "/companies/#{@id}/product_services"
      collection

    contactsCollection: ->
      collection = new AlumNet.Entities.ProfileContactsCollection @get('contacts')
      collection.url = AlumNet.api_endpoint + "/companies/#{@id}/contact_infos"
      collection

    linksCollection: ->
      collection = new AlumNet.Entities.LinksCollection @get('links')
      collection.url = AlumNet.api_endpoint + "/companies/#{@id}/links"
      collection

    getLocation: ->
      location = []
      location.push(@get('main_address')) unless @get('main_address') == ""
      location.push(@get('city').name) unless @get('city').name == ""
      location.push(@get('country').name) unless @get('country').name == ""
      location.join(", ")

    validation:
      name:
        required: true
      sector_id:
        required: true
        msg: "Sector is required"
      size:
        required: true

  class Entities.CompaniesCollection extends Backbone.Collection
    model: Entities.Company
    rows: 9
    page: 1
    url: ->
      AlumNet.api_endpoint + "/companies"






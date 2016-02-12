@AlumNet.module 'CompaniesApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.Controller
    activeTab: "discoverCompanies"
    showMainCompanies: (optionMenu)->
      @activeTab = optionMenu
      @layoutCompanies = new Main.CompaniesView
        option: @activeTab
      AlumNet.mainRegion.show(@layoutCompanies)
      @showMenuUrl()

      self = @
      @layoutCompanies.on "navigate:menu:companies", (valueClick)->
        self.activeTab = valueClick
        self.showMenuUrl()

    showDiscoverCompanies: ()->
      controller = @
      controller.querySearch = {}
      companies = new AlumNet.Entities.CompaniesCollection
      companies.page = 1
      companies.url = AlumNet.api_endpoint + "/companies"
      @querySearch = { q: { company_admins_user_id_eq: AlumNet.current_user.id, status_eq: 1 } }
      companies.fetch
        reset: true
        data:
          q:
            company_admins_user_id_eq: AlumNet.current_user.id
            status_eq: 1
          page: companies.page
          per_page: companies.rows

      view = new AlumNet.CompaniesApp.Discover.List
        collection: companies

      @layoutCompanies.companies_region.show(view)


    showMenuUrl: ()->
      self = @
      switch @activeTab
        when "discoverCompanies"
          self.showDiscoverCompanies()
  
     
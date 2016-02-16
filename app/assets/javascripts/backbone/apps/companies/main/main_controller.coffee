@AlumNet.module 'CompaniesApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.Controller
    activeTab: "discoverCompanies"
    companiesType: "cards"

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

      @layoutCompanies.on "changeGrid", (typeCompanies)->
        self.companiesType = typeCompanies
        if self.activeTab == "myCompanies"
          self.showMyCompanies(self.companiesType)
        else if self.activeTab == "discoverCompanies"
          self.showDiscoverCompanies(self.companiesType)

    showDiscoverCompanies: (typeCompanies)->
      AlumNet.navigate("companies/discover")
      companies = new AlumNet.Entities.CompaniesCollection
      companies.page = 1
      companies.url = AlumNet.api_endpoint + "/companies"
      companies.fetch
        data: { page: companies.page, per_page: companies.rows }
        reset: true

      view = new AlumNet.CompaniesApp.Discover.List
        collection: companies
        type: typeCompanies

      @layoutCompanies.companies_region.show(view)
      
      controller = @
      controller.querySearch = {}
      view.on "companies:reload", ->
        that = @
        querySearch = controller.querySearch
        newCollection = new AlumNet.Entities.CompaniesCollection
        newCollection.url = AlumNet.api_endpoint + '/companies'
        query = _.extend(querySearch, { page: ++@collection.page, per_page: @collection.rows })
        newCollection.fetch
          data: query
          success: (collection)->
            that.collection.add(collection.models)
            if collection.length < collection.rows
              that.endPagination()

      view.on "add:child", (viewInstance)->
        container = $('#companies-container')
        container.imagesLoaded ->
          container.masonry
            itemSelector: '.col-md-4'
        container.append( $(viewInstance.el) ).masonry 'reloadItems'
      view

    showMyCompanies: (typeCompanies)->
      AlumNet.navigate("my-companies")
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
        type: typeCompanies

      view.on "companies:reload", ->
        that = @
        querySearch = controller.querySearch
        newCollection = new AlumNet.Entities.CompaniesCollection
        newCollection.url = AlumNet.api_endpoint + '/companies'
        query = _.extend(querySearch, { page: ++@collection.page, per_page: @collection.rows })
        newCollection.fetch
          data: query
          success: (collection)->
            that.collection.add(collection.models)
            if collection.length < collection.rows
              that.endPagination()

      view.on "add:child", (viewInstance)->
        container = $('#companies-container')
        container.imagesLoaded ->
          container.masonry
            itemSelector: '.col-md-4'
        container.append( $(viewInstance.el) ).masonry 'reloadItems'
      view

      @layoutCompanies.companies_region.show(view)

    showMenuUrl: ()->
      self = @
      switch @activeTab
        when "discoverCompanies"
          self.showDiscoverCompanies("cards")
        when "myCompanies"
          self.showMyCompanies("cards")
  
   

  
   
@AlumNet.module 'CompaniesApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.Controller
    activeTab: "discoverCompanies"
    companiesType: "cards"
    companiesCollection: null
    myCompaniesCollection: null
    manageCollection: null

    showMainLayout: (optionMenu)->
      @activeTab = optionMenu
      @layoutCompanies = new Main.CompaniesView
        option: @activeTab
      AlumNet.mainRegion.show(@layoutCompanies)
      AlumNet.footerRegion.empty()

      @showRegionMenu()

      self = @
      @layoutCompanies.on "navigate:menu:left", (valueClick)->
        self.activeTab = valueClick
        self.showRegionMenu()

      @layoutCompanies.on "navigate:menu:right", (valueClick)->
        switch valueClick
          when "suggestions"
            self.showSuggestions(self.activeTab)
          when "filters"
            self.showFilters()

      @layoutCompanies.on "changeGrid", (typeCompanies)->
        self.companiesType = typeCompanies
        if self.activeTab == "myCompanies"
          self.showMyCompanies(self.companiesType)
        else if self.activeTab == "discoverCompanies"
          self.showDiscoverCompanies(self.companiesType)
        else
          self.showManageCompanies(self.companiesType)

      @layoutCompanies.on 'discover:search', (querySearch, collection)->
        collection.search(querySearch)
        container = $('#companies-container')
        container.masonry 'layout'

      @layoutCompanies.on 'search', (querySearch)->
        self.querySearch = querySearch
        if self.activeTab == "discoverCompanies"
          collection.search(querySearch)
          container = $('#companies-container')
          container.masonry 'layout'
        else if self.activeTab == "myCompanies"
          self.myCompaniesCollection.fetch
            data: querySearch
            success: (collection)->
            container = $('#companies-container')
            container.masonry 'layout'
        else
          self.manageCollection.fetch
            data: querySearch
            url: AlumNet.api_endpoint + "/companies/managed"

    showDiscoverCompanies: (typeCompanies)->
      AlumNet.navigate("companies/discover")
      companies = AlumNet.request("results:companies")
      @results = companies

      companiesView = new AlumNet.CompaniesApp.Discover.CompaniesView
        collection: companies
        type: typeCompanies
        parentView: @layoutCompanies

      @layoutCompanies.companies_region.show(companiesView)

      self = @
      companiesView.on "add:child", (viewInstance)->
        self.applyMasonry(viewInstance)

    showMyCompanies: (typeCompanies)->
      AlumNet.navigate("my-companies")
      companies = new AlumNet.Entities.CompaniesCollection
      companies.url = AlumNet.api_endpoint + "/companies"
      query = { per_page: 8, q: { creator_id_eq: AlumNet.current_user.id } }

      companiesView = new AlumNet.CompaniesApp.Discover.CompaniesView
        collection: companies
        type: typeCompanies
        parentView: @layoutCompanies
        query: query

      @layoutCompanies.companies_region.show(companiesView)

      self = @
      companiesView.on "add:child", (viewInstance)->
        self.applyMasonry(viewInstance)

    showManageCompanies:(typeCompanies) ->
      AlumNet.navigate("companies/manage")
      companies = new AlumNet.Entities.CompaniesCollection
      companies.url = AlumNet.api_endpoint + "/companies/managed"
      query = { per_page: 8 }

      companiesView = new AlumNet.CompaniesApp.Discover.CompaniesView
        collection: companies
        type: typeCompanies
        parentView: @layoutCompanies
        query: query

      @layoutCompanies.companies_region.show(companiesView)

      self = @
      companiesView.on "add:child", (viewInstance)->
        self.applyMasonry(viewInstance)

    applyMasonry: (view)->
      if view.type == "cards"
        container = $('#companies-container')
        container.imagesLoaded ->
          container.masonry
            itemSelector: '.col-md-6'
        container.append( $(view.el) ).masonry().masonry 'reloadItems'

    showFilters: ->
      filters = new AlumNet.Shared.Views.Filters.Companies.General
        results_collection: @results
      @layoutCompanies.filters_region.show(filters)

    showSuggestions: (optionMenuLeft)->
      collection = new AlumNet.Entities.SuggestedCompaniesCollection

      suggestionsView = new AlumNet.CompaniesApp.Suggestions.CompaniesView 
        collection: collection
        optionMenuLeft: optionMenuLeft
        
      @layoutCompanies.filters_region.show(suggestionsView)

    showRegionMenu: ->
      self = @
      switch @activeTab
        when "discoverCompanies"
          self.showDiscoverCompanies("cards")
        when "myCompanies"
          self.showMyCompanies("cards")
        when "manageCompanies"
          self.showManageCompanies("cards")
      @showSuggestions(@activeTab)

@AlumNet.module 'CompaniesApp.Main', (Main, @AlumNet, Backbone, Marionette, $, _) ->
  class Main.Controller
    activeTab: "discoverCompanies"
    companiesType: "cards"
    companiesCollection: null
    myCompaniesCollection: null
    manageCollection: null

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
        else
          self.showManageCompanies(self.companiesType)

      @layoutCompanies.on 'search', (querySearch)->
        self.querySearch = querySearch
        if self.activeTab == "discoverCompanies"
          self.companiesCollection.fetch
            data: querySearch
            success: (collection)->
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
      @companiesCollection = new AlumNet.Entities.CompaniesCollection
      @companiesCollection.page = 1
      @companiesCollection.url = AlumNet.api_endpoint + "/companies"
      @companiesCollection.fetch
        data: { page: @companiesCollection.page, per_page: @companiesCollection.rows }
        reset: true

      view = new AlumNet.CompaniesApp.Discover.List
        collection: @companiesCollection
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
            itemSelector: '.col-md-6'
        container.append( $(viewInstance.el) ).masonry 'reloadItems'
      view

    showMyCompanies: (typeCompanies)->
      AlumNet.navigate("my-companies")
      controller = @
      controller.querySearch = {}
      @myCompaniesCollection = new AlumNet.Entities.CompaniesCollection
      @myCompaniesCollection.page = 1
      @myCompaniesCollection.url = AlumNet.api_endpoint + "/companies"
      @querySearch = { q: { company_admins_user_id_eq: AlumNet.current_user.id, status_eq: 1 } }
      @myCompaniesCollection.fetch
        reset: true
        data:
          q:
            company_admins_user_id_eq: AlumNet.current_user.id
            status_eq: 1
          page: @myCompaniesCollection.page
          per_page: @myCompaniesCollection.rows

      view = new AlumNet.CompaniesApp.Discover.List
        collection: @myCompaniesCollection
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
            itemSelector: '.col-md-6'
        container.append( $(viewInstance.el) ).masonry 'reloadItems'
      view

      @layoutCompanies.companies_region.show(view)


    showManageCompanies:(typeCompanies) ->
      AlumNet.navigate("companies/manage")
      controller = @
      controller.querySearch = {}
      @manageCollection = new AlumNet.Entities.CompaniesCollection
      @manageCollection.page = 1
      @manageCollection.url = AlumNet.api_endpoint + "/companies/managed"
      @manageCollection.fetch()

      view = new AlumNet.CompaniesApp.Discover.List
        collection: @manageCollection
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
            itemSelector: '.col-md-6'
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
        when "manageCompanies"
          self.showManageCompanies("cards")
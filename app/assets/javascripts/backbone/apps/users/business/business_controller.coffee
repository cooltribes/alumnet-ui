@AlumNet.module 'UsersApp.Business', (Business, @AlumNet, Backbone, Marionette, $, _) ->
  class Business.Controller
    showBusiness: (id)->
      #AlumNet.execute('render:users:submenu')

      user = AlumNet.request("user:find", id)

      user.on 'find:success', (response, options)=>

        @layout = AlumNet.request "user:layout", user, 5
        header = AlumNet.request "user:header", user

        AlumNet.mainRegion.show(@layout)
        @layout.header.show(header)

        self = @

        @businessCollection = new AlumNet.Entities.BusinessCollection {},
          user_id: id

        @keywordsList = new AlumNet.Entities.KeywordsCollection
        @keywordsList.fetch
          wait: true

        @businessCollection.fetch
          success: (collection, res, options)->
            self.showMainView()


        @userCanEdit = user.isCurrentUser()

    showMainView: ->
      #if there are any existing business section show it. else show empty view
      if @businessCollection.length
        @showSection(@businessCollection.at(0))
      else
        @showEmpty()


    showEmpty: ->
      view = new Business.EmptyView
        userCanEdit: @userCanEdit

      controller = @
      view.on "showCreateForm", (view)->
        controller.showCreateForm()

      @layout.body.show view


    showCreateForm: ()->
      controller = @
      url = AlumNet.api_endpoint + "/features/validate"
      current_user = AlumNet.current_user
      user_can_access = false
      Backbone.ajax
        url: url
        type: "GET"
        data: { key_name: 'create_business_exchange_tab' }
        success: (data) =>
          if data.validation
            if current_user.get('is_premium')
              controller.showForm()
            else
              AlumNet.navigate("premium?members_only", {trigger: true})
          else
            controller.showForm()
        error: (data) =>
          $.growl.error({ message: 'Unknow error, please try again' })

    showForm: ()->
      view = new Business.CreateForm
        model: new AlumNet.Entities.Business
        keywords: @keywordsList

      controller = @
      view.on "cancel", (view)->
        controller.showMainView()

      view.on "submit", (options)->
        # console.log controller.businessCollection.url()
        options.model.url = controller.businessCollection.url()
        controller.businessCollection.create options.model,
          wait: true
          # contentType: false
          # processData: false
          # data: options.data
          success: (model)->
            # model.updateLinksURL()
            controller.showMainView()

      @layout.body.show view


    linksView: (model)->
      view = new Business.LinksView
        collection: model.linksCollection
        userCanEdit: @userCanEdit


    showSection: (model)->
      view = new Business.SectionView
        model: model
        userCanEdit: @userCanEdit
        keywords: @keywordsList

      controller = @
      view.on "showCreateForm", (view)->
        controller.showCreateForm()

      @layout.body.show view
      view.links_region.show @linksView(model)


@AlumNet.module 'UsersApp.Business', (Business, @AlumNet, Backbone, Marionette, $, _) ->
  class Business.Controller
    showBusiness: (id)->
      AlumNet.execute('render:users:submenu')
      
      user = AlumNet.request("user:find", id)
      
      user.on 'find:success', (response, options)=>

        @layout = AlumNet.request "user:layout", user, 5
        header = AlumNet.request "user:header", user

        AlumNet.mainRegion.show(@layout)
        @layout.header.show(header)
        
        self = @

        @businessCollection = new AlumNet.Entities.BusinessCollection
          user_id: id

        @businessCollection.fetch
          success: (collection, res, options)->
            self.showMainView()
              


        @userCanEdit = user.isCurrentUser()

    showMainView: ->
      # @showCreateForm()
      # return true
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

      view = new Business.CreateForm
        model: new AlumNet.Entities.Business

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
          success: ()->
            controller.showMainView()

      @layout.body.show view


      
    showSection: (model)->
      view = new Business.SectionView
        model: model
        userCanEdit: @userCanEdit

      controller = @  
      view.on "showCreateForm", (view)->
        controller.showCreateForm()

      @layout.body.show view


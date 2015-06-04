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
      if @businessCollection.length
        self.showSection(@businessCollection.at(0))
      else
        self.showEmpty()
        

    showEmpty: ->
      view = new Business.EmptyView
        userCanEdit: @userCanEdit

      @layout.body.show view


    showCreateForm: ()->
      view = new Business.CreateForm
      
      controller = @  
      view.on "cancel", (view)->
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


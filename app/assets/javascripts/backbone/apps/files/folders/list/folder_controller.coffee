@AlumNet.module 'FilesApp.Folders', (Folders, @AlumNet, Backbone, Marionette, $, _) ->
  class Folders.Controller
    listFolders: (layout, folderable)->      
      @userCanEdit = false # initialy nobody can create or edit
      folderable_route = "" #groups/ or events/

      if folderable instanceof AlumNet.Entities.Group #If is group
        folderable_route = "groups"
        @userCanEdit = folderable.get("admin") #user.isCurrentUser() # || AlumNet.current_user.isAlumnetAdmin()
      else if folderable instanceof AlumNet.Entities.Event #If is group
        folderable_route = "events"
        @userCanEdit = folderable.get("admin") #user.isCurrentUser() # || AlumNet.current_user.isAlumnetAdmin()
      else
        return  

      @folders_collection = new AlumNet.Entities.FoldersCollection
      @folders_collection.url = AlumNet.api_endpoint + "/#{folderable_route}/" + folderable.id + "/folders"
            
      @layout = layout
      
      @showAllFolders()
        

    showAllFolders: ()->
      @albumsView = new Folders.FoldersView
        collection: @folders_collection
        userCanEdit: @userCanEdit
      @folders_collection.fetch()
      
      self = @  

      @albumsView.on "childview:show:detail", (childview)->          
        self.showFiles childview.model
        

      @albumsView.on "new:folder", ()->
        self.showCreateForm()
      
      @layout.show @albumsView


    showCreateForm: ()->
      view = new Folders.FolderModal
        model: new AlumNet.Entities.Folder            
      
      controller = @
      view.on "submit", ()->         
        controller.folders_collection.create @model.attributes,
          wait: true          

      @albumsView.ui.modals.html view.render().el


    showFiles: (folder)->
      files_view = new Folders.FilesView
        model: folder
        collection: folder.files_collection
        userCanEdit: @userCanEdit
      self = @
      
      files_view.on "return", ()->        
        self.showAllFolders()

      files_view.on "childview:move:file", ()->        
        self.showMoveFileModal(@)  

      @layout.show files_view


    showMoveFileModal: (files_view)->
      # folders_list = @folders_collection.filter (folder)->
      #   folder.id != files_view.model.id
      view = new Folders.MoveFileModal
        collection: @folders_collection
        folder_id: files_view.model.id
        # collection: folders_list
      
      # controller = @
      # view.on "submit", ()->         
      #   controller.folders_collection.create @model.attributes,
      #     wait: true          

      files_view.ui.modals.html view.render().el  
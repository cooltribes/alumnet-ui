@AlumNet.module 'FilesApp.Folders', (Folders, @AlumNet, Backbone, Marionette, $, _) ->
  class Folders.Controller
    listFolders: (layout, folderable)->      
      @userCanEdit = folderable.get "user_can_upload_file"
      folderable_route = "" #groups/ or events/

      if folderable instanceof AlumNet.Entities.Group #If is group
        folderable_route = "groups"
      else if folderable instanceof AlumNet.Entities.Event #If is group
        folderable_route = "events"
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

      files_view.on "childview:move:file", (childview)->        
        self.showMoveFileModal(@, childview.model)  

      @layout.show files_view


    showMoveFileModal: (files_view, file)->
      
      view = new Folders.MoveFileModal
        collection: @folders_collection
        folder_id: files_view.model.id
      
      controller = @
      view.on "submit", (new_folder_id)->                 
        
        old_folder_id = file.get "folder_id"        

        file.save {"new_folder_id": new_folder_id},
          success: (model, response)->            
            if model.get("folder_id") != old_folder_id
              
              #remove file from one collection and add it to new one
              current_folder = controller.folders_collection.get files_view.model.id
              new_folder = controller.folders_collection.get model.get("folder_id")

              model = current_folder.files_collection.remove model.id
              new_folder.files_collection.add model
            
      files_view.ui.modals.html view.render().el  
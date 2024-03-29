@AlumNet.module 'FilesApp.Folders', (Folders, @AlumNet, Backbone, Marionette, $, _) ->
  class Folders.Controller
    listFolders: (layout, folderable)->
      @userCanEdit = folderable.get "user_can_upload_files"
      folderable_route = "" #groups/ or events/

      if folderable instanceof AlumNet.Entities.Group #If it's a group
        folderable_route = "groups"
      else if folderable instanceof AlumNet.Entities.Event #If it's an event
        folderable_route = "events"
      else
        return

      @folders_collection = new AlumNet.Entities.FoldersCollection
      @folders_collection.url = AlumNet.api_endpoint + "/#{folderable_route}/" + folderable.id + "/folders"

      @layout = layout

      @_showAllFolders()


    _showAllFolders: ()->
      self = @

      @albumsView = new Folders.FoldersView
        collection: @folders_collection
        userCanEdit: @userCanEdit

      @folders_collection.fetch
        success: ()->
          self.albumsView.render()

      #each folder events
      @albumsView.on "childview:show:detail", (childview)->
        self.showFiles childview.model

      @albumsView.on "childview:show:edit", (childview)->
        self.showEditFolder childview.model

      #all folders events
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


    showEditFolder: (model)->
      view = new Folders.FolderModal
        model: model

      controller = @
      view.on "submit", ()->
        @model.save {},
          success: (model)->
            model.trigger "save:name"
            $.growl.notice
              # title: "Notice"
              message: "The folder has been successfully saved"

      @albumsView.ui.modals.html view.render().el


    showFiles: (folder)->
      files_view = new Folders.FilesView
        model: folder
        collection: folder.files_collection
        userCanEdit: @userCanEdit
      self = @

      files_view.on "return", ()->
        self._showAllFolders()

      files_view.on "childview:move:file", (childview)->
        self.showMoveFileModal(@, childview.model)

      files_view.on "childview:show:edit", (childview)->
        self.showRenameFileModal(@, childview.model)

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


    showRenameFileModal: (files_view, file)->

      view = new Folders.FileModal
        model: file

      controller = @
      view.on "submit", ()->
        @model.save {},
          success: (model)->
            model.trigger "save:name"
            $.growl.notice
              # title: "Notice"
              message: "The file has been successfully renamed"

      files_view.ui.modals.html view.render().el
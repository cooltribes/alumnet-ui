@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Folder extends Backbone.Model
   initialize: ()->      
      @files_collection = new Entities.FilesCollection @get("files")#(@get("files") ? [])     
      @updateFilesURL()
      @on "change:id", @updateFilesURL
      

    validation:
      name:
        required: true
    defaults:
      name: "New folder"    

    updateFilesURL: ()->
      @files_collection.url = AlumNet.api_endpoint + "/folders/#{@id}/attachments"  

  class Entities.FoldersCollection extends Backbone.Collection
    model: Entities.Folder

  
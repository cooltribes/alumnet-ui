@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.File extends Backbone.Model
    validation:
      name:
        required: true
    
  class Entities.FilesCollection extends Backbone.Collection
    model: Entities.File

    checkDuplicated: (file_names)->
      true

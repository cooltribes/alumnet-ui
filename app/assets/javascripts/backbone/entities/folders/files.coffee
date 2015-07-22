@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.File extends Backbone.Model
    validation:
      name:
        required: true
    
  class Entities.FilesCollection extends Backbone.Collection
    model: Entities.File

    checkDuplicated: (files)->
      # new_files = _.pluck files, "name"

      # # existing_files = _.pluck @, "name"

      # console.log files
      # console.log @

      # console.log existing_names
      # console.log file_names

      true

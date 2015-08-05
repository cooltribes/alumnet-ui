@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Branch extends Backbone.Model
    validation:
      address:
        required: true

  class Entities.BranchesCollection extends Backbone.Collection
    model: Entities.Branch




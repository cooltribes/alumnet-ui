@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Branch extends Backbone.Model
    validation:
      address:
        required: true

    getLocation:(address) ->
      location = []
      if address
        location.push(@get('address')) unless @get('address') == ""
      location.push(@get('city').name) unless @get('city').name == ""
      location.push(@get('country').name) unless @get('country').name == ""
      location.join(", ")

  class Entities.BranchesCollection extends Backbone.Collection
    model: Entities.Branch




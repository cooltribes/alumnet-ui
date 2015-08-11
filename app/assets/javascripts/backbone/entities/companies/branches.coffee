@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Branch extends Backbone.Model
    validation:
      address:
        required: true

    getLocation:(address) ->
      location = []
      if address
        location.push(@get('address')) unless @get('address') == ""
      location.push(@get('city').text) unless @get('city').text == ""
      location.push(@get('country').text) unless @get('country').text == ""
      location.join(", ")

  class Entities.BranchesCollection extends Backbone.Collection
    model: Entities.Branch




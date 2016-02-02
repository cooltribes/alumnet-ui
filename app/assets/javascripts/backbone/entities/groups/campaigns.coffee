@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Campaign extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/groups/' + @get('group_id') + '/campaigns/'

  class Entities.CampaignCollection extends Backbone.Collection
    model: Entities.Campaign
    rows: 15
    page: 1

    url: ->
      AlumNet.api_endpoint + '/admin/campaigns'
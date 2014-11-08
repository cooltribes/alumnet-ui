@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Member extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/users'

  class Entities.MembersCollection extends Backbone.Collection
    model: Entities.Member

  API =
    getMembersGroup: (group_id, querySearch)->
      members = new Entities.MembersCollection
      members.url = AlumNet.api_endpoint + '/groups/' + group_id + '/members'
      members.fetch
        data: querySearch
      members

  AlumNet.reqres.setHandler 'members:entities', (group_id, querySearch)->
    API.getMembersGroup(group_id, querySearch)
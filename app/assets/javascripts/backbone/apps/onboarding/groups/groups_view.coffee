@AlumNet.module 'OnboardingApp.Suggestions', (Suggestions, @AlumNet, Backbone, Marionette, $, _) ->
  class Suggestions.Group extends Marionette.ItemView
    template: 'onboarding/groups/templates/_group'

    ui:
      'joinButton': '.js-join'

    events:
      'click @ui.joinButton': 'join'

    join: ->
      view = @
      group = @model
      attrs = { group_id: group.get('id'), user_id: AlumNet.current_user.id }
      request = AlumNet.request('membership:create', attrs)
      request.on 'save:success', (response, options)->
        view.$('.js-link').html('</span>Resquest Send</span>')

      request.on 'save:error', (response, options)->
        console.log response.responseJSON

  class Suggestions.Groups extends Marionette.CompositeView
    template: 'onboarding/groups/templates/groups'
    childView: Suggestions.Group
    childViewContainer: '.groups-container'

    initialize: ->
      @collection = new AlumNet.Entities.SuggestedGroupsCollection
      @collection.fetch()

    templateHelpers: ->
      user_first_name: AlumNet.current_user.profile.get('first_name')


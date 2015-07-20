@AlumNet.module 'MeetupExchangeApp.Invitations', (Invitations, @AlumNet, Backbone, Marionette, $, _) ->
  class Invitations.TaskInvitation extends Marionette.ItemView
    template: 'meetup_exchange/invitations/templates/invitation'

    ui:
      'linkAccept': '.js-invitation-accept'
      'linkDecline': '.js-invitation-decline'

    events:
      'click @ui.linkAccept': 'acceptClicked'
      'click @ui.linkDecline': 'declineClicked'

    templateHelpers: ->
      model = @model
      location: ->
        location = []
        task = model.get('task')
        if task
          location.push task.country.text unless task.country.text == ""
          location.push task.city.text unless task.city.text == ""
          location.join(', ')

    acceptClicked: (e)->
      e.preventDefault()
      view = @
      @model.save {},
        success: ->
          view.destroy()

    declineClicked: (e)->
      e.preventDefault()
      @model.destroy()

  class Invitations.TaskInvitations extends Marionette.CompositeView
    template: 'meetup_exchange/invitations/templates/invitations'
    childView: Invitations.TaskInvitation
    childViewContainer: '.invitations-container'
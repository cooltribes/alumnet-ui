@AlumNet.module 'MeetupExchangeApp.Show', (Show, @AlumNet, Backbone, Marionette, $, _) ->
  class Show.Task extends AlumNet.MeetupExchangeApp.Shared.Task
    className: 'container'
    template: 'meetup_exchange/_shared/templates/detail_task'


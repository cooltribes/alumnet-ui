@AlumNet.module 'MeetupExchangeApp.Discover', (Discover, @AlumNet, Backbone, Marionette, $, _) ->
  class Discover.Controller
    discover: ->
      tasks = new AlumNet.Entities.MeetupExchangeCollection
      tasks.fetch()
      discoverView = new Discover.List
        collection: tasks

      AlumNet.mainRegion.show(discoverView)

      # Check cookies for first visit
      if not Cookies.get('meetup_exchange_visit')
        modal = new Discover.ModalMeetups
        $('#container-modal-meetup').html(modal.render().el)
        Cookies.set('meetup_exchange_visit', 'true')

      #AlumNet.execute('render:meetup_exchange:submenu', undefined, 3)

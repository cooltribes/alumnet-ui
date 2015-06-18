@AlumNet.module 'ProgramsApp.JobExchange', (JobExchange, @AlumNet, Backbone, Marionette, $, _) ->
  class JobExchange.Controller

    automatchesJobExchange:->
      tasks = new AlumNet.Entities.JobExchangeCollection
      tasks.fetch
        url: AlumNet.api_endpoint + '/job_exchanges/automatches'
      automatchView = new JobExchange.AutomatchesJobs
        collection: tasks

      AlumNet.mainRegion.show(automatchView)
      AlumNet.execute('render:programs:submenu', undefined, 1)

    invitationsJobExchange: ->
      invitations = new AlumNet.Entities.TaskInvitationCollection
      invitations.fetch()
      invitationsView = new JobExchange.TaskInvitations
        collection: invitations

      AlumNet.mainRegion.show(invitationsView)
      AlumNet.execute('render:programs:submenu', undefined, 4)

    discoverJobExchange:->
      tasks = new AlumNet.Entities.JobExchangeCollection
      tasks.fetch()
      discoverView = new JobExchange.DiscoverJobs
        collection: tasks

      AlumNet.mainRegion.show(discoverView)
      AlumNet.execute('render:programs:submenu', undefined, 2)

    showJobExchange: (id)->
      task = new AlumNet.Entities.JobExchange { id: id }
      task.fetch
        success: ->
          detailView = new JobExchange.Task
            model: task
            mode: 'detail'

          AlumNet.mainRegion.show(detailView)
          AlumNet.execute('render:programs:submenu')

        error: (model, response, options)->
          AlumNet.trigger('show:error', response.status)

    appliedJobExchange: ->
      tasks = new AlumNet.Entities.JobExchangeCollection
      tasks.fetch
        url: AlumNet.api_endpoint + '/job_exchanges/applied'
      appliedJobsView = new JobExchange.AppliedJobs
        collection: tasks

      AlumNet.mainRegion.show(appliedJobsView)
      AlumNet.execute('render:programs:submenu', undefined, 3)

    myJobExchange: ->
      tasks = new AlumNet.Entities.JobExchangeCollection
      tasks.fetch
        url: AlumNet.api_endpoint + '/job_exchanges/my'
      myJobsView = new JobExchange.MyJobs
        collection: tasks

      AlumNet.mainRegion.show(myJobsView)
      AlumNet.execute('render:programs:submenu', undefined, 0)

    createJobExchange: ->
      task = new AlumNet.Entities.JobExchange
      createForm = new JobExchange.Form
        model: task

      AlumNet.mainRegion.show(createForm)
      AlumNet.execute('render:programs:submenu')

    updateJobExchange: (id)->
      current_user = AlumNet.current_user
      task = new AlumNet.Entities.JobExchange { id: id }
      task.fetch
        success: ->
          if task.canEdit()
            createForm = new JobExchange.Form
              model: task
              user: current_user

            AlumNet.mainRegion.show(createForm)
            AlumNet.execute('render:programs:submenu')
          else
            AlumNet.trigger('show:error', 403)

        error: (model, response, options)->
          AlumNet.trigger('show:error', response.status)
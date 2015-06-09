@AlumNet.module 'ProgramsApp.JobExchange', (JobExchange, @AlumNet, Backbone, Marionette, $, _) ->
  class JobExchange.Controller

    showJobExchange: (id)->
      current_user = AlumNet.current_user
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

    myJobExchange: ->
      current_user = AlumNet.current_user
      tasks = new AlumNet.Entities.JobExchangeCollection
      tasks.fetch()
      myJobsView = new JobExchange.MyJobs
        collection: tasks

      AlumNet.mainRegion.show(myJobsView)
      AlumNet.execute('render:programs:submenu', undefined, 0)

    createJobExchange: ->
      current_user = AlumNet.current_user
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
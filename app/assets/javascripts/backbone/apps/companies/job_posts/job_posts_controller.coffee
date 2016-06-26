@AlumNet.module 'CompaniesApp.JobPosts', (JobPosts, @AlumNet, Backbone, Marionette, $, _) ->
  class JobPosts.Controller
    job_posts: (id)->
      company = new AlumNet.Entities.Company { id: id }
      company.fetch
        success: ->
          layout = AlumNet.request('company:layout', company, 2)
          header = AlumNet.request('company:header', company)

          tasks = new AlumNet.Entities.JobExchangeCollection
          tasks.url = AlumNet.api_endpoint + '/job_exchanges'

          tasksView = new JobPosts.TasksView
            model: company
            collection: tasks

          AlumNet.mainRegion.show(layout)
          AlumNet.execute 'show:footer'
          layout.header.show(header)
          layout.body.show(tasksView)

          #AlumNet.execute('render:companies:submenu',undefined, 1)

        error: (model, response, options)->
          AlumNet.trigger('show:error', response.status)


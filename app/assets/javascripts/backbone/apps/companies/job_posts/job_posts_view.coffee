@AlumNet.module 'CompaniesApp.JobPosts', (JobPosts, @AlumNet, Backbone, Marionette, $, _) ->

  class JobPosts.Task extends AlumNet.JobExchangeApp.Shared.Task
    template: 'job_exchange/_shared/templates/discover_task'
    className: 'col-md-4'


  class JobPosts.TasksView extends Marionette.CompositeView
    template: 'companies/job_posts/templates/tasks_container'
    childView: JobPosts.Task
    childViewContainer: '.tasks-container'
    className: 'container-fluid'    

    initialize: ->
      @collection.fetch
        data: { q: { company_id_eq: @model.id } }

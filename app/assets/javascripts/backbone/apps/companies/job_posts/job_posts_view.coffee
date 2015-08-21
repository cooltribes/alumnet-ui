@AlumNet.module 'CompaniesApp.JobPosts', (JobPosts, @AlumNet, Backbone, Marionette, $, _) ->

  class JobPosts.Task extends Marionette.ItemView
    template: 'companies/job_posts/templates/_task'


  class JobPosts.TasksView extends Marionette.CompositeView
    template: 'companies/job_posts/templates/tasks_container'
    childView: JobPosts.Task
    childViewContainer: '.tasks-container'

    initialize: ->
      @collection.fetch
        data: { q: { company_id_eq: @model.id } }

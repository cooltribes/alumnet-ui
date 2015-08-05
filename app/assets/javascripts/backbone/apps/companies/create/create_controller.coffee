@AlumNet.module 'CompaniesApp.Create', (Create, @AlumNet, Backbone, Marionette, $, _) ->
  class Create.Controller
    create: ->
      company = new AlumNet.Entities.Company
      createForm = new Create.Form
        model: company
      AlumNet.mainRegion.show(createForm)

    # update: (id)->
    #   current_user = AlumNet.current_user
    #   task = new AlumNet.Entities.JobExchange { id: id }
    #   task.fetch
    #     success: ->
    #       if task.canEdit()
    #         createForm = new Create.Form
    #           model: task
    #           user: current_user

    #         AlumNet.mainRegion.show(createForm)
    #         AlumNet.execute('render:job_exchange:submenu')
    #       else
    #         AlumNet.trigger('show:error', 403)

    #     error: (model, response, options)->
    #       AlumNet.trigger('show:error', response.status)
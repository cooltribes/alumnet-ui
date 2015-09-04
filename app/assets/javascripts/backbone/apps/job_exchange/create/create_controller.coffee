@AlumNet.module 'JobExchangeApp.Create', (Create, @AlumNet, Backbone, Marionette, $, _) ->
  class Create.Controller
    create: ->
      controller = @
      #feature = new AlumNet.Entities.Feature { key_name: 'job_post' }
      url = AlumNet.api_endpoint + "/features/validate"
      current_user = AlumNet.current_user
      Backbone.ajax
        url: url
        type: "GET"
        data: { key_name: 'job_post' }
        success: (data) =>
          if data.validation
            if current_user.get('is_premium')
              if current_user.get('remaining_job_posts') > 0
                controller.showCreateForm()
              else
                controller.showBuyForm()
                #AlumNet.navigate("job-exchange/buy", {trigger: true})
            else
              AlumNet.navigate("premium?members_only", {trigger: true})
          else
            if current_user.get('remaining_job_posts') > 0
              controller.showCreateForm()
            else
              controller.showBuyForm()
              #AlumNet.navigate("job-exchange/buy", {trigger: true})
        error: (data) =>
          $.growl.error({ message: 'Unknow error, please try again' })

    showCreateForm: ->
      task = new AlumNet.Entities.JobExchange
      createForm = new Create.Form
        model: task
      AlumNet.mainRegion.show(createForm)
      AlumNet.execute('render:job_exchange:submenu')

    showBuyForm: ->
      #task = new AlumNet.Entities.JobExchange
      buyForm = new Create.JobPostsView
        #model: task
      AlumNet.mainRegion.show(buyForm)
      AlumNet.execute('render:job_exchange:submenu')

    update: (id)->
      current_user = AlumNet.current_user
      task = new AlumNet.Entities.JobExchange { id: id }
      task.fetch
        success: ->
          if task.canEdit()
            createForm = new Create.Form
              model: task
              user: current_user

            AlumNet.mainRegion.show(createForm)
            AlumNet.execute('render:job_exchange:submenu')
          else
            AlumNet.trigger('show:error', 403)

        error: (model, response, options)->
          AlumNet.trigger('show:error', response.status)
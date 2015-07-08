@AlumNet.module 'JobExchangeApp.Create', (Create, @AlumNet, Backbone, Marionette, $, _) ->
  class Create.Controller
    create: ->
      task = new AlumNet.Entities.JobExchange
      #feature = new AlumNet.Entities.Feature { key_name: 'job_post' }
      url = AlumNet.api_endpoint + "/features/validate"
      current_user = AlumNet.current_user
      Backbone.ajax
        url: url
        type: "GET"
        data: { key_name: 'job_post' }
        success: (data) =>
          console.log data
          if data.validation
            if current_user.get('is_premium')
              createForm = new Create.Form
                model: task
              AlumNet.mainRegion.show(createForm)
              AlumNet.execute('render:job_exchange:submenu')
            else

          else
            createForm = new Create.Form
              model: task
            AlumNet.mainRegion.show(createForm)
            AlumNet.execute('render:job_exchange:submenu')
        error: (data) =>
          $.growl.error({ message: 'Unknow error, please try again' })
      #feature = AlumNet.request('feature:findByKeyName', 'job_post')
      
      ###feature.fetch
        success: ->
          console.log feature

        error: (model, response, options)->
          console.log 'error controller'
          AlumNet.trigger('show:error', response.status)###

      

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
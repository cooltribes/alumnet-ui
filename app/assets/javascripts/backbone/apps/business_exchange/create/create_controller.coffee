@AlumNet.module 'BusinessExchangeApp.Create', (Create, @AlumNet, Backbone, Marionette, $, _) ->
  class Create.Controller
    create: ->
      task = new AlumNet.Entities.BusinessExchange
      url = AlumNet.api_endpoint + "/features/validate"
      current_user = AlumNet.current_user
      Backbone.ajax
        url: url
        type: "GET"
        data: { key_name: 'get_help' }
        success: (data) =>
          if data.validation
            if current_user.get('is_premium')
              createForm = new Create.Form
                model: task

              AlumNet.mainRegion.show(createForm)
              AlumNet.execute('render:business_exchange:submenu')
            else
              AlumNet.navigate("premium?members_only", {trigger: true})
          else
            createForm = new Create.Form
              model: task

            AlumNet.mainRegion.show(createForm)
            AlumNet.execute('render:business_exchange:submenu')
        error: (data) =>
          console.log data
          $.growl.error({ message: 'Unknow error, please try again' })

      ###createForm = new Create.Form
        model: task

      AlumNet.mainRegion.show(createForm)
      AlumNet.execute('render:business_exchange:submenu')###

    update: (id)->
      current_user = AlumNet.current_user
      task = new AlumNet.Entities.BusinessExchange { id: id }
      task.fetch
        success: ->
          if task.canEdit()
            createForm = new Create.Form
              model: task
              user: current_user

            AlumNet.mainRegion.show(createForm)
            AlumNet.execute('render:business_exchange:submenu')
          else
            AlumNet.trigger('show:error', 403)

        error: (model, response, options)->
          AlumNet.trigger('show:error', response.status)
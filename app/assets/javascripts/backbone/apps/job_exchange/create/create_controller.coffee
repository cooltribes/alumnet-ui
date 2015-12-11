@AlumNet.module 'JobExchangeApp.Create', (Create, @AlumNet, Backbone, Marionette, $, _) ->
  class Create.Controller
    create: ->
      controller = @
      #feature = new AlumNet.Entities.Feature { key_name: 'job_post' }
      url = AlumNet.api_endpoint + "/features/validate"
      current_user = AlumNet.current_user
      controller.showCreateForm()
      # uncomment this block to validate premium user and available job_posts before create
      # Backbone.ajax
      #   url: url
      #   type: "GET"
      #   data: { key_name: 'job_post' }
      #   success: (data) =>
      #     if data.validation
      #       if current_user.get('is_premium')
      #         if current_user.get('remaining_job_posts') > 0
      #           controller.showCreateForm()
      #         else
      #           controller.showBuyForm()
      #       else
      #         AlumNet.navigate("premium?members_only", {trigger: true})
      #     else
      #       if current_user.get('remaining_job_posts') > 0
      #         controller.showCreateForm()
      #       else
      #         controller.showBuyForm()
      #   error: (data) =>
      #     $.growl.error({ message: 'Unknow error, please try again' })

    showCreateForm: ->
      task = new AlumNet.Entities.JobExchange
      createForm = new Create.Form
        model: task
      AlumNet.mainRegion.show(createForm)
      #AlumNet.execute('render:job_exchange:submenu')

    showBuyForm: ->
      job_posts = AlumNet.request('product:entities', {q: { feature_eq: 'job_post', status_eq: 1 }})
      job_posts.on 'fetch:success', (collection)->
        jobPostsView = new Create.JobPostsView
          current_user: AlumNet.current_user
          collection: collection
        AlumNet.mainRegion.show(jobPostsView)
        #AlumNet.execute('render:job_exchange:submenu')
      

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
            #AlumNet.execute('render:job_exchange:submenu')
          else
            AlumNet.trigger('show:error', 403)

        error: (model, response, options)->
          AlumNet.trigger('show:error', response.status)
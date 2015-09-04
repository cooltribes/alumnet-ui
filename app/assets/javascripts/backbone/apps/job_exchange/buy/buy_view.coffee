@AlumNet.module 'JobExchangeApp.Buy', (Buy, @AlumNet, Backbone, Marionette, $, _) ->

  class Buy.JobPostsView extends Marionette.ItemView
    template: 'job_exchange/buy/templates/job_posts'
    className: 'container'

    initialize: (options)->
      document.title = 'AlumNet - Buy Job Posts'
      @current_user = options.current_user
    
    events:
      'click button.js-submit': 'submitClicked'

    submitClicked: (e)->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      AlumNet.trigger 'payment:checkout' , data
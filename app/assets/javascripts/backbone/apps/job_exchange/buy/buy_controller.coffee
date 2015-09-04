@AlumNet.module 'JobExchangeApp.Buy', (Buy, @AlumNet, Backbone, Marionette, $, _) ->
  class Buy.Controller
    list: ()->
      console.log 'enter list'
      # job_posts = AlumNet.request('product:entities', {q: { feature_eq: 'job_post', status_eq: 1 }})
      # job_posts.on 'fetch:success', (collection)->
	     #  jobPostsView = new Buy.JobPostsView
	     #  	current_user: AlumNet.current_user
	     #  	collection: collection
	     #  AlumNet.mainRegion.show(jobPostsView)

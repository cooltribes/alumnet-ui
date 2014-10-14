@AlumNet.module "HeaderApp.Show", (Show, @AlumNet, Backbone, Marionette, $, _) ->

  class Show.Controller extends AlumNet.Controllers.Base
    initialize: (options) ->
      @show @layout

  


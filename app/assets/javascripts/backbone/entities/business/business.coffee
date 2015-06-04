@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Business extends Backbone.Model
    

  class Entities.BusinessCollection extends Backbone.Collection
    model: Entities.Business
    url: -> 
      AlumNet.api_endpoint + "/users/#{@user_id}/business"

    initialize: (options) ->
      @user_id = options.user_id 

  

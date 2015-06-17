@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Business extends Backbone.Model

    validation:
      company_name:
        required: true
        msg: "This field is required and must be less than 250 characters long."
      offer:
        required: true
        maxLength: 250
        msg: "This field is required and must be less than 250 characters long."
      search:
        required: true
        maxLength: 250
        msg: "This field is required and must be less than 250 characters long."
      
      offer_keywords: (value, attr, computedState) ->
        unless value[0]? && value[0] != ""
          "This field is required"

      search_keywords: (value, attr, computedState) ->
        unless value[0]? && value[0] != ""        
          "This field is required"
      
    

  class Entities.BusinessCollection extends Backbone.Collection
    model: Entities.Business
    url: -> 
      AlumNet.api_endpoint + "/users/#{@user_id}/business"

    initialize: (options) ->
      @user_id = options.user_id 

  

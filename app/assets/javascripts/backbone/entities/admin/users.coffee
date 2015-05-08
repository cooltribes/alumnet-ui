@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.UserStats extends Backbone.Model
    urlRoot: ->
      AlumNet.api_endpoint + '/admin/users/stats'

    defaults:
      graphType: 0
      q: ""
      location_id: 0

    events:
      "change:location_id": "changeLocation"  

    initialize: (options) ->
      if options? && options.graphType?
        if options.graphType == 1
          @set "q",
            profile_residence_country_region_id_eq: @get "location_id"
        
        else if options.graphType == 2
          @set "q",
            profile_residence_country_id_eq: @get "location_id"
        

        #query for region of residence
        # if options.graphType == 1
        #   @set "q",
        #     profile_residence_country_region_id_eq: options.region_id
        # #query for country of residence

    changeLocation: ->
      console.log "nelson"  
      console.log @get "location_id"    



  
  class Entities.UserStatsCollection extends Backbone.Collection
    

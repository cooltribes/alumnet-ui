@AlumNet.module 'Utilities', (Utilities, @AlumNet, Backbone, Marionette, $, _) ->

  AlumNet.months = [
    { pos: 1, name: "January" }
    { pos: 2, name: "February" }
    { pos: 3, name: "March" }
    { pos: 4, name: "April" }
    { pos: 5, name: "May" }
    { pos: 6, name: "June" }
    { pos: 7, name: "July" }
    { pos: 8, name: "August" }
    { pos: 9, name: "September" }
    { pos: 10, name: "October" }
    { pos: 11, name: "November" }
    { pos: 12, name: "December" }
  ]

  AlumNet.formatErrorsFromApi = (errors)->
    ## errors = { attr: [array] }
    container = []
    _.each errors, (array, attr, list)->
      attribute = s.humanize(attr)
      _.each array, (message)->
        container.push("#{attribute} #{message}")
    container.join(", ")

  AlumNet.urlWithTimestamp = (url)->
    "#{url}?#{new Date().getTime()}"

  AlumNet.loadReceptiveWidget = ->
    Backbone.ajax
      url: AlumNet.api_endpoint + '/me/receptive_settings'
      success: (data)->
        window.receptiveAppSettings = data.settings
        s = document.createElement('script');
        s.type = 'text/javascript'; s.async = true;
        s.src = 'https://receptive.io/js/widget/widget.js';
        x = document.getElementsByTagName('script')[0];
        x.parentNode.insertBefore(s, x);

  class Utilities.Seniorities
    fetch: (type, callback)->
      self = @
      Backbone.ajax
        url: AlumNet.api_endpoint + "/seniorities"
        async: false
        data:
          q: { seniority_type_eq: type }
        success: (response)->
          self.results = response
          if callback
            callback(response)

  ###
  This function is intended to be the general function
  for showing the location of any model in AlumNet,
  therefore it will passed two parameters, the type of model (user, group, event, etc)
  and the model itself.
  It returns the location formatted as a string containing country and city,
  computed from the locations objects

   @params from_elasticsearch Indicates if the model is returned from API as a source
   of elasticsearch. if false then the model is a backbone model (using "get" for attributes)

   nramirez!
  ###

  AlumNet.parseLocation = (type = "", model = {}, from_elasticsearch = false)->
    return null if type == "" or model == {}
    location = "No Location"
    city = ""

    if from_elasticsearch
      switch type
        when "user" #location for users
          city = model.residence_city.name
          country = model.residence_country.name
                    
        when "task", "group", "company", "event"
          city = model.city_info.name
          country = model.country_info.name      
        
        else
          country = ""      


    if city != ""
     location = "#{city} - #{country}"
    else
      if country != ""
        location = "#{country}"
      else  
        location = "No Location"              
      
    return location


  ###
  This function is responsible for building the respective url of each model 
  to be used as the path in the application UI
   
  nramirez!
  ###

  AlumNet.buildUrlFromModel = (model = {})->
  # AlumNet.buildUrlFromModel = (type = "", id = null, model = {})->
    # return null if type == "" or !id or model == {}
    return null if model == {}
    
    url = ""
    page = "posts"
    location = model.get('_index')
    id = model.get("_id")
    
    switch location
      when "profiles"
        location = "users"

      when "tasks"
        location = "business-exchange"
        page = ""                
      
      when "companies"
        page = "about"                      
      
      when null
        page = null     
      
      else


    if page == null
      url = null
    else
      if page == ""
        url = "#{location}/#{id}"
      else
        url = "#{location}/#{id}/#{page}"

    return url


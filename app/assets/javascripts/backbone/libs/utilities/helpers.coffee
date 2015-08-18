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

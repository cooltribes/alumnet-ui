@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Experience extends Backbone.Model
    defaults:
      first: false
      name: ""
      organization_name: ""
      start_year: ""
      start_month: ""
      end_year: ""
      end_month: ""
      description: ""
      country_id: ""
      city_id: ""
      internship: 0

      ########
      asTitle: false

    validation:
      name:
        required: true
      description:
        required: (value, attr, computedState) ->
          @get("exp_type") == 0 || @get("exp_type") == 1
      organization_name:
        required: (value, attr, computedState) ->
          @get("exp_type") == 2 || @get("exp_type") == 3
      start_year: "checkDate"
      end_year: "checkDate"
      country_id:
        required: (value, attr, computedState) ->
          if @get("exp_type") == 0 || @get("exp_type") == 1
            @get("region_id") == ''
      region_id:
        required: (value, attr, computedState) ->
          if @get("exp_type") == 0 || @get("exp_type") == 1
            @get("country_id") == ''

    checkDate: (value, attr, computedState)->
      if value == ''
        Backbone.Validation.validators.required(value, attr, true, @)
      else
        @formatDates()
        start = @get 'start_date'
        end = @get 'end_date'
        if moment(end).diff(moment(start), 'days') < 0
          'End date must be greater than Start date'

    formatDates: ->
      @formatDate('start')
      @formatDate('end')

    formatDate: (attr)->
      day = "01"
      month = @get("#{attr}_month")
      year = @get("#{attr}_year")

      #Si el usuario no selecciona mes, se pone por defecto en 1 (enero) y el dia en 01
      #Si el usuario selecciona 1 (enero), el dia se pone en 02.
      if parseInt(month) == 1 then day = 2

      if month == '' then month = "01"      

      if year == 'current'
        year = 0 #"0000"
        month = 0 # "00"
        day = 0 # "00"

      @set "#{attr}_date", "#{year}-#{month}-#{day}"

    getLocation: ()->
      if @get("city") && @get("country")
        return "#{@get("city").text} - #{@get("country").text}"
      "No Location"

    getOrganization: ()->
      if @get("organization_name")
        @get("organization_name")
      else
        false

    getEndDate: ()->
      @get("end_date") ? "Current"         

    getExperienceId: ->
      @experienceId[@get "exp_type"]

    getExperienceType: ->
      @experienceType[@get "exp_type"]

    experienceType:
      0: 'AIESEC Experience'
      1: 'Alumni Experience'
      2: 'Academic Experience'
      3: 'Professional Experience'

    experienceId:
      0: 'aiesecExperience'
      1: 'alumniExperience'
      2: 'academicExperience'
      3: 'professionalExperience'

  class Entities.ExperienceCollection extends Backbone.Collection
    model: Entities.Experience

    addExperiencesTitles: ->
      missing = [0..3]
      @each (model, index)->
        # console.log model
        #First delete previous titles
        # if model.isNew() && model.get ("asTitle")
        #   model.destroy()
        # else  
        type = model.get "exp_type"
        indexOf = missing.indexOf(type)
        if indexOf > -1
          missing.splice(indexOf, 1)

      #Put titles for every missing experience
      _.forEach missing, (element)  ->
        newExperience = new AlumNet.Entities.Experience
          exp_type: element
          first: true
          asTitle: true

        @push newExperience
      ,
        this  


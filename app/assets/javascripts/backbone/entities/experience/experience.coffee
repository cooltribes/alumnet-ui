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

      if month == '' then month = "01"

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

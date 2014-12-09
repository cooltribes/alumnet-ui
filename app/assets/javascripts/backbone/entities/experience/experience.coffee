@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Experience extends Backbone.Model
    defaults:
      first: false,
      name: "",
      organization_name: "",
      start_year: "",
      start_month: "",
      end_year: "",
      end_month: "",
      description: "",
      country_id: "",
      city_id: "",
      local_comitee: "",
      internship: 0,

    validation:
      name:
        required: true
      start_year:
        required: true
      end_year:
        required: true
      description:
        required: true
      country_id:
        required: true
      city_id:
        required: true
      committee_id:
        required: true
      organization_name:
        required: (value, attr, computedState) ->
          @get("exp_type") == 2 || @get("exp_type") == 3


  class Entities.ExperienceCollection extends Backbone.Collection
    model: Entities.Experience

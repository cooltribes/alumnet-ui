@AlumNet.module 'Entities', (Entities, @AlumNet, Backbone, Marionette, $, _) ->
  class Entities.Business extends Backbone.Model

    initialize: ()->
      @linksCollection = new Entities.LinksCollection @get("links")
      @updateLinksURL()

      @on "change:id", @updateLinksURL

      @company = new Entities.Company @get("company")


    updateLinksURL: ()->
      @linksCollection.url = AlumNet.api_endpoint + "/business/#{@id}/links"

    validation:
      company_name:
        required: true
        msg: "This field is required and must be less than 250 characters long."
      offer:
        required: true
        # maxLength: 250
        # msg: "This field is required and must be less than 250 characters long."
      search:
        required: true
        # maxLength: 250
        # msg: "This field is required and must be less than 250 characters long."

      offer_keywords: (value, attr, computedState) ->
        unless value[0]? && value[0] != ""
          "This field is required"

      search_keywords: (value, attr, computedState) ->
        unless value[0]? && value[0] != ""
          "This field is required"

  class Entities.BusinessCollection extends Backbone.Collection
    model: Entities.Business
    url: ->
      if @user_id
        AlumNet.api_endpoint + "/users/#{@user_id}/business"

    initialize: (models, options) ->
      if options
        @user_id = options.user_id



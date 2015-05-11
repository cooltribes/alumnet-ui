@AlumNet.module 'RegistrationApp.Approval', (Approval, @AlumNet, Backbone, Marionette, $, _) ->
  class Approval.UserView extends Marionette.ItemView
    template: 'registration/approval_process/templates/user'  

    ui:
      'requestBtn': '.js-ask'
      'actionsContainer': '.js-actions-container'
    
    events:
      'click @ui.requestBtn':'clickedRequest'
    
    clickedRequest: (e)->
      e.stopPropagation()
      e.preventDefault()
      @trigger("request")
      

      
  class Approval.Form extends Marionette.CompositeView
    template: 'registration/approval_process/templates/form'  
    childView: Approval.UserView
    childViewContainer: '.users-list'

    ui:
      'adminRequestBtn': '.js-askAdmin'
      selectResidenceCountries: "#js-residence-countries"

    events:
      'click .js-search': 'performSearch'
      'click @ui.adminRequestBtn':'clickedRequestAdmin'

    onRender: ()->
      data = CountryList.toSelect2()
      @ui.selectResidenceCountries.select2
        placeholder: "Select a Country"
        data: data
      # console.log @model  
      @ui.selectResidenceCountries.select2('val', @model.profile.get('residence_country').id)         

    clickedRequestAdmin: (e)->
      e.stopPropagation()
      e.preventDefault()
      @trigger("request:admin")
      @ui.adminRequestBtn.parent().empty().html('Your request has been sent to admin <span class="icon-entypo-paper-plane"></span>')
      # console.log "RequestAdmin"  

    performSearch: (e) ->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      console.log data
      @trigger('users:search', @buildQuerySearch(data))

    buildQuerySearch: (data) ->
      q:
        m: 'and'        
        profile_residence_country_id_eq: data.residence_country_id
        profile_first_name_or_profile_last_name_or_email_cont: data.search_term
        # profile_last_name_cont: data.searchTerm
        # email_cont: data.earchTerm
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
      'click #showMore': 'showMore'

    initialize: (options)->
      @bandera = options.bandera
      document.title = " AlumNet - Registration"

    templateHelpers: ->
      bandera: @bandera

    onShow: ->
      view = @
      ((url)->
        script = document.createElement('script')
        m = document.getElementsByTagName('script')[0]
        script.async = 1
        script.src = url
        m.parentNode.insertBefore(script, m)
      )('//api.cloudsponge.com/widget/2b05ca85510fb736f4dac18a06b9b6a28004f5fa.js')
      window.csPageOptions =
        skipSourceMenu: true
        afterInit: ()->
          links = document.getElementsByClassName('delayed');
          for link in links
            link.href = '#'
        beforeDisplayContacts: (contacts, source, owner)->
          view.formatContact(contacts)
          false

    onRender: ()->
      $('body,html').animate({scrollTop: 20}, 600);
      data = CountryList.toSelect2()
      @ui.selectResidenceCountries.select2
        placeholder: "Select a Country"
        data: data
      @ui.selectResidenceCountries.select2('val', @model.profile.get('residence_country').id)

    clickedRequestAdmin: (e)->
      e.stopPropagation()
      e.preventDefault()
      @trigger("request:admin")
      @ui.adminRequestBtn.parent().empty().html('Your request has been sent to an administrator. You will receive an e-mail notification once your Alumni status had been verified <span class="icon-entypo-paper-plane"></span>')

    performSearch: (e) ->
      e.preventDefault()
      data = Backbone.Syphon.serialize(this)
      @trigger('users:search', @buildQuerySearch(data))

    buildQuerySearch: (data) ->
      q:
        m: 'and'
        profile_residence_country_id_eq: data.residence_country_id
        profile_first_name_or_profile_last_name_or_email_cont: data.search_term

    formatContact: (contacts)->
      view = @
      formatedContacts = []
      _.map contacts, (contact)->
        formatedContacts.push({name: contact.fullName(), email: contact.selectedEmail()})
      users = new AlumNet.Entities.ContactsInAlumnet
      users.fetch
        method: 'POST'
        data: { contacts: formatedContacts }
        success: (collection)->
          view.collection.set(collection.models)

    showMore: (e)->
      e.preventDefault()
      @collection.fetch 
        success: ->
          $('#showMore').hide()
          @bandera = false
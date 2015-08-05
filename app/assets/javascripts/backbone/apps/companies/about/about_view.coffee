@AlumNet.module 'CompaniesApp.About', (About, @AlumNet, Backbone, Marionette, $, _) ->
   #Si son regiones utilizo layout
   class About.View extends Marionette.LayoutView
      template: 'companies/about/templates/about'
      className: 'container'

      regions:
         details: "#Details"
         contact_web: "#Contact-Web"
         branches: "#Branches"

      events:
        'click .smoothClick':'smoothClick'

      initialize: ->
         $(window).on 'scroll' , =>
           if $('body').scrollTop()>500
             $('#companyBusinessAffix').css
               'position': 'fixed'
               'width' : '265px'
               'top' : '120px'
           else
             if $('html').scrollTop()>500
               $('#companyBusinessAffix').css
                 'position': 'fixed'
                 'width' : '265px'
                 'top' : '120px'
             else
               $('#companyBusinessAffix').css
                 'position': 'relative'
                 'top':'0px'
                 'width':'100%'

      smoothClick: (e)->
        if $(e.target).prop("tagName")!='a'
          element = $(e.target).closest 'a'
        else
          element = e.target
        String id = $(element).attr("id")
        id = '#'+id.replace('to','')
        $('html,body').animate({
          scrollTop: $(id).offset().top-120
        }, 1000);

   class About.details extends Marionette.CompositeView
      template: 'companies/about/templates/details'
      className: 'container-fluid'

   class About.contact_web extends Marionette.CompositeView
      template: 'companies/about/templates/contact_web'
      className: 'container-fluid'

   class About.branches extends Marionette.CompositeView
      template: 'companies/about/templates/branches'
      className: 'container-fluid'
@AlumNet.module 'CompaniesApp.About', (About, @AlumNet, Backbone, Marionette, $, _) ->
   #Si son regiones utilizo layout
   class About.View extends Marionette.LayoutView
      template: 'company/about/templates/about'
      className: 'container'

      regions:
         details: "#details"
         contact_web: "#contact-web"
         branches: "#branches"

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
         
   class About.details extends Marionette.CompositeView
      template: 'company/about/templates/details'
      className: 'container-fluid'

   class About.contact_web extends Marionette.CompositeView
      template: 'company/about/templates/contact_web'
      className: 'container-fluid'

   class About.branches extends Marionette.CompositeView
      template: 'company/about/templates/branches'
      className: 'container-fluid'
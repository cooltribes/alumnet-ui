@AlumNet.module 'PagesApp', (PagesApp, @AlumNet, Backbone, Marionette, $, _) ->

  class PagesApp.Router extends AlumNet.Routers.Base
      appRoutes:
        "about": "pagesAbout"
        "contact": "pagesContact"
        "donate": "pagesDonate" 
        "joinAAI": "pagesJoinAAI"
        "privacyPolicy": "pagesPrivacy"
        "termsOfUse": "pagesTermsOfUse"
        "programs/business-exchange": "programsBusiness"
        "programs/job-exchange": "programsJob"
        "programs/home-exchange": "programsHome"
        "programs/a-groups": "programsAGroups"
        "programs/meet-ups": "programsMeetUps"
        "programs/alumnite": "programsAlumNite"

    API =
      pagesAbout: ()->
        document.title = 'AlumNet - About AIESSEC Alumni International'
        controller = new PagesApp.About.Controller
        controller.showAbout()

      pagesContact: ()->
        document.title = 'AlumNet - Contact us'
        controller = new PagesApp.Contact.Controller
        controller.showContact()

      pagesDonate: ()->
        document.title = 'AlumNet - Donate to the AAI Seed'
        controller = new PagesApp.Donate.Controller
        controller.showDonate()

      pagesJoinAAI: ()->
        document.title = 'AlumNet - Join us'
        controller = new PagesApp.Join.Controller
        controller.showJoin()

      pagesPrivacy: ()->
        document.title = 'AlumNet - Privacy Policy'
        controller = new PagesApp.Privacy.Controller
        controller.showPrivacy()

      pagesTermsOfUse: ()->
        document.title = 'AlumNet - Terms Of Use'
        controller = new PagesApp.Terms.Controller
        controller.showTermsOfUse()

      programsBusiness: ()->
        document.title = 'AlumNet - Business Exchange Program'
        controller = new PagesApp.Programs.Controller
        controller.showBusiness()

      programsHome: ()->
        document.title = 'AlumNet - Home Exchange Program'
        controller = new PagesApp.Programs.Controller
        controller.showHome()

      programsMeetUps: ()->
        document.title = 'AlumNet - Global Meet-ups Program'
        controller = new PagesApp.Programs.Controller
        controller.showMeetUps()

      programsJob: ()->
        document.title = 'AlumNet - Jobs Exchange Program'
        controller = new PagesApp.Programs.Controller
        controller.showJob()

      programsAGroups: ()->
        document.title = 'AlumNet - A-Groups Program'
        controller = new PagesApp.Programs.Controller
        controller.showAGroups()

      programsAlumNite: ()->
        document.title = 'AlumNet - ALUMnite Program'
        controller = new PagesApp.Programs.Controller
        controller.showAlumNite()

    AlumNet.on "about", () ->
        AlumNet.navigate("about")
        API.pagesAbout()

    AlumNet.on "contact", () ->
        AlumNet.navigate("contact")
        API.pagesContact()

    AlumNet.on "donate", () ->
        AlumNet.navigate("donate")
        API.pagesDonate()

    AlumNet.on "joinAAI", () ->
        AlumNet.navigate("joinAAI")
        API.pagesJoinAAI()

    AlumNet.on "privacyPolicy", () ->
        AlumNet.navigate("privacy")
        API.pagesPrivacyPolicy()

    AlumNet.on "termsOfUse", () ->
        AlumNet.navigate("termsOfUse")
        API.pagesTermsOfUse()

    AlumNet.on "programs", () ->
        AlumNet.navigate("programs")
        API.pagesPrograms()
    AlumNet.on "programs/business-exchange", () ->
        AlumNet.navigate("programs/business-exchange")
        API.pagesPrograms()

    AlumNet.addInitializer ->
      new PagesApp.Router
        controller: API

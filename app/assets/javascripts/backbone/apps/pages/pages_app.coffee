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
        controller = new PagesApp.About.Controller
        controller.showAbout()

      pagesContact: ()->
        controller = new PagesApp.Contact.Controller
        controller.showContact()

      pagesDonate: ()->
        controller = new PagesApp.Donate.Controller
        controller.showDonate()

      pagesJoinAAI: ()->
        controller = new PagesApp.Join.Controller
        controller.showJoin()

      pagesPrivacy: ()->
        controller = new PagesApp.Privacy.Controller
        controller.showPrivacy()

      pagesTermsOfUse: ()->
        controller = new PagesApp.Terms.Controller
        controller.showTermsOfUse()

      programsBusiness: ()->
        controller = new PagesApp.Programs.Controller
        controller.showBusiness()

      programsHome: ()->
        controller = new PagesApp.Programs.Controller
        controller.showHome()

      programsMeetUps: ()->
        controller = new PagesApp.Programs.Controller
        controller.showMeetUps()

      programsJob: ()->
        controller = new PagesApp.Programs.Controller
        controller.showJob()

      programsAGroups: ()->
        controller = new PagesApp.Programs.Controller
        controller.showAGroups()

      programsAlumNite: ()->
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

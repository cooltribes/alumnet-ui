@AlumNet.module 'PagesApp', (PagesApp, @AlumNet, Backbone, Marionette, $, _) ->

  class PagesApp.Router extends AlumNet.Routers.Base
      appRoutes:
        "about": "pagesAbout"
        "contact": "pagesContact"
        "donate": "pagesDonate" 
        "joinAAI": "pagesJoinAAI"
        "privacyPolicy": "pagesPrivacy"
        "termsOfUse": "pagesTermsOfUse"

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

    AlumNet.addInitializer ->
      new PagesApp.Router
        controller: API

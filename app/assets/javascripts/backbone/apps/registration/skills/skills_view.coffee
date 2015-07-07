@AlumNet.module 'RegistrationApp.Skills', (Skills, @AlumNet, Backbone, Marionette, $, _) ->

  class Skills.FormLanguage extends Marionette.ItemView
    template: "registration/skills/templates/form"
    tagName: 'form'

    initialize: ->
      Backbone.Validation.bind this,
        valid: (view, attr, selector) ->
          $el = view.$("[name^=#{attr}]")
          $group = $el.closest('.form-group')
          $group.removeClass('has-error')
          $group.find('.help-block').html('').addClass('hidden')
        invalid: (view, attr, error, selector) ->
          $el = view.$("[name^=#{attr}]")
          $group = $el.closest('.form-group')
          $group.addClass('has-error')
          $group.find('.help-block').html(error).removeClass('hidden')

    ui:
      'btnRmv': '.js-rmvRow'
    events:
      "click @ui.btnRmv": "removeItem"

    removeItem: (e)->
      @model.destroy()

    onRender: ->
      $('body,html').animate({scrollTop: 20}, 600);
      #Render the slider
      slideItem = $("#slider", @el)
      levelTextItem = slideItem.next("#level")

      textLevel =
            1: "Elementary"
            2: "Limited working"
            3: "Professional working"
            4: "Full professional"
            5: "Native or Bilingual"

      levelTextItem.text(textLevel[@model.get("level")])

      slideItem.slider
        min: 1
        max: 5
        value: parseInt( @model.get("level"), 10 )
        slide: (event, ui) ->
          levelTextItem.text(textLevel[ui.value])

      #Render the list of languages
      dropdown = $("[name=language_id]", $(@el))
      content = AlumNet.request("languages:html", @model.get("name"))
      dropdown.html(content)

  class Skills.LanguageList extends Marionette.CompositeView
    template: 'registration/skills/templates/skills'
    childView: Skills.FormLanguage
    childViewContainer: '#lan-list'
    className: 'row'

    initialize: (options)->
      document.title = " AlumNet - Registration"
      @linkedin_skills = options.linkedin_skills

    templateHelpers: ->
      linkedin_skills: @linkedin_skills.join(", ")

    ui:
      'btnAdd': '.js-addRow'
      'btnSubmit': '.js-submit'
      'skills': '#skills-input'

    events:
      'click @ui.btnAdd': 'addRow'
      'click @ui.btnSubmit': 'submitClicked'
      'click .js-linkedin-import': 'linkedinClicked'

    oonRender: ->
      skillsList = new AlumNet.Entities.Skills
      skillsList.fetch
        success: =>
          @fillSkills(skillsList)
      $('body,html').animate({scrollTop: 20}, 600);


    fillSkills: (collection)->
      skills = _.pluck(collection.models, 'attributes')
      listOfNames = _.pluck(skills, 'name')
      @ui.skills.select2
        tags: listOfNames
        multiple: true
        tokenSeparators: [',', ', ']
        dropdownAutoWidth: true

    addRow: (e)->
      newRow = new AlumNet.Entities.ProfileLanguage
      @collection.add(newRow)

    submitClicked: (e)->
      e.preventDefault()

      #retrieve each itemView data
      @children.each (itemView)->
        data = Backbone.Syphon.serialize itemView
        itemView.model.set data

      skillsData = Backbone.Syphon.serialize this #,
        # include: "skills"
      skillsData = skillsData.skills.split(',')

      this.trigger("form:submit", @model, skillsData)

    linkedinClicked: (e)->
      if gon.linkedin_profile && gon.linkedin_profile.skills.length > 0
        e.preventDefault()
        @render()



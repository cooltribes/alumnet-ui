class AlumnetLinkedin
  attr_accessor :client, :valid

  API_KEY = "77m01gfshs64pi"
  API_SECRET = "7f9vbnhJJa4Lu9DD"
  CONFIG = { site: 'https://api.linkedin.com',
    authorize_path: '/uas/oauth/authenticate',
    request_token_path: '/uas/oauth/requestToken?scope=r_basicprofile+r_fullprofile+r_emailaddress+r_network+r_contactinfo',
    access_token_path: '/uas/oauth/accessToken' }

  CONTACT_TYPE = { "skype" => 2, "yahoo" => 3 }

  FIELDS = ["phone-numbers", "im-accounts", "primary-twitter-account", "languages", "positions",
    "date-of-birth", "first-name", "last-name", "picture-url", "skills", "email-address", "id",
    "educations"]

  def initialize
    @client = LinkedIn::Client.new(API_KEY, API_SECRET, CONFIG)
    @valid = true
  end

  def auth_params
    { email: linkedin['email_address'], provider: "linkedin", uid: linkedin['id'] }
  end

  def profile
    { languages: languages_for_alumnet, contacts: contacts_for_alumnet, experiences: experiences_for_alumnet,
      profile: profile_for_alumnet, skills: skills_for_alumnet, educations: educations_for_alumnet }
  end

  def languages_for_alumnet
    linkedin ? format_languages(linkedin['languages']) : []
  end

  def contacts_for_alumnet
    if linkedin
      [format_im_phones(linkedin['phone_numbers']), format_im_accounts(linkedin['im_accounts']), format_twiter(linkedin["primary_twitter_account"])].flatten
    else
      []
    end
  end

  def experiences_for_alumnet
    linkedin ? format_positions(linkedin['positions']) : []
  end

  def profile_for_alumnet
    if linkedin
      { first_name: linkedin['first_name'], last_name: linkedin['last_name'], born: format_date_of_birth(linkedin['date-of-birth']),
        avatar_url: linkedin['picture_url'] }
    else
      nil
    end
  end

  def skills_for_alumnet
    linkedin ? format_skills(linkedin['skills']) : []
  end

  def educations_for_alumnet
    linkedin ? format_educations(linkedin['educations']) : []
  end

  protected
    def linkedin
      @linkedin ||= client.profile(fields: FIELDS, headers: {"Accept-Language" => "es_ES"})
    rescue
      @valid = false
    end

    def format_im_accounts(accounts)
      array = []
      accounts.all.each do |account|
        if CONTACT_TYPE.keys.include?(account.im_account_type)
          array << {info: account.im_account_name, contact_type: CONTACT_TYPE[account.im_account_type]}
        end
      end
      array
    end

    def format_im_phones(phone_numbers)
      phone_numbers.all.inject([]) do |array, phone|
        array << {info: phone.phone_number, contact_type: 1}
      end
    end

    def format_twiter(twitter)
      { info: twitter.provider_account_name, contact_type: 5} if twitter
    end

    def format_languages(languages)
      if languages
        languages.all.inject([]) do |array, language|
          array << {id: language.id, name: language.language.name}
        end
      else
        []
      end
    end

    def format_skills(skills)
      if skills
        skills.all.inject([]) do |array, skill|
          array << { name: skill.skill.name }
        end
      else
        []
      end
    end

    def format_positions(positions)
      positions.all.inject([]) do |array, position|
        start_date = format_position_date(position.start_date)
        if position.is_current
          end_date = { month: "", year: "current" }
        else
          end_date = format_position_date(position.end_date)
        end
        array << {exp_type: 3, name: position.title, description: position.summary,
          organization_name: position.company.name, start_year: start_date[:year],
          start_month: start_date[:month], end_year: end_date[:year], end_month: end_date[:month]}
      end
    end

    def format_educations(educations)
      educations.all.inject([]) do |array, education|
        array << {exp_type: 2, name: education.degree, organization_name: education.school_name,
        start_month: '01', start_year: education.start_date.year, end_month: '01',
        end_year: education.end_date.year, description: education.field_of_study }
      end
    end

    def format_position_date(date)
      month = date.try(:month) ? date.month : ""
      year = date.try(:year) ? date.year : ""
      { month: month, year: year }
    end

    def format_date_of_birth(date)
      day = date.try(:day)
      month = date.try(:month)
      year = date.try(:year)
      if day.present? && month.present? && year.present?
        "#{year}-#{month.to_s.rjust(2, '0')}-#{day.to_s.rjust(2, '0')}"
      else
        ""
      end
    end
end
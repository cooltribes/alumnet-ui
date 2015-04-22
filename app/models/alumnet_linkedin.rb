class AlumnetLinkedin
  attr_accessor :client

  API_KEY = "77m01gfshs64pi"
  API_SECRET = "7f9vbnhJJa4Lu9DD"
  CONFIG = { site: 'https://api.linkedin.com',
    authorize_path: '/uas/oauth/authenticate',
    request_token_path: '/uas/oauth/requestToken?scope=r_basicprofile+r_fullprofile+r_emailaddress+r_network+r_contactinfo',
    access_token_path: '/uas/oauth/accessToken' }

  CONTACT_TYPE = { "skype" => 2, "yahoo" => 3 }

  FIELDS = ["phone-numbers", "im-accounts", "primary-twitter-account", "languages", "positions"]

  def initialize
    @client = LinkedIn::Client.new(API_KEY, API_SECRET, CONFIG)
  end

  def profile
    { languages: languages_for_alumnet, contacts: contacts_for_alumnet, experiences: experiences_for_alumnet }
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

  protected
    def linkedin
      @linkedin ||= client.profile(fields: FIELDS)
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
      { info: twitter.provider_account_name, contact_type: 5}
    end

    def format_languages(languages)
      languages.all.inject([]) do |array, language|
        array << {id: language.id, name: language.language.name}
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

    def format_position_date(date)
      month = date.try(:month) ? date.month : ""
      year = date.try(:year) ? date.year : ""
      { month: month, year: year }
    end
end
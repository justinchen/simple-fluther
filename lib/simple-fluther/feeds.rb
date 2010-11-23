module SimpleFluther
  class Feeds  
    def self.recent_owned_questions_url
      "#{SimpleFluther::FederatedHost}/feeds/questions/?fed_key=#{SimpleFluther::Config.app_key}"
    end
    
    def self.recent_owned_questions_raw
      begin
        tmp = open(self.recent_owned_questions_url, "User-Agent" => SimpleFluther::UserAgent)
        tmp.read
      rescue Exception
        nil
      end
    end
  end
end
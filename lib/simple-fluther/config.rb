module SimpleFluther
  class Config
    def self.prefix( *args )
      @@prefix = nil  unless defined? @@prefix
      return @@prefix  if args.empty?
      @@prefix = args.first
      @@prefix = "/#{@@prefix}" unless @@prefix.starts_with?('/')
      @@prefix
    end

    def self.fluther_host( *args )
      @@fluther_host = nil  unless defined? @@fluther_host
      return @@fluther_host  if args.empty?
      @@fluther_host = args.first
    end

    def self.app_key( *args )
      @@app_key = nil  unless defined? @@app_key
      return @@app_key  if args.empty?
      @@app_key = args.first
    end

    def self.method_to_get_current_user( *args)
      @@method_to_get_current_user = nil  unless defined? @@method_to_get_current_user
      return @@method_to_get_current_user  if args.empty?
      @@method_to_get_current_user = args.first
    end
    
    def self.user_fields( *args )
      @@user_fields = { :id => :id, :name => :name, :email => :email }  unless defined? @@user_fields
      return @@user_fields  if args.empty?
      @@user_fields.update args.first
    end
    
  end

  def self.topic_path(t)
    t.downcase!
    t.gsub!(' ', '_')
    "#{SimpleFluther::Config.prefix}/topics/#{t}/"
  end
end

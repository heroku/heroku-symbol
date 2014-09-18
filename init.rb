if !ENV['DISABLE_HEROKU_SYMBOL']
  require "heroku/command/base"

  # manage app config vars
  #
  class Heroku::Command::Config < Heroku::Command::Base
    # config
    #
    # display the config vars for an app
    #
    # -s, --shell  # output config vars in shell format
    #
    #Examples:
    #
    # $ heroku config
    # A: one
    # B: two
    #
    # $ heroku config --shell
    # A=one
    # B=two
    #
    def index
      validate_arguments!

      vars = if options[:shell]
               api.get_config_vars(app).body
             else
               api.request(
                 :expects  => 200,
                 :method   => :get,
                 :path     => "/apps/#{app}/config_vars",
                 :query    => { "symbolic" => true }
               ).body
             end

      if vars.empty?
        display("#{app} has no config vars.")
      else
        vars.each {|key, value| vars[key] = value.to_s}
        if options[:shell]
          vars.keys.sort.each do |key|
            display(%{#{key}=#{vars[key]}})
          end
        else
          styled_header("#{app} Config Vars")
          styled_hash(vars)
        end
      end
    end
  end
end

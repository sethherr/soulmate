require 'sinatra/base'
require 'soulmate'
require 'rack/contrib'

module Soulmate

  class Server < Sinatra::Base
    include Helpers
    
    before do
      content_type 'application/json', :charset => 'utf-8'
    end

    before do 
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, PUT, GET, OPTIONS'
      headers['Access-Control-Request-Method'] = '*'
      headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
      headers['Access-Control-Max-Age'] = "1728000"
    end
    
    get '/' do
      raise Sinatra::NotFound unless (params[:term] and params[:types] and params[:types].is_a?(Array))
      
      limit = (params[:limit] || 5).to_i
      types = params[:types].map { |t| normalize(t) }
      term  = params[:term]
      
      results = {}
      types.each do |type|
        matcher = Matcher.new(type)
        results[type] = matcher.matches_for_term(term, :limit => limit)
      end
      
      MultiJson.encode({
        :term    => params[:term],
        :results => results
      })
    end

    get '/status' do
      MultiJson.encode({ :soulmate => Soulmate::Version::STRING, :status   => "ok" })
    end
    
    not_found do
      content_type 'application/json', :charset => 'utf-8'
      MultiJson.encode({ :error => "not found" })
    end
    
  end
end

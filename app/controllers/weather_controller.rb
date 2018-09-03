class WeatherController < ApplicationController
  OWM_WEATHER = 'http://api.openweathermap.org/data/2.5/weather'.freeze
  OWM_FIND = 'http://api.openweathermap.org/data/2.5/find'.freeze
  COUNTRY_CODE = 'AR'.freeze
  def index
    request = OWM_WEATHER + "?q=#{index_params}&app_id=#{app_id}"
  end

  def cities
    request = HTTParty.get(OWM_FIND + "?q=#{name_param},#{COUNTRY_CODE}&type=like&appid=#{app_id}")
    response = JSON.parse(request.body)
    if response['count'] > 0
      render json: response['list'].map{ |e| { id: e['id'], name: e['name']} }
    else
      render json: []
    end
  end

  private

  def index_params
    params.require(:city_id)
  end

  def name_param
    params.require(:name)
  end

  def app_id
    Rails.application.secrets.open_weather_api_key
  end
end

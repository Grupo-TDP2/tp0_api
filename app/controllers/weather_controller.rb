class WeatherController < ApplicationController
  OWM_FORECAST = 'http://api.openweathermap.org/data/2.5/forecast'.freeze
  STATIC_CITY_IDS = ['-1', '-2']
  def index
    return render json: static_city if id_of_static_city?
    request = HTTParty.get(OWM_FORECAST + "?id=#{index_params}&appid=#{app_id}")
    render json: process_forecast(JSON.parse(request.body))
  end

  def cities
    city_name = "#{name_param}%"
    render json: City.where("name ilike ?", city_name)
  end

  private

  def id_of_static_city?
    STATIC_CITY_IDS.include?(index_params)
  end

  def static_city
    index_params == '-1' ? StaticCity.paris_2 : StaticCity.paris_3
  end

  def process_forecast(owm_forecast)
    owm_forecast
  end

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

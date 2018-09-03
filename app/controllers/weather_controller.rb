class WeatherController < ApplicationController
  OWM_FORECAST = 'http://api.openweathermap.org/data/2.5/forecast'.freeze
  def index
    request = OWM_FORECAST + "?q=#{index_params}&app_id=#{app_id}"
  end

  def cities
    city_name = "#{name_param}%"
    render json: City.where("name ilike ?", city_name)
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

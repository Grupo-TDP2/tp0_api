class WeatherController < ApplicationController
  OWM_FORECAST = 'http://api.openweathermap.org/data/2.5/forecast'.freeze
  STATIC_CITY_IDS = ['-1', '-2']
  def index
    return render json: static_city if id_of_static_city?
    request = HTTParty.get(OWM_FORECAST + "?id=#{index_params}&units=metric&appid=#{app_id}")
    render json: process_forecast(JSON.parse(request.body)['list'])
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
    response = {'isDayInCity': true, day_1: {}, day_2: {}, day_3: {}, day_4: {}, day_5: {}}
    (0..4).each do |i|
      # select all entries for day i
      day_forecast = filter_forecast_for(Date.current + i.days, owm_forecast)
      response["day_#{i+1}"] = means_for_day(day_forecast)
    end
    response
  end

  def filter_forecast_for(date, owm_forecast)
    result = []
    owm_forecast.each do |forecast|
      if (forecast['dt_txt'] + ' UTC').to_time.between?(date.beginning_of_day, date.end_of_day)
        result << forecast
      end
    end
    result
  end

  def means_for_day(day_forecast)
    means = { midday: { temperature: nil, weather: nil }, midnight: { temperature: nil, weather: nil } }
    day_forecast.reverse!
    if day_forecast.size <= 4
      means['midnight'] = mean_temperature_weather(day_forecast[0, day_forecast.size])
    else
      means['midnight'] = mean_temperature_weather(day_forecast[0, 4])
      means['midday'] = mean_temperature_weather(day_forecast[4, day_forecast.size])
    end
    means
  end

  def mean_temperature_weather(forecast_array)
    { temperature: (forecast_array.sum { |f| f['main']['temp'] } / forecast_array.size).round,
      weather: forecast_array.last['weather'].first['id'] } # We take the last one since it's the most recent one
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

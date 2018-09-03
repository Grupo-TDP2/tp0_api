namespace :owm_data do
  task import_cities: :environment do
    file = JSON.parse(File.read(Rails.root.join('docs','city.list.json')))
    file.each do |city|
      City.create(owm_id: city['id'], name: city['name']) if city['country'] == 'AR'
    end
  end
end

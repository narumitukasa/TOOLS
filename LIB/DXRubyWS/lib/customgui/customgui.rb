Dir[File.dirname(__FILE__) + '/*.rb'].sort.each do |path|
  require path
end
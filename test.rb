require 'faker'
require_relative 'captcha'
require_relative 'solver'

# class to test our captcha solver
class Test
  def self.run
    # Create a random text
    text = Faker::Lorem.characters(6)
    puts "Text to create #{text}"

    # Create an image
    image = Captcha.generate text, 400, 200, 80
    path = 'captcha.jpg'
    File.open(path, 'wb') { |f| f.write(image) }

    # Send image's path to solver and wait for result
    result = Solver.solve path
    puts "result: #{result}"
  end
end

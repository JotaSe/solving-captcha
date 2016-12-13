require 'faker'
require_relative 'captcha'
require_relative 'solver'

# class to test our captcha solver
class Test
  def self.run
    # Create a random text
    text = random_text

    # Create an image
    path = 'captcha.jpg'
    create_image path, text

    # solving captcha
    solve path
  end

  def self.random_text
    text = Faker::Lorem.characters(6)
    puts "Text to create '#{text}'"
    text
  end

  def self.create_image(path, text)
    image = Captcha.generate text, 400, 200, 80
    File.open(path, 'wb') { |f| f.write(image) }
  end

  def self.solve(path)
    # instance a solver class
    args = {
      psm: 7, # this is how ocr will work https://github.com/tesseract-ocr/tesseract/wiki/Command-Line-Usage
      options: :alphanum, # check other options https://github.com/dannnylo/rtesseract
      lang: :eng # languate option, we will set eng as default
    }
    solver = Solver.new args

    # Send image's path to solver and wait for result
    puts 'Solving captcha'
    result = solver.solve path
    puts "result: #{result}"
  end
end

Test.run
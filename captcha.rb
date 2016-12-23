require 'rmagick'

class Captcha
  # Generates the CAPTCHA image with +captcha_text+
  # @param [String] captcha_text the text to include in the CAPTCHA image
  # @return [String] the bytes of the generated image
  def self.generate(captcha_text, width = 100, height = 32, text_size = 22)
    image = create_image(width, height)
    draw_text!(captcha_text, image, text_size)

    image = apply_distortion!(image)

    data = image.to_blob
    image.destroy!

    data
  end

  def self.create_image(width, height)
    image = Magick::Image.new(width, height)
    image.format = 'jpg'
    image.gravity = Magick::CenterGravity
    image.background_color = 'white'

    image
  end

  def self.draw_text!(text, image, text_size)
    draw = Magick::Draw.new

    draw.annotate(image, image.columns, image.rows, 0, 0, text) do
      self.gravity = Magick::CenterGravity
      self.pointsize = text_size
      self.fill = 'darkblue'
      self.stroke = 'transparent'
    end

    nil
  end

  def self.apply_distortion!(image)
    image = image.swirl rand(10)
    image = image.add_noise Magick::ImpulseNoise
    image
  end
end

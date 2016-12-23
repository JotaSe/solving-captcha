require 'rtesseract'
require 'rmagick'

# Transform and solve captchas
class Solver
  def initialize(args = {})
    @solved_path = 'captcha_solved.jpg'
    @psm = args[:psm]
    @options = args[:options]
    @lang = args[:lang]
  end

  def solve(image_path)
    # read image from disk
    img = Magick::Image.read(image_path).first
    # process image to reduce noise and improve text quality
    img = process_image(img)
    # enhance the image to improve ocr accuracy
    img = enhance(img)
    # save the image in disk
    img.write(@solved_path)
    # extract result
    extract_characters
  end

  def process_image(img)
    # to improve OCR quality, let's crop the image
    # args X, Y, width, height
    img.crop!(50, 60, 300, 80)

    # img.scale! 0.5

    # transform image into gray scale colors
    img = img.quantize(128, Magick::GRAYColorspace)

    # convert into white everything below the threshold
    img = img.white_threshold(180 * 256)

    # transform image into binary colors
    img = img.quantize(2, Magick::GRAYColorspace)

    # Add border to avoid noise there
    img.border!(5, 5, 'white')
  end

  def enhance(img)
    # clean extra noise
    clean_image img, 2
    # fill blank spots
    fill img
    # soft edges
    img = img.gaussian_blur 0.5, 0.5
    # cut white space to improve ocr accuracy
    trim(img)
    # reduce size
    img.scale! 0.75

  end

  def fill(img, range = 3, color = 'black')
    process img, color, range
  end

  def clean_image(img, range = 4, color = 'white')
    process img, color, range
  end

  def trim(img)
    img.fuzz = 1
    img.trim!
  end

  def process(img, color, range)
    img.each_pixel do |_pixel, c, r|
      next if border?(c, range, img.columns) || border?(r, range, img.rows)
      # Determinamos la cantidad de pixeles del mismo color
      # en un bloque range * range alrededor del pixel actual
      pixels = img.get_pixels(c, r, range, range).map do |e|
        e if e.to_color.eql? color
      end
      # Si la cantidad de pixeles es mayor al radio son puntos
      # que se deben pintar
      img.pixel_color(c, r, color) if pixels.compact.size >= range
    end
  end

  def border?(pixel, range, max)
    pixel < range || pixel > (max - range)
  end

  def extract_characters
    text = RTesseract.new(@solved_path,
                          lang: @lang,
                          options: @options,
                          psm: @psm)
    text.to_s_without_spaces
  end
end

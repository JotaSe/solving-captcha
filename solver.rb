require 'rtesseract'
require 'RMagick'

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

    # transform image into gray scale colors
    img = img.quantize(128, Magick::GRAYColorspace)

    # convert into white everything below the threshold
    img = img.white_threshold(140 * 256)

    # transform image into binary colors
    img = img.quantize(2, Magick::GRAYColorspace)

    # Add border to avoid noise there
    img.border!(5, 5, 'white')
  end

  def enhance(img)
    img
  end

  def extract_characters
    text = RTesseract.new(@solved_path,
                          lang: @lang,
                          options: @options,
                          psm: @psm)
    text.to_s_without_spaces
  end
end

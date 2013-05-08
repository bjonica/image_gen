#!/usr/bin/env ruby

# generate a random NxN symmetrical image
# author: Boris Jonica
# usage `imggen filename.png filename2.png filename3.png ...`

#------------------------------------------------------------------------
# This is free and unencumbered software released into the public domain.
# For more information, see UNLICENSE
#------------------------------------------------------------------------

require 'chunky_png'

# Begin Configuration
@blockiness = 7     # higher number = more blocks
@noise = 8          # higher number = smaller blocks
@color = {          # base color of the image
    :r => rand(0..255),
    :g => rand(0..255),
    :b => rand(0..255)}
@size = 256         # length and width dimension of the final image, in pixels
# End Configuration

ARGV.each do |filename|
  # we first generate a two dimensional array of booleans, which is used to
  # generate the scaled and mirrored pattern in the image
  base_img = Array.new(@noise) {Array.new(@noise)}
  @noise.times do |i|
    @noise.times do |j|
      base_img[i][j] = false unless base_img[i][j]
      if rand(0..@blockiness) == @blockiness
        base_img[i][j] = !(base_img[i][j])
        y = @noise
        until (y -= 1) == i
          x = @noise
          until (x -= 1) == j
            base_img[y][x] = base_img[i][j]
          end
        end
      end
    end
  end

  # png stores our final result
  png = ChunkyPNG::Image.new(@size, @size, ChunkyPNG::Color::TRANSPARENT)

  quad   = @size / 2      # size of a quadrant of the image
  factor = quad / @noise  # used for scaling the array

  # here we generate the quadrant image, and then flip it on x, y, and x-y axes
  quad.times do |i|
    quad.times do |j|
      # pixel coloring logic
      # I play with this math. A lot. have fun
      if base_img[Integer(i / factor)][Integer(j / factor)]
        png[i,j] = ChunkyPNG::Color.rgba((j + (@color[:r] / (j+1))) % 255,
                                         ((i+j) + @color[:g]) % 255,
                                         (i + @color[:b]) % 255,
                                         255)
      else
        png[i,j] = ChunkyPNG::Color.rgba((i - @color[:r]) % 255,
                                         (j + @color[:g]) % 255,
                                         (i + j + @color[:b]) % 255,
                                         255)
      end

      # mirror the pixel
      png[@size - 1 - i, j] = png[i,j]
      png[i, @size - 1 - j] = png[i,j]
      png[@size - 1 - i, @size - 1 - j] = png[i,j]
    end
  end

  png.save(filename, :interlace => true)
end

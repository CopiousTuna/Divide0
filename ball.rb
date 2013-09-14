
class Ball

	attr_reader :x, :y, :dX, :dY, :radius

	def initialize(x, y, dX, dY)
		@radius = 25 / 2  # Image width is 25px
		@x = x + @radius
		@y = y + @radius
		@dX = dX
		@dY = dY
		
		@@img ||= Gosu::Image::load_tiles($window, "img/ball.png", 25, 25, false)
	end
	
	def move
		@x += @dX
		@y += @dY
	end
	
	def set_dX(dX, dY)
		@dX = dX
		@dY = dY
	end
	
	def set_pos(x, y)
		@x = x
		@y = y
	end
	
	def update(balls)
		check_ball_collision(balls)
		check_wall_collision
	end
	
	def check_ball_collision(balls)
		balls.each do |ball|
			if self != ball
				if (@x - ball.x).abs + (@y - ball.y).abs < radius + ball.radius
					# Change delta for each ball
					dX_temp = @dX
					dY_temp = @dY
					set_dX(ball.dX, ball.dY)
					ball.set_dX(dX_temp, dY_temp)

					# Move balls apart if they are inside of each other
					move
					ball.move
				end
			end
		end
	end
	
	def check_wall_collision
		if @x - @radius <= 0
			@x = @radius
			@dX *= -1
		end
		if @y - @radius <= 0
			@y = @radius
			@dY *= -1
		end
		if @x + @radius >= $win_width
			@x = $win_width - @radius * 2
			@dX *= -1
		end
		if @y + @radius >= $win_height
			@y = $win_height - @radius * 2
			@dY *= -1
		end
	end
	
	def draw
		@@img[0].draw(@x - @radius, @y - @radius, 1)
	end

end
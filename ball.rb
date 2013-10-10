
class Ball

	attr_reader :x, :y, :dX, :dY, :radius

	def initialize(x, y, dX, dY)
		@radius = 25 / 2  # Image width is 25px
		
		if x + @radius > $win_width
			@x = x
		else
			@x = x + @radius
		end
		
		if y + @radius > $win_height
			@y = y
		else
			@y = y + @radius
		end
		
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
	
	# Checks for collisions with lines, other balls, and window.
	# Returns true if a collision with the expanding line is detected.
	def update(balls, line_expanding, lines_expanded)
		check_ball_collision(balls)
		check_wall_collision
		
		# Check for collision with expanding line, return true if collision is found
		return true if line_expanding != nil && check_line_collision(line_expanding)
		
		# Check for collision with expanded lines
		lines_expanded.each do |line|
			check_line_collision(line)	
		end
		
		return false
	end

	# Returns true if collision is detected, false otherwise
	def check_line_collision(line)
		if @y >= line.y1 && @y <= line.y2
			if @x < line.x1 && line.x1 - @x <= @radius
				@x = line.x1 - @radius - 1
				@dX *= -1
				return true
			elsif @x > line.x1 && @x - line.x1 <= @radius
				@x = line.x1 + @radius + 1
				@dX *= -1
				return true
			end
		elsif @x >= line.x1 && @x <= line.x2
			if @y < line.y1 && line.y1 - @y <= @radius
				@y = line.y1 - @radius - 1
				@dY *= -1
				return true
			elsif @y > line.y1 && @y - line.y1 <= @radius
				@y = line.y1 + @radius + 1
				@dY *= -1
				return true
			end					
		end
		
		return false
	end
	
	# Checks for collision with other balls and handles collision physics
	# Return true if collision is detected with another ball
	def check_ball_collision(balls)
		balls.each do |ball|
			if self != ball
				if get_distance(ball) < radius + ball.radius
					# Change delta for each ball
					dX_temp = @dX
					dY_temp = @dY
					set_dX(ball.dX, ball.dY)
					ball.set_dX(dX_temp, dY_temp)

					# Move balls apart if they are inside of each other
					move
					ball.move
					return
				end
			end
		end
	end
	
	# Checks for collision with the window and handles collision physics
	# Return true if collision is detected with the window
	def check_wall_collision
		if @x - @radius <= 0
			@x = @radius
			@dX *= -1
		elsif @y - @radius <= 0
			@y = @radius
			@dY *= -1
		elsif @x + @radius >= $win_width
			@x = $win_width - @radius * 2
			@dX *= -1
		elsif @y + @radius >= $win_height
			@y = $win_height - @radius * 2
			@dY *= -1
		end
	end
	
	def get_distance(ball)
		return (@x - ball.x).abs + (@y - ball.y).abs
	end
	
	def draw
		@@img[0].draw(@x - @radius, @y - @radius, 1)
	end

end

class Line

	attr_reader :x1, :x2, :y1, :y2, :speed, :is_vertical

	def initialize(x, y, is_vertical, speed = 2)
		@x1 = @x2 = x
		@y1 = @y2 = y
		@speed = speed
		@is_vertical = is_vertical
		
		@expand_up = @expand_down = @is_vertical
		@expand_left = @expand_right = !@is_vertical

		@@color ||= Gosu::Color.new(7, 157, 208)
	end

	# Returns the center point of the line as an array [x, y]
	def get_center
		if(is_vertical)
			return [x1, (y2 + y1) / 2]	
		else
			return [(x2 + x1) / 2, y1]
		end	
	end

	def check_intersects_line(line)
		if is_vertical
			if @expand_up && @y1 == line.y1
				if @x1 >= line.x1 && @x2 <= line.x2
					@expand_up = false
				end
			elsif @expand_down && @y2 == line.y2
				if @x1 >= line.x1 && @x2 <= line.x2
					@expand_down = false
				end
			end
		else
			if @expand_left && @x1 == line.x1
				if @y1 >= line.y1 && @y2 <= line.y2
					@expand_left = false
				end
			elsif @expand_right && @x2 == line.x2
				if @y1 >= line.y1 && @y2 <= line.y2
					@expand_right = false
				end
			end
		end
	end

	# Returns true if line has intersected with another line, false otherwise
	def check_intersects_lines(lines)
		lines.each do |line|
			if line != self
				check_intersects_line(line)
			end
		end
	end

	# Returns true if done expanding, false otherwise
	def update(lines_expanding, lines_expanded)	
		for i in (0...speed) # Increment size by 1 in order to not extend outside of intersected lines
			if is_vertical
				@y1 -= 1 if @expand_up
				@y2 += 1 if @expand_down

				@expand_up = false if @y1 == 0
				@expand_down = false if @y2 == $win_height
					
				return true if !@expand_up && !@expand_down
			else
				@x1 -= 1 if @expand_left
				@x2 += 1 if @expand_right

				@expand_left = false if @x1 == 0
				@expand_right = false if @x2 == $win_width

				return true if !@expand_left && !@expand_right
			end
			# Check to see if expansion caused intersection with other lines
			check_intersects_lines(lines_expanding)
			check_intersects_lines(lines_expanded)
		end
		return false
	end

	def draw
		$window.draw_line(@x1, @y1, @@color, @x2, @y2, @@color, 1)
	end
end
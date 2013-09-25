require 'rubygems'
require 'gosu'
require 'set'
require_relative 'ball'
require_relative 'line'
require_relative 'area'

class Window < Gosu::Window

	def initialize(width, height)
		super(width, height, false)
		self.caption = "Divide0"
		@font = Gosu::Font.new(self, Gosu::default_font_name, 16)
		@bg_color = Gosu::Color.new(255, 0, 0, 50)	# (a, r, g, b)
		@bg_gameover_color = Gosu::Color.new(255, 150, 0, 0)
		@line_color = Gosu::Color.new(255, 7, 157, 208)
		@is_gameover = false
		
		@random = Random.new
		@balls = Set.new
		@lines_expanding = Set.new
		@lines_expanded = Set.new
		@area = Area.new(0, $win_width, 0, $win_height)
	end
	
	def line_contains_point?(line, x, y)
		if x == line.x1 && (y >= line.y1 && y <= line.y2)
				return true
		elsif y == line.y1 && (x >= line.x1 && x <= line.x2)
				return true
		end
		return false
	end

	def lines_contain_point?(lines, x, y)
		lines.each do |line|
			if line_contains_point?(line, x, y)
				return true
			end
		end
		return false
	end

	def get_rand_ball
		dX = @random.rand(3..6)
		dX *= dX % 2 == 0 ? 1 : -1
		
		dY = @random.rand(3..6)
		dY *= dY % 2 == 0 ? 1 : -1
		
		return Ball.new(@random.rand(0..$win_width), @random.rand(0..$win_height), dX, dY)
	end

	def reset_game
		@balls.clear
		@lines_expanding.clear
		@lines_expanded.clear
		@is_gameover = false
	end

	# Will handle gameover conditions in the future
	def call_gameover
		@is_gameover = true
	end
	
	# Calls the corresponding update methods for all lines and balls, and checks for gameover
	def update
		if !@is_gameover
			# Move balls
			@balls.each do |ball|
				ball.move
				call_gameover if ball.update(@balls, @lines_expanding, @lines_expanded) # If collision with expading line is detected, game over
			end

			@lines_expanding.each do |line|
				# Expand line and add to set of expanded lines if line is fully expanded
				if line.update(@lines_expanding, @lines_expanded)
					@lines_expanded << line
					@area.divide(line)
				end
				@lines_expanding -= @lines_expanded	# Removes expanded line from expanding set to prevent unneccesary updates
			end
		end
	end
	
	def draw
		color = @is_gameover ? @bg_gameover_color : @bg_color
		draw_quad(0, 0, color, $win_width, 0, color, 0, $win_height, color, $win_width, $win_height, color, 0)

		@area.draw

		# Draw balls
		@balls.each do |ball|
			ball.draw
		end

		# Draw lines
		@lines_expanding.each do |line|
			line.draw
		end
		@lines_expanded.each do |line|
			line.draw
		end
		
		# Frame rate
		@font.draw(Gosu::fps(), 5, 5, 2, 1.0, 1.0, 0xffffffff)
	end
	
	# Handles keyboard input
	def button_down(id)
		case id
		when Gosu::MsLeft
			if !lines_contain_point?(@lines_expanding, mouse_x, mouse_y) && 
				!lines_contain_point?(@lines_expanded, mouse_x, mouse_y)
					@lines_expanding << Line.new(mouse_x, mouse_y, false)
			end
		when Gosu::MsRight
			if !lines_contain_point?(@lines_expanding, mouse_x, mouse_y) && 
				!lines_contain_point?(@lines_expanded, mouse_x, mouse_y)
					@lines_expanding << Line.new(mouse_x, mouse_y, true)
			end
		when Gosu::KbR
			@balls << get_rand_ball
		when Gosu::KbSpace
			reset_game
		when Gosu::KbEscape
			close
		end
	end
	
	# Forces Gosu to paint cursor
	def needs_cursor?
		true
	end
	
end

$win_width = 500
$win_height = 500
$window = Window.new($win_width, $win_height)
$window.show
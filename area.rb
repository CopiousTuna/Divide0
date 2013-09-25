
class Area
	
	attr_reader :x1, :x2, :y1, :y2
	
	def initialize(x1, x2, y1, y2)
		@x1 = x1
		@x2 = x2
		@y1 = y1
		@y2 = y2
		@children = Set.new
				
		@@color ||= Gosu::Color.new(20, 0, 100, 0)
	end
	
	# If area has children, recursively travel down children to find correct area to split
	# If area has no children and contains the newly expanded line, split it
	def divide(line)
		if !@children.empty?
			@children.each do |child|
				child.divide(line)
			end
		elsif contains_line(line)
			split(line)
		end
	end
	
	# Return true if the area contains the given line
	def contains_line(line)
		point = line.get_center
		return point[0] >= @x1 && point[0] <= @x2 && point[1] >= @y1 && point[1] <= @y2
	end
	
	# Split the area in two based on the position of the expanded line
	def split(line)
		if line.is_vertical
			@children << Area.new(@x1, line.x1, @y1, @y2)
			@children << Area.new(line.x1, @x2, @y1, @y2)
		else
			@children << Area.new(@x1, @x2, @y1, line.y1)
			@children << Area.new(@x1, @x2, line.y1, @y2)
		end
	end
	
	def draw
		$window.draw_quad(@x1, @y1, @@color, @x2, @y1, @@color, 
			@x1, @y2, @@color, @x2, @y2, @@color, 0)
			
		@children.each do |child|
			child.draw
		end
	end
	
end
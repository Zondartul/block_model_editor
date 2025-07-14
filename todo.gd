extends Node

# Stuff we need
# [Feature 1] make shapes
#	[F1.1] primitive shapes: box, cylinder, sphere
# [Feature 2] manipulate shapes
#	[F2.1] editing via inspector window
#	[F2.2] editing via 3D controls (gizmos)
# [Feature 3] save/load shapes
#	[F3.1] basic savefile
#	[F3.2] export to common mesh formats
#	[F3.3] use a DB file as directory
# [Feature 4] change apperance
#	[F4.1] change color
#	[F4.2] apply texture
#	[F4.3] edit texture
#		[F4.3.1] open external editor
#		[F4.3.2] 3D painting
# [Feature 5] generated content
#	[F5.1] CSG shape addition and subtraction
#	[F5.2] utility shapes like AABB, convex hull, etc
#	[F5.3] shape script like OpenSCAD
#	[F5.4] mesh modifiers/mutators
# [Feature 6] animation
#	[F6.1] keyframe format
#	[F6.2] transform keys
#	[F6.3] shape-keys
#	[F6.4] skeleton
#	[F6.5] multiple animation strips
#
# UX Pieces
# [Main window] -> [menu-bar] + [object list] + [editor]
# |
# +[editor] -> [viewport] + [tool palette] + [inspector]
# | + [viewport] -> background + shapes + 3D gizmos  <-- [3D input handling (raycasts)]
# +[object list] -> database -> current file -> main body, utility objects -> selectable objects
# 
# Data formats
# body
# +- shape
#    +- shape_info (view<->model link)
#    +- shape generator (controller<->model link)
#
# ui
# +- inspector (shape<->ui link)
# +- viewport
#    +- camera/raycasts (3D-2D input translator)
#    +- 3d mouseover (3D input state)
#  

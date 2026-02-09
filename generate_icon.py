from PIL import Image, ImageDraw, ImageFont
import os

# Create icon directory if it doesn't exist
os.makedirs('assets/icon', exist_ok=True)

# Create main icon (1024x1024)
size = 1024
image = Image.new('RGBA', (size, size), (31, 122, 77, 255))  # Green background

# Create a rounded square
mask = Image.new('L', (size, size), 0)
draw_mask = ImageDraw.Draw(mask)
draw_mask.rounded_rectangle([(0, 0), (size, size)], radius=size//5, fill=255)
image.putalpha(mask)

# Draw simple mosque icon shape
draw = ImageDraw.Draw(image)
# Central dome
dome_center = (size//2, size//2 - 50)
dome_radius = size//5
draw.ellipse([dome_center[0]-dome_radius, dome_center[1]-dome_radius, 
              dome_center[0]+dome_radius, dome_center[1]+dome_radius], 
             fill=(255, 255, 255, 255))

# Minaret left
minaret_width = size//15
minaret_height = size//3
draw.rectangle([size//4 - minaret_width//2, size//2 - minaret_height//2,
                size//4 + minaret_width//2, size//2 + minaret_height//2], 
               fill=(255, 255, 255, 255))

# Minaret right
draw.rectangle([3*size//4 - minaret_width//2, size//2 - minaret_height//2,
                3*size//4 + minaret_width//2, size//2 + minaret_height//2], 
               fill=(255, 255, 255, 255))

# Base building
base_width = size//2
base_height = size//4
draw.rectangle([size//2 - base_width//2, size//2 + dome_radius//2,
                size//2 + base_width//2, size//2 + dome_radius//2 + base_height], 
               fill=(255, 255, 255, 255))

# Save main icon
image.save('assets/icon/icon.png')
print("✓ Created main icon: assets/icon/icon.png")

# Create foreground for adaptive icon (transparent background)
fg_image = Image.new('RGBA', (size, size), (0, 0, 0, 0))
draw_fg = ImageDraw.Draw(fg_image)

# Draw same mosque shape but larger for foreground
dome_center = (size//2, size//2 - 30)
dome_radius = size//4
draw_fg.ellipse([dome_center[0]-dome_radius, dome_center[1]-dome_radius, 
                dome_center[0]+dome_radius, dome_center[1]+dome_radius], 
               fill=(255, 255, 255, 255))

minaret_width = size//12
minaret_height = size//2.5
draw_fg.rectangle([size//4 - minaret_width//2, size//2 - minaret_height//2,
                  size//4 + minaret_width//2, size//2 + minaret_height//2], 
                 fill=(255, 255, 255, 255))
draw_fg.rectangle([3*size//4 - minaret_width//2, size//2 - minaret_height//2,
                  3*size//4 + minaret_width//2, size//2 + minaret_height//2], 
                 fill=(255, 255, 255, 255))

base_width = size//1.6
base_height = size//3
draw_fg.rectangle([size//2 - base_width//2, size//2 + dome_radius//2,
                  size//2 + base_width//2, size//2 + dome_radius//2 + base_height], 
                 fill=(255, 255, 255, 255))

fg_image.save('assets/icon/icon_foreground.png')
print("✓ Created foreground icon: assets/icon/icon_foreground.png")

print("\n✓ Icon generation complete!")
print("Run: flutter pub get")
print("Then: dart run flutter_launcher_icons")

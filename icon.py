import math

def generate_svg(colors, radius, size):
    centerX = size / 2
    centerY = size / 2

    svg = f'<svg width="{size}" height="{size}" viewBox="0 0 {size} {size}" xmlns="http://www.w3.org/2000/svg">\n'
    svg += f'    <circle cx="{centerX}" cy="{centerY}" r="{radius}" fill="none" stroke="none"/>\n'

    for index, color in enumerate(colors):
        angle = (index / len(colors)) * 2 * math.pi
        x = centerX + radius * math.cos(angle)
        y = centerY + radius * math.sin(angle)
        svg += f'    <circle cx="{x}" cy="{y}" r="20" fill="{color}" stroke="none"/>\n'

    svg += '</svg>'
    return svg

colors = ["red", "orange", "yellow", "green", "blue", "indigo", "purple"]
radius = 60
size = 200

svg_code = generate_svg(colors, radius, size)
print(svg_code)
